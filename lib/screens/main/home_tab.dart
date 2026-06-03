import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/posts_provider.dart';
import '../../models/post_model.dart';
import '../post/create_post_screen.dart';
import '../post/post_detail_screen.dart';
import '../search/search_screen.dart';
import '../notifications/notifications_screen.dart';
import 'widgets/post_card.dart';
import 'widgets/category_tabs.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  String _selectedCategory = '';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadPosts();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<PostsProvider>().loadPosts(category: _selectedCategory);
    }
  }

  Future<void> _loadPosts() async {
    await context.read<PostsProvider>().loadPosts(
      category: _selectedCategory,
      refresh: true,
    );
    
    final userId = context.read<AuthProvider>().user?.id;
    if (userId != null) {
      await context.read<PostsProvider>().loadLikedPosts(userId);
    }
  }

  Future<void> _onRefresh() async {
    await _loadPosts();
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
    });
    context.read<PostsProvider>().loadPosts(
      category: category,
      refresh: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('lushuaih'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Tabs
          CategoryTabs(
            selectedCategory: _selectedCategory,
            onCategorySelected: _onCategorySelected,
          ),
          
          // Posts List
          Expanded(
            child: Consumer<PostsProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading && provider.posts.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.posts.isEmpty) {
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

                return RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.posts.length + 
                        (provider.isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == provider.posts.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final post = provider.posts[index];
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
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreatePostScreen()),
          );
          _loadPosts();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
