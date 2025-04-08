import 'package:flutter/material.dart';
import 'package:meleto/models/note.dart';
import 'package:meleto/screens/auth/login_screen.dart';
import 'package:meleto/screens/notes/note_detail_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  
  // 模拟用户数据
  final Map<String, dynamic> _userData = {
    'username': '弗拉特',
    'email': 'dev@whut.edu.cn',
    'avatar': 'assets/images/opti.png',
    'bio': '一个麻瓜',
    'joinDate': '2023-01-15',
  };
  
  // 模拟用户笔记列表
  final List<Note> _userNotes = [
    Note(
      id: '1',
      title: 'Flutter 基础知识',
      content: 'Flutter是Google开发的UI工具包...',
      authorId: 'user1',
      authorName: '张三',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      tags: ['Flutter', '移动开发'],
      likes: 15,
    ),
    Note(
      id: '2',
      title: 'Dart语言入门',
      content: 'Dart是Google开发的计算机编程语言...',
      authorId: 'user1',
      authorName: '张三',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      tags: ['Dart', '编程语言'],
      likes: 23,
    ),
  ];
  
  // 模拟收藏的笔记
  final List<Note> _favoriteNotes = [
    Note(
      id: '3',
      title: 'React Native vs Flutter',
      content: '本文对比了React Native和Flutter...',
      authorId: 'user3',
      authorName: '王五',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      tags: ['Flutter', 'React Native', '对比'],
      likes: 42,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('退出登录'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('确定'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      setState(() => _isLoading = true);
      
      try {
        // 模拟退出登录
        await Future.delayed(const Duration(seconds: 1));
        
        if (!mounted) return;
        
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      } catch (e) {
        if (!mounted) return;
        
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('退出失败: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('个人中心'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // 打开设置页面
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '我的笔记'),
            Tab(text: '收藏'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverToBoxAdapter(
                    child: _buildProfileHeader(),
                  ),
                ];
              },
              body: TabBarView(
                controller: _tabController,
                children: [
                  _buildNotesList(_userNotes, isUserNotes: true),
                  _buildNotesList(_favoriteNotes),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            // backgroundImage: NetworkImage(_userData['avatar']),
            backgroundImage: AssetImage(_userData['avatar']),
          ),
          const SizedBox(height: 16),
          Text(
            _userData['username'],
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            _userData['email'],
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _userData['bio'],
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  Text(
                    '${_userNotes.length}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Text('笔记'),
                ],
              ),
              const SizedBox(width: 32),
              Column(
                children: [
                  Text(
                    '${_favoriteNotes.length}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Text('收藏'),
                ],
              ),
              const SizedBox(width: 32),
              Column(
                children: [
                  Text(
                    '38',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Text('获赞'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: _logout,
            child: const Text('退出登录'),
          ),
          const Divider(height: 32),
        ],
      ),
    );
  }

  Widget _buildNotesList(List<Note> notes, {bool isUserNotes = false}) {
    if (notes.isEmpty) {
      return Center(
        child: Text(isUserNotes ? '还没有创建笔记' : '还没有收藏笔记'),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NoteDetailScreen(noteId: note.id),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          note.title,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isUserNotes)
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              // 编辑笔记
                            } else if (value == 'delete') {
                              // 删除笔记
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('编辑'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('删除'),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    note.content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.thumb_up, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text('${note.likes}'),
                      const Spacer(),
                      Text(
                        _formatDate(note.createdAt),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }
}// TODO Implement this library.
