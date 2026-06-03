import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/notifications_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/notification_model.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final userId = context.read<AuthProvider>().user?.id;
    if (userId != null) {
      await context.read<NotificationsProvider>().loadNotifications(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('通知'),
        actions: [
          TextButton(
            onPressed: () async {
              final userId = context.read<AuthProvider>().user?.id;
              if (userId != null) {
                await context.read<NotificationsProvider>().markAllAsRead(userId);
              }
            },
            child: const Text('全部已读'),
          ),
        ],
      ),
      body: Consumer<NotificationsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.notifications.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: _loadNotifications,
            child: ListView.builder(
              itemCount: provider.notifications.length,
              itemBuilder: (context, index) {
                final notification = provider.notifications[index];
                return _buildNotificationTile(notification, provider);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '暂无通知',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTile(
    NotificationModel notification,
    NotificationsProvider provider,
  ) {
    return ListTile(
      leading: _buildNotificationIcon(notification.type),
      title: Text(
        notification.title,
        style: TextStyle(
          fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
        ),
      ),
      subtitle: notification.content != null
          ? Text(
              notification.content!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            timeago.format(notification.createdAt, locale: 'zh'),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          if (!notification.isRead)
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
      onTap: () async {
        if (!notification.isRead) {
          await provider.markAsRead(notification.id);
        }
        
        // Navigate based on notification type
        if (notification.postId != null) {
          // Navigate to post detail
        }
      },
    );
  }

  Widget _buildNotificationIcon(NotificationType type) {
    IconData iconData;
    Color color;

    switch (type) {
      case NotificationType.like:
        iconData = Icons.thumb_up;
        color = Colors.red;
        break;
      case NotificationType.comment:
        iconData = Icons.chat_bubble;
        color = Colors.blue;
        break;
      case NotificationType.follow:
        iconData = Icons.person_add;
        color = Colors.green;
        break;
      case NotificationType.mention:
        iconData = Icons.alternate_email;
        color = Colors.orange;
        break;
      case NotificationType.system:
        iconData = Icons.info;
        color = Colors.grey;
        break;
      case NotificationType.report:
        iconData = Icons.flag;
        color = Colors.red;
        break;
    }

    return CircleAvatar(
      backgroundColor: color.withOpacity(0.1),
      child: Icon(iconData, color: color),
    );
  }
}
