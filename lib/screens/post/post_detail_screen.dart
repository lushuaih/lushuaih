import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/post_model.dart';
import '../../models/comment_model.dart';
import '../../models/notification_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/posts_provider.dart';
import '../../providers/users_provider.dart';
import '../../services/firebase_service.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostDetailScreen extends StatefulWidget {
  final PostModel post;

  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final FirebaseService _firebase = FirebaseService();
  final _commentController = TextEditingController();
  List<CommentModel> _comments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadComments();
    _incrementViews();
  }

  Future<void> _loadComments() async {
    final comments = await _firebase.getComments(widget.post.id);
    setState(() {
      _comments = comments;
      _isLoading = false;
    });
  }

  Future<void> _incrementViews() async {
    await context.read<PostsProvider>().incrementViews(widget.post.id);
  }

  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty) return;

    final user = context.read<AuthProvider>().user;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先登录')),
      );
      return;
    }

    final comment = CommentModel(
      id: '',
      postId: widget.post.id,
      authorId: user.id,
      authorName: user.username,
      authorAvatar: user.avatarUrl,
      content: _commentController.text.trim(),
      createdAt: DateTime.now(),
    );

    await _firebase.createComment(comment);
    _commentController.clear();
    await _loadComments();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('评论成功')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('帖子详情'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              _showPostOptions();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Author info
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundImage: widget.post.authorAvatar != null
                            ? NetworkImage(widget.post.authorAvatar!)
                            : null,
                        child: widget.post.authorAvatar == null
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.post.authorName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              timeago.format(widget.post.createdAt, locale: 'zh'),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      FollowButton(authorId: widget.post.authorId),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Title
                  Text(
                    widget.post.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Content
                  Text(
                    widget.post.content,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.6,
                    ),
                  ),
                  
                  // Images
                  if (widget.post.images.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    ...widget.post.images.map((url) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            url,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) {
                              return Container(
                                height: 200,
                                color: Colors.grey[300],
                                child: const Center(
                                  child: Icon(Icons.broken_image),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    }),
                  ],
                  
                  // Tags
                  if (widget.post.tags.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: widget.post.tags.map((tag) {
                        return Chip(
                          label: Text('#$tag'),
                          backgroundColor: 
                              Theme.of(context).colorScheme.primaryContainer,
                        );
                      }).toList(),
                    ),
                  ],
                  
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  
                  // Stats
                  Row(
                    children: [
                      Text(
                        '${widget.post.likesCount} 赞 · ${widget.post.commentsCount} 评论 · ${widget.post.viewsCount} 浏览',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Comments Section
                  Row(
                    children: [
                      const Text(
                        '评论',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${_comments.length})',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (_comments.isEmpty)
                    _buildEmptyComments()
                  else
                    ..._comments.map((comment) {
                      return _buildCommentItem(comment);
                    }),
                ],
              ),
            ),
          ),
          
          // Comment Input
          _buildCommentInput(),
        ],
      ),
    );
  }

  Widget _buildEmptyComments() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 8),
            Text(
              '暂无评论，来说点什么吧',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentItem(CommentModel comment) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: comment.authorAvatar != null
                ? NetworkImage(comment.authorAvatar!)
                : null,
            child: comment.authorAvatar == null
                ? const Icon(Icons.person, size: 16)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.authorName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      timeago.format(comment.createdAt, locale: 'zh'),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment.content,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        // Like comment
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.thumb_up_outlined,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${comment.likesCount}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    InkWell(
                      onTap: () {
                        // Reply to comment
                      },
                      child: Text(
                        '回复',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: '写评论...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              maxLines: 1,
            ),
          ),
          const SizedBox(width: 12),
          Consumer<AuthProvider>(
            builder: (context, auth, _) {
              return IconButton(
                onPressed: auth.isAuthenticated ? _submitComment : null,
                icon: Icon(
                  Icons.send,
                  color: Theme.of(context).colorScheme.primary,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showPostOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.bookmark_outline),
                title: const Text('收藏'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('已收藏')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.share_outlined),
                title: const Text('分享'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.flag_outlined),
                title: const Text('举报'),
                onTap: () {
                  Navigator.pop(context);
                  _showReportDialog();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showReportDialog() {
    final reasons = [
      '垃圾广告',
      '不实信息',
      '违法违规',
      '侵权内容',
      '其他',
    ];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('举报原因'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: reasons.map((reason) {
              return ListTile(
                title: Text(reason),
                onTap: () async {
                  final user = context.read<AuthProvider>().user;
                  if (user != null) {
                    await _firebase.createReport(ReportModel(
                      id: '',
                      reporterId: user.id,
                      reporterName: user.username,
                      targetType: 'post',
                      targetId: widget.post.id,
                      reason: reason,
                      createdAt: DateTime.now(),
                    ));
                  }
                  
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('举报成功，我们会尽快处理')),
                    );
                  }
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class FollowButton extends StatefulWidget {
  final String authorId;

  const FollowButton({super.key, required this.authorId});

  @override
  State<FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {
  bool _isFollowing = false;

  @override
  void initState() {
    super.initState();
    _checkFollowing();
  }

  Future<void> _checkFollowing() async {
    final userId = context.read<AuthProvider>().user?.id;
    if (userId == null || userId == widget.authorId) return;

    final isFollowing = await context.read<UsersProvider>()
        .isFollowing(userId, widget.authorId);
    
    setState(() {
      _isFollowing = isFollowing;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = context.read<AuthProvider>().user?.id;
    
    if (currentUserId == null || currentUserId == widget.authorId) {
      return const SizedBox.shrink();
    }

    return TextButton(
      onPressed: () async {
        await context.read<UsersProvider>()
            .toggleFollow(currentUserId, widget.authorId);
        
        setState(() {
          _isFollowing = !_isFollowing;
        });
      },
      child: Text(_isFollowing ? '已关注' : '关注'),
    );
  }
}
