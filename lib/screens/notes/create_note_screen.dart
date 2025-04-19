import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:meleto/models/db_helper.dart';
import 'package:meleto/models/note.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class CreateNoteScreen extends StatefulWidget {
  const CreateNoteScreen({super.key});

  @override
  State<CreateNoteScreen> createState() => _CreateNoteScreenState();
}

class _CreateNoteScreenState extends State<CreateNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagController = TextEditingController();
  final List<String> _tags = [];
  bool _isPublic = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
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

  Future<void> _saveNote() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // 实现保存笔记的逻辑，比如API调用
        final dbHelper = DatabaseHelper.instance;
        final prefs = await SharedPreferences.getInstance();
        final String authorId = prefs.getString("userid") ?? "";
        final String authorName = prefs.getString("username") ?? "";
        final now = DateTime.now();
        final note = Note(
          id: '', // ID会在保存时生成
          title: _titleController.text,
          content: _contentController.text,
          authorId: authorId,
          authorName: authorName,
          createdAt: now,
          updatedAt: now,
          tags: List<String>.from(_tags),
          likes: 0,
          isPublic: _isPublic,
        );

        await dbHelper.saveNote(note);

        final resp = await http.post(
          Uri.parse("http://10.0.2.2:8080/api/note/create"),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${prefs.getString('token')}',
          },
          body: json.encode({
            'title': note.title,
            'content': note.content,
            'isPublic': note.isPublic,
          }),
        );

        if (resp.statusCode != 200) {
          throw Exception('Failed to create note');
        }
        // await Future.delayed(const Duration(seconds: 2)); // 模拟网络请求

        if (!mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('笔记发布成功！')));

        Navigator.pop(context, true); // 返回并传递成功状态
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('发布失败: ${e.toString()}')));

        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('创建笔记'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveNote,
            child:
                _isLoading
                    ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Text('发布'),
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
                IconButton(icon: const Icon(Icons.add), onPressed: _addTag),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children:
                  _tags.map((tag) {
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
