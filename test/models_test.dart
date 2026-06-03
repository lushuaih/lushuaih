import 'package:flutter_test/flutter_test.dart';
import 'package:lushuaih/models/user_model.dart';
import 'package:lushuaih/models/post_model.dart';

void main() {
  group('UserModel Tests', () {
    test('UserModel creation and serialization', () {
      final user = UserModel(
        id: 'test123',
        email: 'test@example.com',
        username: 'testuser',
        bio: 'Test bio',
        followersCount: 100,
        followingCount: 50,
        postsCount: 10,
        createdAt: DateTime(2024, 1, 1),
      );

      expect(user.id, 'test123');
      expect(user.email, 'test@example.com');
      expect(user.username, 'testuser');
      expect(user.bio, 'Test bio');
      expect(user.followersCount, 100);
      expect(user.followingCount, 50);
      expect(user.postsCount, 10);
    });

    test('UserModel fromMap', () {
      final map = {
        'email': 'test@example.com',
        'username': 'testuser',
        'bio': 'Test bio',
        'followersCount': 100,
        'followingCount': 50,
        'postsCount': 10,
        'createdAt': '2024-01-01T00:00:00.000',
        'isOnline': true,
      };

      final user = UserModel.fromMap(map, 'test123');

      expect(user.id, 'test123');
      expect(user.email, 'test@example.com');
      expect(user.username, 'testuser');
    });

    test('UserModel copyWith', () {
      final user = UserModel(
        id: 'test123',
        email: 'test@example.com',
        username: 'testuser',
        createdAt: DateTime(2024, 1, 1),
      );

      final updatedUser = user.copyWith(
        username: 'newname',
        bio: 'New bio',
      );

      expect(updatedUser.username, 'newname');
      expect(updatedUser.bio, 'New bio');
      expect(updatedUser.email, user.email); // Unchanged
    });
  });

  group('PostModel Tests', () {
    test('PostCategory defaults', () {
      expect(PostCategory.defaults.length, 6);
      expect(PostCategory.defaults[0].id, 'general');
      expect(PostCategory.defaults[0].name, '综合');
    });
  });
}
