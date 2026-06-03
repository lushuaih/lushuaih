import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/posts_provider.dart';
import '../../providers/users_provider.dart';
import '../post/post_detail_screen.dart';
import '../main/widgets/post_card.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;

  const UserProfileScreen({super.key, required this.userId});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool _isFollowing = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await context.read<PostsProvider>().loadUserPosts(widget.userId);
    
    final currentUserId = context.read<AuthProvider>().user?.id;
    if (currentUserId != null) {
      final isFollowing = await context.read<UsersProvider>()
          .isFollowing(currentUserId, widget.userId);
      setState(() {
        _isFollowing = isFollowing;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = context.read<AuthProvider>().user?.id;
    final isOwnProfile = currentUserId == widget.userId;

    return Scaffold(
      body: StreamBuilder<UserModel?>(
        stream: context.read<UsersProvider>().getUserStream(widget.userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = snapshot.data;
          if (user == null) {
            return const Center(child: Text('用户不存在'));
          }

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: 280,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: _buildHeader(user, isOwnProfile),
                  ),
                  bottom: const PreferredSize(
                    preferredSize: Size.fromHeight(48),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          '发布的帖子',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ];
            },
            body: _buildUserPosts(),
          );
        },
      ),
    );
  }

  Widget _buildHeader(UserModel user, bool isOwnProfile) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 80, 16, 16),
      child: Column(
        children: [
          // Avatar
          CircleAvatar(
            radius: 50,
            backgroundImage: user.avatarUrl != null
                ? NetworkImage(user.avatarUrl!)
                : null,
            child: user.avatarUrl == null
                ? const Icon(Icons.person, size: 50)
                : null,
          ),
          const SizedBox(height: 16),
          
          // Username
          Text(
            user.username,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          
          // Bio
          if (user.bio != null && user.bio!.isNotEmpty)
            Text(
              user.bio!,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 16),
          
          // Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem('帖子', user.postsCount),
              _buildStatItem('关注', user.followingCount),
              _buildStatItem('粉丝', user.followersCount),
            ],
          ),
          const SizedBox(height: 16),
          
          // Action Buttons
          if (!isOwnProfile)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final currentUserId = context.read<AuthProvider>().user?.id;
                      if (currentUserId != null) {
                        await context.read<UsersProvider>()
                            .toggleFollow(currentUserId, widget.userId);
                        setState(() {
                          _isFollowing = !_isFollowing;
                        });
                      }
                    },
                    icon: Icon(_isFollowing ? Icons.check : Icons.person_add),
                    label: Text(_isFollowing ? '已关注' : '关注'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isFollowing 
                          ? Colors.grey[300] 
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Navigate to chat
                    },
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: const Text('私信'),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int count) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildUserPosts() {
    return Consumer<PostsProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.userPosts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.article_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  '暂无帖子',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.userPosts.length,
          itemBuilder: (context, index) {
            final post = provider.userPosts[index];
            return PostCard(
              post: post,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PostDetailScreen(post: post),
                  ),
                );
              },
              onLike: () {
                final userId = context.read<AuthProvider>().user?.id;
                if (userId != null) {
                  provider.toggleLike(userId, post.id);
                }
              },
              isLiked: provider.isLiked(post.id),
            );
          },
        );
      },
    );
  }
}
