import 'package:flutter/material.dart';
import 'package:meleto/models/note.dart';
import 'package:meleto/screens/notes/note_detail_screen.dart';
import 'package:meleto/screens/notes/create_note_screen.dart';
import 'package:meleto/screens/search_screen.dart';
import 'package:meleto/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Note> _notes = [
    Note(
      id: '1',
      title: 'Flutter 基础知识',
      content: 'Flutter是Google开发的UI工具包，可以使用一套代码库构建多平台应用...',
      authorId: 'user1',
      authorName: '张三',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      tags: ['Flutter', '移动开发'],
      likes: 15,
    ),
    Note(
      id: '2',
      title: 'Dart语言入门',
      content: 'Dart是Google开发的计算机编程语言，可以用于web、服务器、移动应用和物联网等领域的开发...',
      authorId: 'user2',
      authorName: '李四',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      tags: ['Dart', '编程语言'],
      likes: 23,
    ),
    Note(
      id: '3',
      title: 'React Native vs Flutter',
      content: '本文对比了React Native和Flutter在性能、开发效率和社区支持等方面的差异...',
      authorId: 'user3',
      authorName: '王五',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      tags: ['Flutter', 'React Native', '对比'],
      likes: 42,
    ),
  ];

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meleto学习笔记'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // 实现下拉刷新逻辑
          await Future.delayed(const Duration(seconds: 1));
          // setState(() {
          //   // 刷新数据
          // });
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _notes.length,
          itemBuilder: (context, index) {
            final note = _notes[index];
            return _buildNoteCard(note);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateNoteScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          
          // 实现底部导航栏切换逻辑
          if (index == 2) { // 个人资料页
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '首页',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: '收藏',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '我的',
          ),
        ],
      ),
    );
  }

  Widget _buildNoteCard(Note note) {
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
              Text(
                note.title,
                style: Theme.of(context).textTheme.titleLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                note.content,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    child: Text(note.authorName[0]),
                  ),
                  const SizedBox(width: 8),
                  Text(note.authorName),
                  const Spacer(),
                  const Icon(Icons.thumb_up, size: 16),
                  const SizedBox(width: 4),
                  Text('${note.likes}'),
                  const SizedBox(width: 16),
                  Text(
                    _formatDate(note.createdAt),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: note.tags.map((tag) {
                  return Chip(
                    label: Text(tag),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: EdgeInsets.zero,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }
}