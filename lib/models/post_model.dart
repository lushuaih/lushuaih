import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String authorId;
  final String authorName;
  final String? authorAvatar;
  final String title;
  final String content;
  final List<String> images;
  final List<String> tags;
  final String category;
  final int likesCount;
  final int commentsCount;
  final int viewsCount;
  final bool isPinned;
  final bool isHot;
  final DateTime createdAt;
  final DateTime? updatedAt;

  PostModel({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorAvatar,
    required this.title,
    required this.content,
    this.images = const [],
    this.tags = const [],
    this.category = 'general',
    this.likesCount = 0,
    this.commentsCount = 0,
    this.viewsCount = 0,
    this.isPinned = false,
    this.isHot = false,
    required this.createdAt,
    this.updatedAt,
  });

  factory PostModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PostModel(
      id: doc.id,
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? 'Anonymous',
      authorAvatar: data['authorAvatar'],
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      tags: List<String>.from(data['tags'] ?? []),
      category: data['category'] ?? 'general',
      likesCount: data['likesCount'] ?? 0,
      commentsCount: data['commentsCount'] ?? 0,
      viewsCount: data['viewsCount'] ?? 0,
      isPinned: data['isPinned'] ?? false,
      isHot: data['isHot'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'authorId': authorId,
      'authorName': authorName,
      'authorAvatar': authorAvatar,
      'title': title,
      'content': content,
      'images': images,
      'tags': tags,
      'category': category,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'viewsCount': viewsCount,
      'isPinned': isPinned,
      'isHot': isHot,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  PostModel copyWith({
    int? likesCount,
    int? commentsCount,
    int? viewsCount,
    bool? isHot,
  }) {
    return PostModel(
      id: id,
      authorId: authorId,
      authorName: authorName,
      authorAvatar: authorAvatar,
      title: title,
      content: content,
      images: images,
      tags: tags,
      category: category,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      viewsCount: viewsCount ?? this.viewsCount,
      isPinned: isPinned,
      isHot: isHot ?? this.isHot,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class PostCategory {
  final String id;
  final String name;
  final String icon;
  final String description;

  const PostCategory({
    required this.id,
    required this.name,
    required this.icon,
    this.description = '',
  });

  static const List<PostCategory> defaults = [
    PostCategory(id: 'general', name: '综合', icon: '💬'),
    PostCategory(id: 'tech', name: '技术', icon: '💻'),
    PostCategory(id: 'life', name: '生活', icon: '🌱'),
    PostCategory(id: 'entertainment', name: '娱乐', icon: '🎮'),
    PostCategory(id: 'question', name: '问答', icon: '❓'),
    PostCategory(id: 'news', name: '资讯', icon: '📰'),
  ];
}
