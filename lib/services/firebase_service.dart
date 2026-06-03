import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/user_model.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';
import '../models/notification_model.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Collections
  CollectionReference get usersRef => _firestore.collection('users');
  CollectionReference get postsRef => _firestore.collection('posts');
  CollectionReference get commentsRef => _firestore.collection('comments');
  CollectionReference get messagesRef => _firestore.collection('messages');
  CollectionReference get notificationsRef => _firestore.collection('notifications');
  CollectionReference get reportsRef => _firestore.collection('reports');
  CollectionReference get likesRef => _firestore.collection('likes');
  CollectionReference get followsRef => _firestore.collection('follows');

  // Auth Methods
  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signUp(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // User Methods
  Future<void> createUser(UserModel user) async {
    await usersRef.doc(user.id).set(user.toMap());
  }

  Future<UserModel?> getUser(String userId) async {
    final doc = await usersRef.doc(userId).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  Stream<UserModel?> getUserStream(String userId) {
    return usersRef.doc(userId).snapshots().map((doc) {
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    });
  }

  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    await usersRef.doc(userId).update(data);
  }

  Future<String?> uploadAvatar(String userId, String filePath) async {
    final ref = _storage.ref().child('avatars/$userId.jpg');
    await ref.putFile(File(filePath));
    return await ref.getDownloadURL();
  }

  // Post Methods
  Future<void> createPost(PostModel post) async {
    await postsRef.add(post.toMap());
  }

  Future<List<PostModel>> getPosts({
    String? category,
    String? authorId,
    int limit = 20,
    DocumentSnapshot? lastDocument,
  }) async {
    Query query = postsRef.orderBy('createdAt', descending: true);
    
    if (category != null) {
      query = query.where('category', isEqualTo: category);
    }
    if (authorId != null) {
      query = query.where('authorId', isEqualTo: authorId);
    }
    
    query = query.limit(limit);
    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => PostModel.fromFirestore(doc))
        .toList();
  }

  Future<List<PostModel>> getHotPosts({int limit = 10}) async {
    final snapshot = await postsRef
        .where('isHot', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
    
    return snapshot.docs
        .map((doc) => PostModel.fromFirestore(doc))
        .toList();
  }

  Future<List<PostModel>> searchPosts(String query) async {
    final snapshot = await postsRef
        .orderBy('title')
        .startAt([query])
        .endAt(['$query\uf8ff'])
        .limit(20)
        .get();
    
    return snapshot.docs
        .map((doc) => PostModel.fromFirestore(doc))
        .toList();
  }

  Stream<PostModel> getPostStream(String postId) {
    return postsRef.doc(postId).snapshots().map((doc) {
      return PostModel.fromFirestore(doc);
    });
  }

  Future<void> updatePost(String postId, Map<String, dynamic> data) async {
    await postsRef.doc(postId).update(data);
  }

  Future<void> deletePost(String postId) async {
    await postsRef.doc(postId).delete();
    
    // Delete related comments
    final comments = await commentsRef
        .where('postId', isEqualTo: postId)
        .get();
    
    for (final doc in comments.docs) {
      await doc.reference.delete();
    }
  }

  // Comment Methods
  Future<void> createComment(CommentModel comment) async {
    await commentsRef.add(comment.toMap());
    
    // Update post comments count
    await postsRef.doc(comment.postId).update({
      'commentsCount': FieldValue.increment(1),
    });
  }

  Future<List<CommentModel>> getComments(String postId) async {
    final snapshot = await commentsRef
        .where('postId', isEqualTo: postId)
        .orderBy('createdAt', descending: true)
        .get();
    
    return snapshot.docs
        .map((doc) => CommentModel.fromFirestore(doc))
        .toList();
  }

  Future<void> deleteComment(String commentId, String postId) async {
    await commentsRef.doc(commentId).delete();
    
    await postsRef.doc(postId).update({
      'commentsCount': FieldValue.increment(-1),
    });
  }

  // Like Methods
  Future<bool> isLiked(String userId, String postId) async {
    final doc = await likesRef
        .where('userId', isEqualTo: userId)
        .where('postId', isEqualTo: postId)
        .get();
    return doc.docs.isNotEmpty;
  }

  Future<void> toggleLike(String userId, String postId) async {
    final existing = await likesRef
        .where('userId', isEqualTo: userId)
        .where('postId', isEqualTo: postId)
        .get();

    if (existing.docs.isEmpty) {
      await likesRef.add({
        'userId': userId,
        'postId': postId,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      await postsRef.doc(postId).update({
        'likesCount': FieldValue.increment(1),
      });
    } else {
      await existing.docs.first.reference.delete();
      
      await postsRef.doc(postId).update({
        'likesCount': FieldValue.increment(-1),
      });
    }
  }

  // Follow Methods
  Future<bool> isFollowing(String currentUserId, String targetUserId) async {
    final doc = await followsRef
        .where('followerId', isEqualTo: currentUserId)
        .where('followingId', isEqualTo: targetUserId)
        .get();
    return doc.docs.isNotEmpty;
  }

  Future<void> toggleFollow(String currentUserId, String targetUserId) async {
    final existing = await followsRef
        .where('followerId', isEqualTo: currentUserId)
        .where('followingId', isEqualTo: targetUserId)
        .get();

    if (existing.docs.isEmpty) {
      await followsRef.add({
        'followerId': currentUserId,
        'followingId': targetUserId,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      await usersRef.doc(currentUserId).update({
        'followingCount': FieldValue.increment(1),
      });
      await usersRef.doc(targetUserId).update({
        'followersCount': FieldValue.increment(1),
      });
    } else {
      await existing.docs.first.reference.delete();
      
      await usersRef.doc(currentUserId).update({
        'followingCount': FieldValue.increment(-1),
      });
      await usersRef.doc(targetUserId).update({
        'followersCount': FieldValue.increment(-1),
      });
    }
  }

  // Message Methods
  Future<void> sendMessage(MessageModel message) async {
    await messagesRef.add(message.toMap());
  }

  Future<List<MessageModel>> getMessages(String userId1, String userId2) async {
    final snapshot = await messagesRef
        .where('senderId', whereIn: [userId1, userId2])
        .where('receiverId', whereIn: [userId1, userId2])
        .orderBy('createdAt', descending: true)
        .limit(50)
        .get();
    
    return snapshot.docs
        .map((doc) => MessageModel.fromFirestore(doc))
        .toList();
  }

  // Notification Methods
  Future<void> createNotification(NotificationModel notification) async {
    await notificationsRef.add(notification.toMap());
  }

  Future<List<NotificationModel>> getNotifications(String userId) async {
    final snapshot = await notificationsRef
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .get();
    
    return snapshot.docs
        .map((doc) => NotificationModel.fromFirestore(doc))
        .toList();
  }

  Future<void> markNotificationRead(String notificationId) async {
    await notificationsRef.doc(notificationId).update({'isRead': true});
  }

  Future<int> getUnreadNotificationsCount(String userId) async {
    final snapshot = await notificationsRef
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();
    return snapshot.docs.length;
  }

  // Report Methods
  Future<void> createReport(ReportModel report) async {
    await reportsRef.add(report.toMap());
  }

  Future<List<ReportModel>> getReports({String status = 'pending'}) async {
    final snapshot = await reportsRef
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .get();
    
    return snapshot.docs
        .map((doc) => ReportModel.fromFirestore(doc))
        .toList();
  }

  Future<void> updateReportStatus(String reportId, String status) async {
    await reportsRef.doc(reportId).update({'status': status});
  }
}
