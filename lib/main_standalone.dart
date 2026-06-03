import 'package:flutter/material.dart';

void main() {
  runApp(const LushuaihApp());
}

class LushuaihApp extends StatelessWidget {
  const LushuaihApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'lushuaih',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: [
        const HomeTab(),
        const DiscoverTab(),
        const MessagesTab(),
        const ProfileTab(),
      ][_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: '首页',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: '发现',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: '消息',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: '我的',
          ),
        ],
      ),
    );
  }
}

// 模拟数据
class MockData {
  static final List<Map<String, dynamic>> posts = [
    {
      'id': '1',
      'author': '张三',
      'avatar': null,
      'title': 'Flutter 开发体验分享',
      'content': '最近在使用 Flutter 开发移动应用，体验非常好！跨平台、性能好、开发效率高。推荐大家尝试。',
      'likes': 128,
      'comments': 32,
      'views': 1024,
      'isHot': true,
      'tags': ['Flutter', '技术'],
      'category': '技术',
      'time': '2小时前',
    },
    {
      'id': '2',
      'author': '李四',
      'avatar': null,
      'title': '今天天气真好',
      'content': '阳光明媚，适合出门散步。大家周末有什么安排吗？',
      'likes': 56,
      'comments': 18,
      'views': 320,
      'isHot': false,
      'tags': ['生活', '日常'],
      'category': '生活',
      'time': '4小时前',
    },
    {
      'id': '3',
      'author': '王五',
      'avatar': null,
      'title': '求推荐好用的代码编辑器',
      'content': '最近想换个代码编辑器，大家有什么推荐吗？主要写 Python 和 JavaScript。',
      'likes': 89,
      'comments': 45,
      'views': 560,
      'isHot': true,
      'tags': ['问答', '工具'],
      'category': '问答',
      'time': '6小时前',
    },
    {
      'id': '4',
      'author': '赵六',
      'avatar': null,
      'title': '新游戏推荐：塞尔达传说',
      'content': '刚通关塞尔达传说，游戏体验太棒了！开放世界设计精妙，剧情引人入胜。强烈推荐！',
      'likes': 234,
      'comments': 67,
      'views': 1800,
      'isHot': true,
      'tags': ['游戏', '推荐'],
      'category': '娱乐',
      'time': '8小时前',
    },
    {
      'id': '5',
      'author': '孙七',
      'avatar': null,
      'title': 'AI 技术最新进展',
      'content': '最近 GPT-4V 和 Gemini 都发布了，多模态能力越来越强。AI 领域发展速度惊人！',
      'likes': 312,
      'comments': 89,
      'views': 2400,
      'isHot': true,
      'tags': ['AI', '科技'],
      'category': '资讯',
      'time': '12小时前',
    },
  ];

  static final List<Map<String, dynamic>> categories = [
    {'id': 'all', 'name': '全部', 'icon': '📱'},
    {'id': 'tech', 'name': '技术', 'icon': '💻'},
    {'id': 'life', 'name': '生活', 'icon': '🌱'},
    {'id': 'entertainment', 'name': '娱乐', 'icon': '🎮'},
    {'id': 'question', 'name': '问答', 'icon': '❓'},
    {'id': 'news', 'name': '资讯', 'icon': '📰'},
  ];
}

// 首页 Tab
class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  String _selectedCategory = 'all';
  final Set<String> _likedPosts = {};

  List<Map<String, dynamic>> get _filteredPosts {
    if (_selectedCategory == 'all') return MockData.posts;
    return MockData.posts.where((p) => p['category'] == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('lushuaih', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              _showSearch(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('通知功能需要登录')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 分类标签
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: MockData.categories.length,
              itemBuilder: (context, index) {
                final cat = MockData.categories[index];
                final isSelected = _selectedCategory == cat['id'];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Text('${cat['icon']} ${cat['name']}'),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() {
                        _selectedCategory = cat['id'];
                      });
                    },
                    selectedColor: Theme.of(context).colorScheme.primaryContainer,
                  ),
                );
              },
            ),
          ),
          
          // 帖子列表
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredPosts.length,
              itemBuilder: (context, index) {
                return _buildPostCard(_filteredPosts[index]);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreatePost(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post) {
    final isLiked = _likedPosts.contains(post['id']);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          _showPostDetail(context, post);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 作者信息
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.primaries[post['id'].hashCode % Colors.primaries.length],
                    child: Text(
                      post['author'][0],
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(post['author'], style: const TextStyle(fontWeight: FontWeight.w600)),
                        Text(post['time'], style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                  if (post['isHot'])
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('热', style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              
              // 标题和内容
              Text(post['title'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Text(
                post['content'],
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[700], height: 1.5),
              ),
              
              // 标签
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: (post['tags'] as List).map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text('#$tag', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary)),
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 8),
              
              // 互动按钮
              Row(
                children: [
                  _buildActionButton(
                    icon: isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                    label: (post['likes'] + (isLiked ? 1 : 0)).toString(),
                    color: isLiked ? Theme.of(context).colorScheme.primary : null,
                    onTap: () {
                      setState(() {
                        if (isLiked) {
                          _likedPosts.remove(post['id']);
                        } else {
                          _likedPosts.add(post['id']);
                        }
                      });
                    },
                  ),
                  _buildActionButton(
                    icon: Icons.chat_bubble_outline,
                    label: post['comments'].toString(),
                  ),
                  _buildActionButton(
                    icon: Icons.visibility_outlined,
                    label: post['views'].toString(),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.share_outlined),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('分享功能需要登录')),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    Color? color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 12, color: color ?? Colors.grey[700])),
          ],
        ),
      ),
    );
  }

  void _showSearch(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    decoration: InputDecoration(
                      hintText: '搜索帖子...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('热门搜索', style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey[700])),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ['Flutter', 'AI', '游戏', '美食', '旅行'].map((keyword) {
                      return ActionChip(label: Text(keyword), onPressed: () {});
                    }).toList(),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showCreatePost(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            final titleController = TextEditingController();
            final contentController = TextEditingController();
            
            return Container(
              padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
                      const Text('发布帖子', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('发布功能需要登录')),
                          );
                        },
                        child: const Text('发布'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      hintText: '标题',
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  Expanded(
                    child: TextField(
                      controller: contentController,
                      decoration: const InputDecoration(
                        hintText: '分享你的想法...',
                        border: InputBorder.none,
                      ),
                      maxLines: null,
                      expands: true,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showPostDetail(BuildContext context, Map<String, dynamic> post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostDetailScreen(post: post),
      ),
    );
  }
}

// 帖子详情页
class PostDetailScreen extends StatelessWidget {
  final Map<String, dynamic> post;
  const PostDetailScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('帖子详情'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
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
                              const SnackBar(content: Text('收藏功能需要登录')),
                            );
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.share_outlined),
                          title: const Text('分享'),
                          onTap: () => Navigator.pop(context),
                        ),
                        ListTile(
                          leading: const Icon(Icons.flag_outlined),
                          title: const Text('举报'),
                          onTap: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('举报功能需要登录')),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 作者
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.primaries[post['id'].hashCode % Colors.primaries.length],
                  child: Text(post['author'][0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post['author'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      Text(post['time'], style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    ],
                  ),
                ),
                TextButton(onPressed: () {}, child: const Text('关注')),
              ],
            ),
            const SizedBox(height: 16),
            
            // 标题
            Text(post['title'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            // 内容
            Text(post['content'], style: const TextStyle(fontSize: 16, height: 1.6)),
            const SizedBox(height: 16),
            
            // 标签
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: (post['tags'] as List).map((tag) {
                return Chip(
                  label: Text('#$tag'),
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            
            // 统计
            Text(
              '${post['likes']} 赞 · ${post['comments']} 评论 · ${post['views']} 浏览',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            const Divider(height: 32),
            
            // 评论
            const Text('评论', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text('暂无评论', style: TextStyle(color: Colors.grey[600])),
                    const SizedBox(height: 4),
                    Text('来说点什么吧', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -1))],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: '写评论...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('评论功能需要登录')),
                );
              },
              icon: Icon(Icons.send, color: Theme.of(context).colorScheme.primary),
            ),
          ],
        ),
      ),
    );
  }
}

// 发现 Tab
class DiscoverTab extends StatelessWidget {
  const DiscoverTab({super.key});

  @override
  Widget build(BuildContext context) {
    final hotPosts = MockData.posts.where((p) => p['isHot'] == true).toList();
    
    return Scaffold(
      appBar: AppBar(title: const Text('发现')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 热门推荐
            const Text('🔥 热门推荐', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...hotPosts.asMap().entries.map((entry) {
              final index = entry.key;
              final post = entry.value;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: index < 3 ? [Colors.red, Colors.orange, Colors.amber][index] : Colors.blue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text('${index + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  title: Text(post['title'], maxLines: 2, overflow: TextOverflow.ellipsis),
                  subtitle: Row(
                    children: [
                      Icon(Icons.thumb_up_outlined, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text('${post['likes']}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      const SizedBox(width: 16),
                      Icon(Icons.chat_bubble_outline, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text('${post['comments']}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => PostDetailScreen(post: post)));
                  },
                ),
              );
            }),
            
            const SizedBox(height: 24),
            
            // 分类浏览
            const Text('📚 分类浏览', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: MockData.categories.skip(1).map((cat) {
                return Card(
                  child: InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(12),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(cat['icon'], style: const TextStyle(fontSize: 28)),
                          const SizedBox(height: 8),
                          Text(cat['name'], style: const TextStyle(fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 24),
            
            // 活跃用户
            const Text('⭐ 活跃用户', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 10,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.only(right: 12),
                    child: Container(
                      width: 80,
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.primaries[index % Colors.primaries.length],
                            child: const Icon(Icons.person, color: Colors.white),
                          ),
                          const SizedBox(height: 4),
                          Text('用户${index + 1}', style: const TextStyle(fontSize: 11), overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 消息 Tab
class MessagesTab extends StatelessWidget {
  const MessagesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('消息'),
        actions: [
          IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () {}),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('暂无私信', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
            const SizedBox(height: 8),
            Text('登录后可与其他用户聊天', style: TextStyle(color: Colors.grey[500])),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {},
              child: const Text('登录'),
            ),
          ],
        ),
      ),
    );
  }
}

// 我的 Tab
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的'),
        actions: [
          IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 用户信息卡片
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[300],
                      child: const Icon(Icons.person, size: 50, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    const Text('点击登录', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('登录后解锁更多功能', style: TextStyle(color: Colors.grey[600])),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatItem('帖子', 0),
                        _buildStatItem('关注', 0),
                        _buildStatItem('粉丝', 0),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        child: const Text('登录 / 注册'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // 功能列表
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.article_outlined),
                    title: const Text('我的帖子'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.bookmark_outline),
                    title: const Text('我的收藏'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.history),
                    title: const Text('浏览历史'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.dark_mode_outlined),
                    title: const Text('深色模式'),
                    trailing: Switch(value: false, onChanged: (_) {}),
                  ),
                  ListTile(
                    leading: const Icon(Icons.language),
                    title: const Text('语言设置'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.help_outline),
                    title: const Text('帮助与反馈'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text('关于 lushuaih'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'lushuaih',
                        applicationVersion: '1.0.0',
                        applicationLegalese: '© 2024 lushuaih Team',
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int count) {
    return Column(
      children: [
        Text(count.toString(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}
