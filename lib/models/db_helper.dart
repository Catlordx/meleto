import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:meleto/models/note.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static DatabaseHelper get instance => _instance;
  
  static Database? _database;
  
  DatabaseHelper._internal();
  
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }
  
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'meleto_notes.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
    );
  }
  
  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notes(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        authorId TEXT NOT NULL,
        authorName TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        isPublic INTEGER NOT NULL,
        likes INTEGER DEFAULT 0
      )
    ''');
    
    await db.execute('''
      CREATE TABLE tags(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        noteId TEXT NOT NULL,
        name TEXT NOT NULL,
        FOREIGN KEY (noteId) REFERENCES notes (id) ON DELETE CASCADE
      )
    ''');
  }
  
  // 保存笔记
  Future<String> saveNote(Note note) async {
    final db = await database;
    
    // 生成唯一ID
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    
    await db.insert('notes', {
      'id': id,
      'title': note.title,
      'content': note.content,
      'authorId': note.authorId,
      'authorName': note.authorName,
      'createdAt': note.createdAt.toIso8601String(),
      'updatedAt': note.updatedAt.toIso8601String(),
      'isPublic': note.isPublic ? 1 : 0,
      'likes': note.likes,
    });
    
    // 保存标签
    for (String tag in note.tags) {
      await db.insert('tags', {
        'noteId': id,
        'name': tag,
      });
    }
    
    return id;
  }
  
  // 获取所有笔记
  Future<List<Note>> getAllNotes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('notes');
    
    return Future.wait(maps.map((map) async {
      List<Map<String, dynamic>> tagMaps = await db.query(
        'tags',
        where: 'noteId = ?',
        whereArgs: [map['id']],
      );
      
      List<String> tags = tagMaps.map((tag) => tag['name'] as String).toList();
      
      return Note(
        id: map['id'],
        title: map['title'],
        content: map['content'],
        authorId: map['authorId'],
        authorName: map['authorName'],
        createdAt: DateTime.parse(map['createdAt']),
        updatedAt: DateTime.parse(map['updatedAt']),
        isPublic: map['isPublic'] == 1,
        tags: tags,
        likes: map['likes'],
      );
    }).toList());
  }
}