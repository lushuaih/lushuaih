import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';

class UsersProvider extends ChangeNotifier {
  final FirebaseService _firebase = FirebaseService();
  
  Map<String, UserModel> _usersCache = {};
  Map<String, bool> _followingStatus = {};
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<UserModel?> getUser(String userId) async {
    if (_usersCache.containsKey(userId)) {
      return _usersCache[userId];
    }

    try {
      final user = await _firebase.getUser(userId);
      if (user != null) {
        _usersCache[userId] = user;
      }
      return user;
    } catch (e) {
      _error = '获取用户信息失败';
      notifyListeners();
      return null;
    }
  }

  Stream<UserModel?> getUserStream(String userId) {
    return _firebase.getUserStream(userId);
  }

  Future<bool> isFollowing(String currentUserId, String targetUserId) async {
    if (_followingStatus.containsKey(targetUserId)) {
      return _followingStatus[targetUserId]!;
    }

    final isFollowing = await _firebase.isFollowing(currentUserId, targetUserId);
    _followingStatus[targetUserId] = isFollowing;
    return isFollowing;
  }

  Future<void> toggleFollow(String currentUserId, String targetUserId) async {
    await _firebase.toggleFollow(currentUserId, targetUserId);
    
    final currentStatus = _followingStatus[targetUserId] ?? false;
    _followingStatus[targetUserId] = !currentStatus;
    
    // Update cached user data
    if (_usersCache.containsKey(targetUserId)) {
      final user = _usersCache[targetUserId]!;
      _usersCache[targetUserId] = user.copyWith(
        followersCount: currentStatus 
            ? user.followersCount - 1 
            : user.followersCount + 1,
      );
    }
    
    notifyListeners();
  }

  Future<List<UserModel>> searchUsers(String query) async {
    try {
      final snapshot = await _firebase.usersRef
          .orderBy('username')
          .startAt([query])
          .endAt(['$query\uf8ff'])
          .limit(20)
          .get();

      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      _error = '搜索用户失败';
      notifyListeners();
      return [];
    }
  }

  void clearCache() {
    _usersCache.clear();
    _followingStatus.clear();
    notifyListeners();
  }
}
