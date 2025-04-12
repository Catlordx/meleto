import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
  List<Note> _notes = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _selectedIndex = 0;
  
  @override
  void initState() {
    super.initState();
    _fetchNotes();
  }
  
  Future<void> _fetchNotes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8080/api/note/getall?sort=rating&page=1')
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final notesList = (data['data'] as List)
            .map((noteJson) => Note.fromJson(noteJson))
            .toList();
            
        setState(() {
          _notes = notesList;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load notes: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
      print('Error fetching notes: $e');
    }
  }

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
      body: _buildBody(),
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
          
          if (index == 2) { // 个人资料页
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          }
        },
        items: const [
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
  
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('加载失败: $_errorMessage'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchNotes,
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _fetchNotes,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _notes.length,
        itemBuilder: (context, index) {
          final note = _notes[index];
          return _buildNoteCard(note);
        },
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
                    child: Text(note.authorName.isNotEmpty ? note.authorName[0] : ''),
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
              if (note.tags.isNotEmpty)
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