import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static Database? _database;

  // Метод для отримання доступу до бази даних
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    // Якщо база даних ще не створена, створюємо нову
    _database = await _initDatabase();
    return _database!;
  }

  // Ініціалізація бази даних
  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'notes.db'); // Шлях до бази даних
    return await openDatabase(path, onCreate: (db, version) {
      // Створення таблиці для нотаток
      return db.execute(
        "CREATE TABLE notes(id INTEGER PRIMARY KEY AUTOINCREMENT, content TEXT, createdAt TEXT)",
      );
    }, version: 1);
  }

  // Метод для додавання нотатки
  Future<void> insertNote(Note note) async {
    final db = await database;
    await db.insert(
      'notes',
      note.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Метод для отримання всіх нотаток
  Future<List<Note>> getNotes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('notes', orderBy: 'createdAt DESC');
    return List.generate(maps.length, (i) {
      return Note.fromMap(maps[i]);
    });
  }
}

class Note {
  final int? id;
  final String content;
  final DateTime createdAt;

  Note({this.id, required this.content, required this.createdAt});

  // Перетворення об'єкта Note на карту (для збереження в БД)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'createdAt': createdAt.toIso8601String(),  // Перетворення в String
    };
  }

  // Перетворення карти на об'єкт Note
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      content: map['content'],
      createdAt: DateTime.parse(map['createdAt']),  // Перетворення з String в DateTime
    );
  }
}
