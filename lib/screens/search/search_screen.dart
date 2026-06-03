import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/posts_provider.dart';
import '../../providers/users_provider.dart';
import '../../models/post_model.dart';
import '../../models/user_model.dart';
import '../post/post_detail_screen.dart';
import '../profile/user_profile_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  List<PostModel> _postResults = [];
  List<UserModel> _userResults = [];
  bool _isSearching = false;
  String _searchType = 'posts'; // 'posts' or 'users'

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _postResults = [];
        _userResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    if (_searchType == 'posts') {
      _postResults = await context.read<PostsProvider>().searchPosts(query);
    } else {
      _userResults = await context.read<UsersProvider>().searchUsers(query);
    }

    setState(() {
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: _searchType == 'posts' ? '搜索帖子...' : '搜索用户...',
            border: InputBorder.none,
          ),
          autofocus: true,
          onChanged: (value) {
            _search(value);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              _searchController.clear();
              setState(() {
                _postResults = [];
                _userResults = [];
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Type Toggle
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'posts', label: Text('帖子')),
                ButtonSegment(value: 'users', label: Text('用户')),
              ],
              selected: {_searchType},
              onSelectionChanged: (Set<String> selection) {
                setState(() {
                  _searchType = selection.first;
                  _postResults = [];
                  _userResults = [];
                });
                _search(_searchController.text);
              },
            ),
          ),
          
          // Results
          Expanded(
            child: _buildResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchController.text.isEmpty) {
      return _buildSearchSuggestions();
    }

    if (_searchType == 'posts') {
      if (_postResults.isEmpty) {
        return _buildEmptyState('没有找到相关帖子');
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _postResults.length,
        itemBuilder: (context, index) {
          final post = _postResults[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(post.title),
              subtitle: Text(
                post.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PostDetailScreen(post: post),
                  ),
                );
              },
            ),
          );
        },
      );
    } else {
      if (_userResults.isEmpty) {
        return _buildEmptyState('没有找到相关用户');
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _userResults.length,
        itemBuilder: (context, index) {
          final user = _userResults[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: user.avatarUrl != null
                  ? NetworkImage(user.avatarUrl!)
                  : null,
              child: user.avatarUrl == null
                  ? const Icon(Icons.person)
                  : null,
            ),
            title: Text(user.username),
            subtitle: Text(
              user.bio ?? '这个人很懒，什么都没写',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Text(
              '${user.postsCount} 帖子',
              style: TextStyle(color: Colors.grey[600]),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => UserProfileScreen(userId: user.id),
                ),
              );
            },
          );
        },
      );
    }
  }

  Widget _buildSearchSuggestions() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '热门搜索',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              'Flutter',
              '技术分享',
              '生活日常',
              '求职',
              '学习笔记',
              '旅行',
            ].map((keyword) {
              return ActionChip(
                label: Text(keyword),
                onPressed: () {
                  _searchController.text = keyword;
                  _search(keyword);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
