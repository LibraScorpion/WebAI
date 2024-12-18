import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/message_model.dart';

class MessageRepository {
  static Database? _database;
  static const String tableName = 'messages';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'messages.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tableName(
            id TEXT PRIMARY KEY,
            content TEXT,
            type TEXT,
            timestamp TEXT,
            sender_id TEXT,
            is_ai INTEGER,
            metadata TEXT
          )
        ''');
      },
    );
  }

  Future<void> insertMessage(Message message) async {
    final db = await database;
    await db.insert(
      tableName,
      {
        'id': message.id,
        'content': message.content,
        'type': message.type.toString(),
        'timestamp': message.timestamp.toIso8601String(),
        'sender_id': message.senderId,
        'is_ai': message.isAI ? 1 : 0,
        'metadata': message.metadata?.toString(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Message>> getMessages({
    int offset = 0,
    int limit = 20,
  }) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      orderBy: 'timestamp DESC',
      limit: limit,
      offset: offset,
    );

    return List.generate(maps.length, (i) {
      return Message(
        id: maps[i]['id'] as String,
        content: maps[i]['content'] as String,
        type: MessageType.values.firstWhere(
          (e) => e.toString() == maps[i]['type'] as String,
        ),
        timestamp: DateTime.parse(maps[i]['timestamp'] as String),
        senderId: maps[i]['sender_id'] as String,
        isAI: maps[i]['is_ai'] == 1,
        metadata: maps[i]['metadata'] != null
            ? {} // Parse metadata if needed
            : null,
      );
    });
  }

  Future<int> getMessageCount() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $tableName',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> deleteAllMessages() async {
    final db = await database;
    await db.delete(tableName);
  }

  Future<List<Message>> searchMessages(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'content LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'timestamp DESC',
    );

    return List.generate(maps.length, (i) {
      return Message(
        id: maps[i]['id'] as String,
        content: maps[i]['content'] as String,
        type: MessageType.values.firstWhere(
          (e) => e.toString() == maps[i]['type'] as String,
        ),
        timestamp: DateTime.parse(maps[i]['timestamp'] as String),
        senderId: maps[i]['sender_id'] as String,
        isAI: maps[i]['is_ai'] == 1,
        metadata: maps[i]['metadata'] != null
            ? {} // Parse metadata if needed
            : null,
      );
    });
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
