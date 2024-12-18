import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/message_model.dart';
import '../../models/image_model.dart';

class DatabaseService {
  static Database? _database;
  static const String messagesTable = 'messages';
  static const String imagesTable = 'generated_images';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'webai.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Create messages table
        await db.execute('''
          CREATE TABLE $messagesTable(
            id TEXT PRIMARY KEY,
            content TEXT,
            type TEXT,
            timestamp TEXT,
            sender_id TEXT,
            is_ai INTEGER,
            metadata TEXT
          )
        ''');

        // Create generated images table
        await db.execute('''
          CREATE TABLE $imagesTable(
            id TEXT PRIMARY KEY,
            prompt TEXT,
            image_url TEXT,
            local_path TEXT,
            timestamp TEXT,
            metadata TEXT
          )
        ''');
      },
    );
  }

  // Message Operations
  Future<List<Message>> getMessages({
    int offset = 0,
    int limit = 20,
    String? searchQuery,
  }) async {
    final db = await database;
    String query = 'SELECT * FROM $messagesTable';
    List<dynamic> args = [];

    if (searchQuery != null && searchQuery.isNotEmpty) {
      query += ' WHERE content LIKE ?';
      args.add('%$searchQuery%');
    }

    query += ' ORDER BY timestamp DESC LIMIT ? OFFSET ?';
    args.addAll([limit, offset]);

    final List<Map<String, dynamic>> maps = await db.rawQuery(query, args);

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

  Future<void> insertMessage(Message message) async {
    final db = await database;
    await db.insert(
      messagesTable,
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

  Future<void> deleteMessage(String id) async {
    final db = await database;
    await db.delete(
      messagesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAllMessages() async {
    final db = await database;
    await db.delete(messagesTable);
  }

  // Generated Image Operations
  Future<List<GeneratedImage>> getGeneratedImages({
    int offset = 0,
    int limit = 20,
  }) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      imagesTable,
      orderBy: 'timestamp DESC',
      limit: limit,
      offset: offset,
    );

    return List.generate(maps.length, (i) {
      return GeneratedImage(
        id: maps[i]['id'] as String,
        prompt: maps[i]['prompt'] as String,
        imageUrl: maps[i]['image_url'] as String,
        localPath: maps[i]['local_path'] as String?,
        timestamp: DateTime.parse(maps[i]['timestamp'] as String),
        metadata: maps[i]['metadata'] != null
            ? {} // Parse metadata if needed
            : null,
      );
    });
  }

  Future<void> insertGeneratedImage(GeneratedImage image) async {
    final db = await database;
    await db.insert(
      imagesTable,
      {
        'id': image.id,
        'prompt': image.prompt,
        'image_url': image.imageUrl,
        'local_path': image.localPath,
        'timestamp': image.timestamp.toIso8601String(),
        'metadata': image.metadata?.toString(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteGeneratedImage(String id) async {
    final db = await database;
    await db.delete(
      imagesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAllGeneratedImages() async {
    final db = await database;
    await db.delete(imagesTable);
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
