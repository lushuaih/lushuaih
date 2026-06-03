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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
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

// 首页
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final posts = [
      {
        'author': '张三',
        'title': 'Flutter开发体验分享',
        'content': '最近在使用Flutter开发移动应用，体验非常好！跨平台、性能好、开发效率高。',
        'likes': 128,
        'comments': 32,
        'isHot': true,
      },
      {
        'author': '李四',
        'title': '今天天气真好',
        'content': '阳光明媚，适合出门散步。大家周末有什么安排吗？',
        'likes': 56,
        'comments': 18,
        'isHot': false,
      },
      {
        'author': '王五',
        'title': '求推荐代码编辑器',
        'content': '最近想换个代码编辑器，大家有什么推荐吗？主要写Python和JavaScript。',
        'likes': 89,
        'comments': 45,
        'isHot': true,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('lushuaih', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('查看: ${post['title']}')),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.primaries[index % Colors.primaries.length],
                          child: Text(
                            (post['author'] as String)[0],
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          post['author'] as String,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
                        if (post['isHot'] == true)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('热', style: TextStyle(color: Colors.red, fontSize: 12)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      post['title'] as String,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      post['content'] as String,
                      style: TextStyle(color: Colors.grey[700]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.thumb_up_outlined, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text('${post['likes']}', style: TextStyle(color: Colors.grey[600])),
                        const SizedBox(width: 16),
                        Icon(Icons.chat_bubble_outline, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text('${post['comments']}', style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('发布功能演示版暂不可用')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// 发现页
class DiscoverTab extends StatelessWidget {
  const DiscoverTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('发现')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.explore_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('发现页面', style: TextStyle(fontSize: 18, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

// 消息页
class MessagesTab extends StatelessWidget {
  const MessagesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('消息')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('暂无私信', style: TextStyle(fontSize: 18, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

// 我的页
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 50),
            ),
            const SizedBox(height: 16),
            const Text('lushuaih', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('演示版本', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('登录功能演示版暂不可用')),
                );
              },
              child: const Text('登录 / 注册'),
            ),
          ],
        ),
      ),
    );
  }
}
