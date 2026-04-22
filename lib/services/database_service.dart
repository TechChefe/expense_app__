// lib/services/database_service.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/category.dart';
import '../models/expense.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'expense_app.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    // Categories table
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT
      )
    ''');

    // Expenses table
    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        description TEXT,
        amount REAL NOT NULL,
        category_id INTEGER NOT NULL,
        date_time TEXT NOT NULL,
        latitude REAL,
        longitude REAL,
        location_name TEXT,
        FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE CASCADE
      )
    ''');

    // Seed with sample data on first creation
    await _seedData(db);
  }

  // ── Seed Data ─────────────────────────────────────────────────────────────
  // Inserts sample categories and expenses so the app has demo content
  // on first launch. This runs only once when the DB is first created.

  Future<void> _seedData(Database db) async {
    final now = DateTime.now();

    // ── Insert categories ──────────────────────────────────────────────────
    await db.insert('categories', {
      'name': 'Σούπερ Μάρκετ',
      'description': 'Εβδομαδιαίες αγορές τροφίμων και είδη σπιτιού',
    });
    await db.insert('categories', {
      'name': 'Μεταφορές',
      'description': 'Καύσιμα, εισιτήρια, taxi και κόστος μετακίνησης',
    });
    await db.insert('categories', {
      'name': 'Εστίαση',
      'description': 'Εστιατόρια, καφετέριες και delivery φαγητού',
    });
    await db.insert('categories', {
      'name': 'Λογαριασμοί',
      'description': 'ΔΕΗ, νερό, τηλέφωνο, internet και ενοίκιο',
    });
    await db.insert('categories', {
      'name': 'Ψυχαγωγία',
      'description': 'Κινηματογράφος, συναυλίες, streaming και χόμπι',
    });
    await db.insert('categories', {
      'name': 'Υγεία',
      'description': 'Φαρμακείο, γιατροί και εξετάσεις',
    });
    await db.insert('categories', {
      'name': 'Ένδυση',
      'description': 'Ρούχα, παπούτσια και αξεσουάρ',
    });

    // Category IDs are 1–7 in insertion order

    // ── Insert expenses ────────────────────────────────────────────────────
    // Helper to build a date relative to today
    String daysAgo(int days, {int hour = 12, int minute = 0}) =>
        DateTime(now.year, now.month, now.day - days, hour, minute)
            .toIso8601String();

    // Σούπερ Μάρκετ (category_id = 1)
    await db.insert('expenses', {
      'description': 'Εβδομαδιαία αγορά Sklavenitis',
      'amount': 87.50,
      'category_id': 1,
      'date_time': daysAgo(1, hour: 11, minute: 30),
      'latitude': 40.6401,
      'longitude': 22.9444,
      'location_name': 'Sklavenitis Καλαμαριά',
    });
    await db.insert('expenses', {
      'description': 'Αγορά φρούτων και λαχανικών',
      'amount': 23.40,
      'category_id': 1,
      'date_time': daysAgo(5, hour: 10, minute: 15),
      'latitude': 40.6361,
      'longitude': 22.9385,
      'location_name': 'Λαϊκή Αγορά',
    });

    // Μεταφορές (category_id = 2)
    await db.insert('expenses', {
      'description': 'Βενζίνη αυτοκινήτου',
      'amount': 55.00,
      'category_id': 2,
      'date_time': daysAgo(2, hour: 9, minute: 0),
      'latitude': 40.6486,
      'longitude': 22.9553,
      'location_name': 'BP Πανόραμα',
    });
    await db.insert('expenses', {
      'description': 'Μηνιαία κάρτα ΟΑΣΘ',
      'amount': 30.00,
      'category_id': 2,
      'date_time': daysAgo(7, hour: 8, minute: 45),
      'latitude': null,
      'longitude': null,
      'location_name': null,
    });

    // Εστίαση (category_id = 3)
    await db.insert('expenses', {
      'description': 'Γεύμα με συναδέλφους',
      'amount': 42.50,
      'category_id': 3,
      'date_time': daysAgo(3, hour: 14, minute: 0),
      'latitude': 40.6333,
      'longitude': 22.9408,
      'location_name': 'The Food Company',
    });
    await db.insert('expenses', {
      'description': 'Καφές και σνακ',
      'amount': 8.60,
      'category_id': 3,
      'date_time': daysAgo(0, hour: 9, minute: 30),
      'latitude': 40.6300,
      'longitude': 22.9450,
      'location_name': 'Mikel Coffee',
    });

    // Λογαριασμοί (category_id = 4)
    await db.insert('expenses', {
      'description': 'ΔΕΗ Απριλίου',
      'amount': 112.00,
      'category_id': 4,
      'date_time': daysAgo(10, hour: 10, minute: 0),
      'latitude': null,
      'longitude': null,
      'location_name': null,
    });
    await db.insert('expenses', {
      'description': 'Συνδρομή Netflix',
      'amount': 13.99,
      'category_id': 5,
      'date_time': daysAgo(4, hour: 0, minute: 0),
      'latitude': null,
      'longitude': null,
      'location_name': null,
    });

    // Υγεία (category_id = 6)
    await db.insert('expenses', {
      'description': 'Φάρμακα φαρμακείου',
      'amount': 18.75,
      'category_id': 6,
      'date_time': daysAgo(6, hour: 11, minute: 0),
      'latitude': 40.6415,
      'longitude': 22.9380,
      'location_name': 'Φαρμακείο Παπαδόπουλος',
    });

    // Ένδυση (category_id = 7)
    await db.insert('expenses', {
      'description': 'Αγορά παπουτσιών',
      'amount': 79.99,
      'category_id': 7,
      'date_time': daysAgo(12, hour: 16, minute: 30),
      'latitude': 40.6350,
      'longitude': 22.9400,
      'location_name': 'Tsakiris Mallas Τσιμισκή',
    });
  }

  // ── Categories CRUD ───────────────────────────────────────────────────────

  Future<int> insertCategory(Category category) async {
    final db = await database;
    return db.insert('categories', category.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Category>> getAllCategories() async {
    final db = await database;
    final maps = await db.query('categories', orderBy: 'name ASC');
    return maps.map(Category.fromMap).toList();
  }

  Future<int> updateCategory(Category category) async {
    final db = await database;
    return db.update('categories', category.toMap(),
        where: 'id = ?', whereArgs: [category.id]);
  }

  Future<int> deleteCategory(int id) async {
    final db = await database;
    return db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  // ── Expenses CRUD ─────────────────────────────────────────────────────────

  Future<int> insertExpense(Expense expense) async {
    final db = await database;
    return db.insert('expenses', expense.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Expense>> getAllExpenses() async {
    final db = await database;
    final maps = await db.query('expenses', orderBy: 'date_time DESC');
    return maps.map(Expense.fromMap).toList();
  }

  Future<int> updateExpense(Expense expense) async {
    final db = await database;
    return db.update('expenses', expense.toMap(),
        where: 'id = ?', whereArgs: [expense.id]);
  }

  Future<int> deleteExpense(int id) async {
    final db = await database;
    return db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  Future<Map<int, double>> getTotalsByCategoryInRange(
      DateTime start, DateTime end) async {
    final db = await database;
    final endOfDay = DateTime(end.year, end.month, end.day, 23, 59, 59);
    final result = await db.rawQuery('''
      SELECT category_id, SUM(amount) as total
      FROM expenses
      WHERE date_time >= ? AND date_time <= ?
      GROUP BY category_id
      ORDER BY total DESC
    ''', [start.toIso8601String(), endOfDay.toIso8601String()]);
    return {
      for (final row in result)
        row['category_id'] as int: (row['total'] as num).toDouble()
    };
  }
}
