import 'package:flutter/material.dart';
import 'package:meleto/models/note.dart';
import 'package:meleto/screens/notes/note_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  bool _isSearching = false;
  List<Note>? _searchResults;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = null;
        _isSearching = false;
      });
      return;
    }
    
    setState(() => _isSearching = true);
    
    try {
      // 模拟搜索API调用
      await Future.delayed(const Duration(seconds: 1));
      
      // 示例搜索结果
      final results = [
        Note(
          id: '1',
          title: 'Flutter 基础知识',
          content: 'Flutter是Google开发的UI工具包...',
          authorId: 'user1',
          authorName: '张三',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          tags: ['Flutter', '移动开发'],
          likes: 15,
        ),
        Note(
          id: '4',
          title: 'Flutter Widget详解',
          content: 'Widget是Flutter应用的基本构建块...',
          authorId: 'user2',
          authorName: '李四',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          tags: ['Flutter', 'Widget'],
          likes: 8,
        ),
      ];
      
      if (!mounted) return;
      
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      if (!mounted) return;
      
      setState(() => _isSearching = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('搜索失败: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: '搜索笔记...',
            border: InputBorder.none,
          ),
          autofocus: true,
          onSubmitted: _performSearch,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _performSearch(_searchController.text),
          ),
        ],
      ),
      body: _buildSearchResults(),
    );
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_searchResults == null) {
      return const Center(
        child: Text('输入关键词搜索笔记'),
      );
    }
    
    if (_searchResults!.isEmpty) {
      return const Center(
        child: Text('没有找到匹配的笔记'),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults!.length,
      itemBuilder: (context, index) {
        final note = _searchResults![index];
        return _buildNoteCard(note);
      },
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
}