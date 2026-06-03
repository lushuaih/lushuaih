class UserModel {
  final String id;
  final String email;
  final String username;
  final String? avatarUrl;
  final String? bio;
  final int followersCount;
  final int followingCount;
  final int postsCount;
  final DateTime createdAt;
  final DateTime? lastActiveAt;
  final bool isOnline;

  UserModel({
    required this.id,
    required this.email,
    required this.username,
    this.avatarUrl,
    this.bio,
    this.followersCount = 0,
    this.followingCount = 0,
    this.postsCount = 0,
    required this.createdAt,
    this.lastActiveAt,
    this.isOnline = false,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      email: map['email'] ?? '',
      username: map['username'] ?? 'Anonymous',
      avatarUrl: map['avatarUrl'],
      bio: map['bio'],
      followersCount: map['followersCount'] ?? 0,
      followingCount: map['followingCount'] ?? 0,
      postsCount: map['postsCount'] ?? 0,
      createdAt: DateTime.parse(map['createdAt']),
      lastActiveAt: map['lastActiveAt'] != null 
          ? DateTime.parse(map['lastActiveAt']) 
          : null,
      isOnline: map['isOnline'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'username': username,
      'avatarUrl': avatarUrl,
      'bio': bio,
      'followersCount': followersCount,
      'followingCount': followingCount,
      'postsCount': postsCount,
      'createdAt': createdAt.toIso8601String(),
      'lastActiveAt': lastActiveAt?.toIso8601String(),
      'isOnline': isOnline,
    };
  }

  UserModel copyWith({
    String? username,
    String? avatarUrl,
    String? bio,
    int? followersCount,
    int? followingCount,
    int? postsCount,
    bool? isOnline,
  }) {
    return UserModel(
      id: id,
      email: email,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      postsCount: postsCount ?? this.postsCount,
      createdAt: createdAt,
      lastActiveAt: lastActiveAt,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}
