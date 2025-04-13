import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:meleto/models/note.dart';
import 'package:meleto/screens/notes/note_detail_screen.dart';
import 'package:meleto/screens/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  // 模拟用户数据
  Map<String, dynamic> _userData = {
    'username': '弗拉特',
    'email': 'dev@whut.edu.cn',
    'avatar': 'assets/images/opti.png',
    'bio': '一个麻瓜',
    'joinDate': '2023-01-15',
  };

  // 模拟用户笔记列表
  List<Note> _userNotes = [
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
    _loadUserData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final resp = await http.get(
        Uri.parse(
          "http://10.0.2.2:8080/api/note/getbyuser?id=${prefs.getString("userid")}",
        ),
      );
      setState(() {
        _userData = {
          'username': prefs.getString('username') ?? '未知用户',
          'email': prefs.getString('email') ?? '未知邮箱',
          'avatar': 'assets/images/opti.png', // 保持默认头像
          'bio': '一个麻瓜',
          'joinDate': '2023-01-15',
        };
        final data = json.decode(resp.body);
        _userNotes =
            (data['data'] as List)
                .map((noteJson) => Note.fromJson(noteJson))
                .toList();
        _isLoading = false;
      });
    } catch (e) {
      print('加载用户数据失败: $e');
      setState(() {
        _isLoading = false;
      });
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
              // 打开设置页面
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: '我的笔记'), Tab(text: '收藏')],
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [SliverToBoxAdapter(child: _buildProfileHeader())];
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
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            _userData['email'],
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(_userData['bio'], textAlign: TextAlign.center),
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
                  Text('38', style: Theme.of(context).textTheme.titleMedium),
                  const Text('获赞'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          const Divider(height: 32),
        ],
      ),
    );
  }

  Widget _buildNotesList(List<Note> notes, {bool isUserNotes = false}) {
    if (notes.isEmpty) {
      return Center(child: Text(isUserNotes ? '还没有创建笔记' : '还没有收藏笔记'));
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
                          itemBuilder:
                              (context) => [
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
} // TODO Implement this library.
