// TODO Other functions like share, delete, edit haven't been implemented yet
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:meleto/models/note.dart';
// import 'package:meleto/models/review.dart';
import 'package:meleto/screens/notes/edit_note_screen.dart';

class NoteDetailScreen extends StatefulWidget {
  final String noteId;

  const NoteDetailScreen({super.key, required this.noteId});

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  late Future<Note> _noteFuture;
  final _reviewController = TextEditingController();
  int _userRating = 0;
  bool _isReviewExpanded = false;

  @override
  void initState() {
    super.initState();
    _noteFuture = _fetchNote();
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<Note> _fetchNote() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8080/api/note/getbyid?id=${widget.noteId}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Note.fromJson(data);
      } else {
        throw Exception('Failed to load note: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback to mock data for development

      // Mock data for development
      return Note(
        id: widget.noteId,
        title: 'Flutter 基础知识详解',
        content: '# Flutter简介\n\nFlutter是Google开发的开源UI工具包...',
        authorId: '1',
        authorName: '张三',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        tags: ['Flutter', '移动开发', '教程'],
        likes: 28,
        reviews: [
          Review(
            id: 1,
            rating: 5,
            comment: '非常详细的Flutter入门教程，对我帮助很大！',
            userId: 2,
            noteId: int.parse(widget.noteId),
            createdAt: DateTime.now().subtract(const Duration(days: 1)),
            userName: '李四',
          ),
          Review(
            id: 2,
            rating: 4,
            comment: '内容不错，但希望能有更多代码示例。',
            userId: 3,
            noteId: int.parse(widget.noteId),
            createdAt: DateTime.now().subtract(const Duration(hours: 5)),
            userName: '王五',
          ),
        ],
      );
    }
  }

  Future<void> _submitReview() async {
    if (_reviewController.text.isEmpty || _userRating == 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请输入评论内容并选择评分')));
      return;
    }

    // 实现提交评论的逻辑
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/api/review'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'noteId': widget.noteId,
          'rating': _userRating,
          'comment': _reviewController.text,
          // Add user authentication token here
        }),
      );

      if (!mounted) return;
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('评论发布成功')));

        setState(() {
          _reviewController.clear();
          _userRating = 0;
          _isReviewExpanded = false;
        });

        _noteFuture = _fetchNote(); // 刷新笔记数据
      } else {
        throw Exception('Failed to submit review: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('评论发布失败: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('笔记详情'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final note = await _noteFuture;
              if (!mounted) return;

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => EditNoteScreen(
                        noteId: widget.noteId,
                        noteAuthorId: note.authorId,
                        noteContent: note.content,
                        noteTitle: note.title,
                        isPublic: note.isPublic,
                      ),
                ),
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') {
                _showDeleteConfirmation();
              } else if (value == 'share') {
                // 实现分享功能
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(value: 'share', child: Text('分享')),
                  const PopupMenuItem(value: 'delete', child: Text('删除')),
                ],
          ),
        ],
      ),
      body: FutureBuilder<Note>(
        future: _noteFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('加载失败: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('找不到笔记'));
          }

          final note = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note.title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      child: Text(
                        note.authorName.isNotEmpty ? note.authorName[0] : '?',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(note.authorName),
                    const Spacer(),
                    Text(_formatDate(note.createdAt)),
                  ],
                ),
                const SizedBox(height: 8),
                if (note.tags.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    children:
                        note.tags.map((tag) {
                          return Chip(
                            label: Text(tag),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            padding: EdgeInsets.zero,
                            labelPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                            ),
                          );
                        }).toList(),
                  ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                Text(
                  note.content,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.thumb_up_outlined),
                      onPressed: () {
                        // 实现点赞功能
                      },
                    ),
                    Text('${note.likes}'),
                    const Spacer(),
                    TextButton.icon(
                      icon: const Icon(Icons.rate_review),
                      label: const Text('写评论'),
                      onPressed: () {
                        setState(() {
                          _isReviewExpanded = !_isReviewExpanded;
                        });
                      },
                    ),
                  ],
                ),
                if (_isReviewExpanded) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < _userRating ? Icons.star : Icons.star_border,
                          color: index < _userRating ? Colors.amber : null,
                        ),
                        onPressed: () {
                          setState(() {
                            _userRating = index + 1;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _reviewController,
                    decoration: const InputDecoration(
                      hintText: '写下您的评论...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _submitReview,
                    child: const Text('提交评论'),
                  ),
                ],
                const SizedBox(height: 24),
                if (note.reviews != null && note.reviews!.isNotEmpty) ...[
                  Text(
                    '评论 (${note.reviews!.length})',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  ...note.reviews!.map((review) => _buildReviewCard(review)),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildReviewCard(Review review) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  child: Text(
                    review.userName.isNotEmpty ? review.userName[0] : '?',
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  review.userName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < review.rating ? Icons.star : Icons.star_border,
                      color: index < review.rating ? Colors.amber : null,
                      size: 16,
                    );
                  }),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(review.comment),
            const SizedBox(height: 4),
            Text(
              _formatDate(review.createdAt),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('删除笔记'),
            content: const Text('确定要删除这篇笔记吗？此操作不可撤销。'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    await http.delete(
                      Uri.parse(
                        'http://localhost:8080/api/note/${widget.noteId}',
                      ),
                      // Add authentication headers here
                    );

                    if (!mounted) return;
                    Navigator.of(context).pop();
                    Navigator.of(context).pop(); // 返回上一页
                  } catch (e) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('删除失败: $e')));
                  }
                },
                child: const Text('删除'),
              ),
            ],
          ),
    );
  }
}
