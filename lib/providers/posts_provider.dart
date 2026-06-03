import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';
import '../services/firebase_service.dart';

class PostsProvider extends ChangeNotifier {
  final FirebaseService _firebase = FirebaseService();
  
  List<PostModel> _posts = [];
  List<PostModel> _hotPosts = [];
  List<PostModel> _userPosts = [];
  Map<String, bool> _likedPosts = {};
  bool _isLoading = false;
  String? _error;
  DocumentSnapshot? _lastDocument;
  String? _currentCategory;

  List<PostModel> get posts => _posts;
  List<PostModel> get hotPosts => _hotPosts;
  List<PostModel> get userPosts => _userPosts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get currentCategory => _currentCategory;

  Future<void> loadPosts({String? category, bool refresh = false}) async {
    if (refresh) {
      _posts.clear();
      _lastDocument = null;
    }

    try {
      _isLoading = true;
      _currentCategory = category;
      notifyListeners();

      final newPosts = await _firebase.getPosts(
        category: category,
        limit: 20,
        lastDocument: _lastDocument,
      );

      if (newPosts.isNotEmpty) {
        _posts.addAll(newPosts);
        _lastDocument = null; // In real app, get last document
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = '加载失败，请重试';
      notifyListeners();
    }
  }

  Future<void> loadHotPosts() async {
    try {
      _hotPosts = await _firebase.getHotPosts(limit: 10);
      notifyListeners();
    } catch (e) {
      _error = '加载热门帖子失败';
      notifyListeners();
    }
  }

  Future<void> loadUserPosts(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      _userPosts = await _firebase.getPosts(authorId: userId);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = '加载用户帖子失败';
      notifyListeners();
    }
  }

  Future<List<PostModel>> searchPosts(String query) async {
    try {
      return await _firebase.searchPosts(query);
    } catch (e) {
      _error = '搜索失败';
      notifyListeners();
      return [];
    }
  }

  Future<bool> createPost({
    required String title,
    required String content,
    required String authorId,
    required String authorName,
    String? authorAvatar,
    List<String> images = const [],
    List<String> tags = const [],
    String category = 'general',
  }) async {
    try {
      final post = PostModel(
        id: '',
        authorId: authorId,
        authorName: authorName,
        authorAvatar: authorAvatar,
        title: title,
        content: content,
        images: images,
        tags: tags,
        category: category,
        createdAt: DateTime.now(),
      );

      await _firebase.createPost(post);
      
      // Add to local list
      _posts.insert(0, post);
      notifyListeners();
      
      return true;
    } catch (e) {
      _error = '发布失败';
      notifyListeners();
      return false;
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      await _firebase.deletePost(postId);
      _posts.removeWhere((p) => p.id == postId);
      notifyListeners();
    } catch (e) {
      _error = '删除失败';
      notifyListeners();
    }
  }

  Future<void> loadLikedPosts(String userId) async {
    for (final post in _posts) {
      final isLiked = await _firebase.isLiked(userId, post.id);
      _likedPosts[post.id] = isLiked;
    }
    notifyListeners();
  }

  Future<void> toggleLike(String userId, String postId) async {
    await _firebase.toggleLike(userId, postId);
    
    final isCurrentlyLiked = _likedPosts[postId] ?? false;
    _likedPosts[postId] = !isCurrentlyLiked;
    
    // Update local post
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final post = _posts[index];
      _posts[index] = post.copyWith(
        likesCount: isCurrentlyLiked 
            ? post.likesCount - 1 
            : post.likesCount + 1,
      );
    }
    
    notifyListeners();
  }

  bool isLiked(String postId) => _likedPosts[postId] ?? false;

  Future<void> incrementViews(String postId) async {
    await _firebase.updatePost(postId, {
      'viewsCount': FieldValue.increment(1),
    });
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
