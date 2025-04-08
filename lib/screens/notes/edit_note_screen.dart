import 'package:flutter/material.dart';
import 'package:meleto/models/note.dart';

class EditNoteScreen extends StatefulWidget {
  final String noteId;
  
  const EditNoteScreen({
    super.key,
    required this.noteId,
  });

  @override
  State<EditNoteScreen> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagController = TextEditingController();
  List<String> _tags = [];
  bool _isPublic = true;
  bool _isLoading = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadNoteData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _loadNoteData() async {
    setState(() => _isLoading = true);
    
    try {
      // 模拟从API获取笔记数据
      await Future.delayed(const Duration(seconds: 1));
      
      final note = Note(
        id: widget.noteId,
        title: 'Flutter 基础知识详解',
        content: '# Flutter简介\n\nFlutter是Google开发的开源UI工具包，可以仅通过一套代码库构建美观、原生的跨平台应用。\n\n## 为什么选择Flutter?\n\n* 快速开发\n* 表现力强且灵活的UI\n* 原生性能\n\n## Flutter架构\n\nFlutter包含几个关键部分：\n\n1. Dart平台\n2. Flutter引擎\n3. Foundation库\n4. 设计特定的widget\n\n## 开始使用Flutter\n\n```dart\nvoid main() {\n  runApp(MyApp());\n}\n\nclass MyApp extends StatelessWidget {\n  @override\n  Widget build(BuildContext context) {\n    return MaterialApp(\n      home: Scaffold(\n        appBar: AppBar(title: Text(\'Hello Flutter\')),\n        body: Center(child: Text(\'Hello World\')),\n      ),\n    );\n  }\n}\n```',
        authorId: 'user1',
        authorName: '张三',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        tags: ['Flutter', '移动开发', '教程'],
        likes: 28,
      );
      
      if (!mounted) return;
      
      setState(() {
        _titleController.text = note.title;
        _contentController.text = note.content;
        _tags = List.from(note.tags);
        _isLoading = false;
        _isInitialized = true;
      });
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('加载失败: ${e.toString()}')),
      );
      
      setState(() => _isLoading = false);
    }
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  Future<void> _updateNote() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        // 实现更新笔记的逻辑，比如API调用
        await Future.delayed(const Duration(seconds: 2)); // 模拟网络请求
        
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('笔记更新成功！')),
        );
        
        Navigator.pop(context, true); // 返回并传递成功状态
      } catch (e) {
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('更新失败: ${e.toString()}')),
        );
        
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized && _isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('编辑笔记')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑笔记'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _updateNote,
            child: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('保存'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: '标题',
                hintText: '请输入笔记标题',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入标题';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: '内容',
                hintText: '请输入笔记内容',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 15,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入内容';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tagController,
                    decoration: const InputDecoration(
                      labelText: '标签',
                      hintText: '添加标签',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addTag(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addTag,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _tags.map((tag) {
                return Chip(
                  label: Text(tag),
                  onDeleted: () => _removeTag(tag),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('公开笔记'),
              subtitle: const Text('允许其他用户查看和评价您的笔记'),
              value: _isPublic,
              onChanged: (value) {
                setState(() {
                  _isPublic = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}