import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  like,
  comment,
  follow,
  mention,
  system,
  report,
}

class NotificationModel {
  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String? content;
  final String? postId;
  final String? actorId;
  final String? actorName;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    this.content,
    this.postId,
    this.actorId,
    this.actorName,
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      type: NotificationType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => NotificationType.system,
      ),
      title: data['title'] ?? '',
      content: data['content'],
      postId: data['postId'],
      actorId: data['actorId'],
      actorName: data['actorName'],
      isRead: data['isRead'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'type': type.name,
      'title': title,
      'content': content,
      'postId': postId,
      'actorId': actorId,
      'actorName': actorName,
      'isRead': isRead,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}

class ReportModel {
  final String id;
  final String reporterId;
  final String reporterName;
  final String targetType; // 'post', 'comment', 'user'
  final String targetId;
  final String reason;
  final String? description;
  final String status; // 'pending', 'reviewed', 'resolved', 'rejected'
  final DateTime createdAt;

  ReportModel({
    required this.id,
    required this.reporterId,
    required this.reporterName,
    required this.targetType,
    required this.targetId,
    required this.reason,
    this.description,
    this.status = 'pending',
    required this.createdAt,
  });

  factory ReportModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReportModel(
      id: doc.id,
      reporterId: data['reporterId'] ?? '',
      reporterName: data['reporterName'] ?? 'Anonymous',
      targetType: data['targetType'] ?? 'post',
      targetId: data['targetId'] ?? '',
      reason: data['reason'] ?? '',
      description: data['description'],
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'reporterId': reporterId,
      'reporterName': reporterName,
      'targetType': targetType,
      'targetId': targetId,
      'reason': reason,
      'description': description,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
