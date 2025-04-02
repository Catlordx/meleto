import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

/// 应用程序数据库服务类
/// 负责管理SQLite数据库连接和表结构
class AppDatabase {
  /// 单例实例
  static final AppDatabase instance = AppDatabase._init();
  
  /// 数据库连接缓存
  static Database? _database;

  /// 私有构造函数，实现单例模式
  AppDatabase._init();

  /// 获取数据库连接实例
  /// 如果数据库未初始化，则先初始化再返回
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('notes.db');
    return _database!;
  }

  /// 初始化数据库
  /// @param filePath 数据库文件名
  /// @return 初始化后的数据库实例
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onConfigure: (db) async => await db.execute('PRAGMA foreign_keys = ON'), // 启用外键约束
    );
  }

  /// 创建数据库表结构
  /// 在数据库首次创建时调用
  Future _createDB(Database db, int version) async {
    // 用户表：存储用户账号信息
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // 笔记表：存储用户创建的笔记内容
    await db.execute('''
      CREATE TABLE notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        author_id INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (author_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // 评论表：存储用户对笔记的评价
    await db.execute('''
      CREATE TABLE reviews (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        note_id INTEGER NOT NULL,
        user_id INTEGER NOT NULL,
        rating INTEGER CHECK(rating BETWEEN 1 AND 5),
        comment TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (note_id) REFERENCES notes (id) ON DELETE CASCADE,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');
  }
}