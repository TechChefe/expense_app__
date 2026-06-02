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
    // Bumped to _pro to force fresh creation with the new seed data
    final path = join(dbPath, 'expense_app_pro2.db');
    return openDatabase(path, version: 1, onCreate: _createTables);
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT
      )
    ''');
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
    await _seedData(db);
  }

  // ── Seed Data — runs once on first install ───────────────────────────────
  Future<void> _seedData(Database db) async {
    final now = DateTime.now();
    String when(int daysAgo, {int h = 12, int m = 0}) =>
        DateTime(now.year, now.month, now.day - daysAgo, h, m)
            .toIso8601String();

    // ── Categories ──────────────────────────────────────────────────────
    final cIds = <String, int>{};
    Future<void> addCat(String key, String name, String desc) async {
      cIds[key] = await db.insert('categories', {
        'name': name,
        'description': desc,
      });
    }

    await addCat('coffee', 'Καφές & Σνακ',
        'Αγορές καφέ, snacks και ροφημάτων');
    await addCat('clothing', 'Ένδυση & Αθλητικά',
        'Ρούχα, παπούτσια και αθλητικά είδη');
    await addCat('subs', 'Συνδρομές',
        'Streaming, εφαρμογές και ψηφιακές υπηρεσίες');
    await addCat('travel', 'Ταξίδια',
        'Αεροπορικά εισιτήρια και διαμονή');
    await addCat('dining', 'Εστίαση',
        'Εστιατόρια, μεζεδοπωλεία και delivery');
    await addCat('home', 'Σπίτι & Διάφορα',
        'Είδη σπιτιού, διακόσμηση και καθημερινές αγορές');
    await addCat('market', 'Σούπερ Μάρκετ',
        'Εβδομαδιαίες αγορές τροφίμων');
    await addCat('transport', 'Μεταφορές',
        'Καύσιμα, εισιτήρια και taxi');

    // ── Expenses ────────────────────────────────────────────────────────
    final all = <Map<String, dynamic>>[
      // ── Καφές & Σνακ ──
      {
        'description': 'Freddo espresso',
        'amount': 3.80,
        'category_id': cIds['coffee'],
        'date_time': when(0, h: 9, m: 15),
        'latitude': 40.6308,
        'longitude': 22.9437,
        'location_name': 'Mikel Coffee Τσιμισκή',
      },
      {
        'description': 'Cappuccino και τοστ',
        'amount': 6.40,
        'category_id': cIds['coffee'],
        'date_time': when(1, h: 10, m: 30),
        'latitude': 40.6256,
        'longitude': 22.9485,
        'location_name': 'Coffee Island Νέα Παραλία',
      },
      {
        'description': 'Iced latte',
        'amount': 4.90,
        'category_id': cIds['coffee'],
        'date_time': when(2, h: 16, m: 45),
        'latitude': 40.5867,
        'longitude': 22.9587,
        'location_name': 'Starbucks One Salonica',
      },

      // ── Ένδυση & Αθλητικά ──
      {
        'description': 'Nike Dri-FIT t-shirt',
        'amount': 66.30,
        'category_id': cIds['clothing'],
        'date_time': when(3, h: 18, m: 20),
        'latitude': 40.5814,
        'longitude': 22.9961,
        'location_name': 'Nike Store Mediterranean Cosmos',
      },
      {
        'description': 'Adidas Samba OG sneakers',
        'amount': 119.99,
        'category_id': cIds['clothing'],
        'date_time': when(8, h: 17, m: 0),
        'latitude': 40.6326,
        'longitude': 22.9396,
        'location_name': 'Adidas Original Στore Τσιμισκή',
      },
      {
        'description': 'Under Armour αθλητικά σορτς',
        'amount': 38.50,
        'category_id': cIds['clothing'],
        'date_time': when(11, h: 14, m: 10),
        'latitude': 40.5870,
        'longitude': 22.9970,
        'location_name': 'Cosmos Sport Mediterranean Cosmos',
      },
      {
        'description': 'Puma αθλητική φόρμα',
        'amount': 75.00,
        'category_id': cIds['clothing'],
        'date_time': when(15, h: 19, m: 30),
        'latitude': 40.6298,
        'longitude': 22.9421,
        'location_name': 'Intersport Aristotelous',
      },

      // ── Συνδρομές ──
      {
        'description': 'Συνδρομή Cosmote TV',
        'amount': 24.90,
        'category_id': cIds['subs'],
        'date_time': when(4, h: 8, m: 0),
        'latitude': null,
        'longitude': null,
        'location_name': null,
      },
      {
        'description': 'Netflix Premium',
        'amount': 17.99,
        'category_id': cIds['subs'],
        'date_time': when(6, h: 8, m: 0),
        'latitude': null,
        'longitude': null,
        'location_name': null,
      },
      {
        'description': 'Spotify Premium',
        'amount': 9.99,
        'category_id': cIds['subs'],
        'date_time': when(9, h: 8, m: 0),
        'latitude': null,
        'longitude': null,
        'location_name': null,
      },
      {
        'description': 'YouTube Premium Family',
        'amount': 21.99,
        'category_id': cIds['subs'],
        'date_time': when(13, h: 8, m: 0),
        'latitude': null,
        'longitude': null,
        'location_name': null,
      },

      // ── Ταξίδια ──
      {
        'description': 'Aegean Airlines: ΑΘΗ → Μύκονος',
        'amount': 142.50,
        'category_id': cIds['travel'],
        'date_time': when(5, h: 11, m: 15),
        'latitude': 37.9356,
        'longitude': 23.9484,
        'location_name': 'Aegean Office Αθήνα',
      },
      {
        'description': 'Ryanair: SKG → Ρώμη',
        'amount': 89.00,
        'category_id': cIds['travel'],
        'date_time': when(10, h: 22, m: 5),
        'latitude': null,
        'longitude': null,
        'location_name': 'ryanair.com',
      },
      {
        'description': 'Δωμάτιο Airbnb 2 βραδιές',
        'amount': 156.00,
        'category_id': cIds['travel'],
        'date_time': when(14, h: 20, m: 0),
        'latitude': null,
        'longitude': null,
        'location_name': 'airbnb.com',
      },

      // ── Εστίαση ──
      {
        'description': 'Δείπνο σε μεζεδοπωλείο',
        'amount': 48.50,
        'category_id': cIds['dining'],
        'date_time': when(2, h: 21, m: 30),
        'latitude': 40.6395,
        'longitude': 22.9358,
        'location_name': 'Λαδάδικα — Ντερέ Παπά',
      },
      {
        'description': 'Pizza & wings delivery',
        'amount': 22.40,
        'category_id': cIds['dining'],
        'date_time': when(7, h: 20, m: 45),
        'latitude': 40.6310,
        'longitude': 22.9540,
        'location_name': 'Domino\'s Pizza Καλαμαριά',
      },
      {
        'description': 'Σουβλάκι & μπύρα',
        'amount': 14.80,
        'category_id': cIds['dining'],
        'date_time': when(1, h: 14, m: 0),
        'latitude': 40.6403,
        'longitude': 22.9337,
        'location_name': 'Ολύμπιον Λαδάδικα',
      },

      // ── Σπίτι & Διάφορα ──
      {
        'description': 'Διακοσμητικά κεριά & αρωματικά',
        'amount': 14.85,
        'category_id': cIds['home'],
        'date_time': when(6, h: 13, m: 20),
        'latitude': 40.5867,
        'longitude': 22.9587,
        'location_name': 'Tedi Καλαμαριά',
      },
      {
        'description': 'Είδη κουζίνας & αποθήκευσης',
        'amount': 9.30,
        'category_id': cIds['home'],
        'date_time': when(12, h: 16, m: 40),
        'latitude': 40.6580,
        'longitude': 22.9505,
        'location_name': 'Tedi Παύλος Μελάς',
      },
      {
        'description': 'Παπλωματοθήκη & μαξιλάρια Jumbo',
        'amount': 42.70,
        'category_id': cIds['home'],
        'date_time': when(16, h: 11, m: 0),
        'latitude': 40.6789,
        'longitude': 22.9456,
        'location_name': 'Jumbo Σταυρούπολη',
      },

      // ── Σούπερ Μάρκετ ──
      {
        'description': 'Εβδομαδιαία αγορά Sklavenitis',
        'amount': 92.30,
        'category_id': cIds['market'],
        'date_time': when(0, h: 18, m: 30),
        'latitude': 40.5901,
        'longitude': 22.9603,
        'location_name': 'Sklavenitis Καλαμαριά',
      },
      {
        'description': 'AB Βασιλόπουλος — φρούτα & λαχανικά',
        'amount': 28.45,
        'category_id': cIds['market'],
        'date_time': when(4, h: 19, m: 0),
        'latitude': 40.6347,
        'longitude': 22.9468,
        'location_name': 'AB Βασιλόπουλος Λευκός Πύργος',
      },

      // ── Μεταφορές ──
      {
        'description': 'Βενζίνη αυτοκινήτου',
        'amount': 55.00,
        'category_id': cIds['transport'],
        'date_time': when(3, h: 9, m: 0),
        'latitude': 40.5878,
        'longitude': 22.9844,
        'location_name': 'BP Πανόραμα',
      },
      {
        'description': 'Μηνιαία κάρτα ΟΑΣΘ',
        'amount': 30.00,
        'category_id': cIds['transport'],
        'date_time': when(20, h: 8, m: 30),
        'latitude': null,
        'longitude': null,
        'location_name': null,
      },

      // ── ΠΑΛΑΙΟΤΕΡΑ (35–90 ημέρες πίσω) για να ξεχωρίζει 30d vs 90d ─────
      {
        'description': 'Adidas αθλητικά παπούτσια',
        'amount': 95.50,
        'category_id': cIds['clothing'],
        'date_time': when(35, h: 17, m: 40),
        'latitude': 40.5814,
        'longitude': 22.9961,
        'location_name': 'Adidas Store Mediterranean Cosmos',
      },
      {
        'description': 'Aegean: Ρόδος επιστροφή',
        'amount': 187.30,
        'category_id': cIds['travel'],
        'date_time': when(42, h: 21, m: 15),
        'latitude': null,
        'longitude': null,
        'location_name': 'aegeanair.com',
      },
      {
        'description': 'Συνδρομή Cosmote TV (μήνας)',
        'amount': 24.90,
        'category_id': cIds['subs'],
        'date_time': when(48, h: 8, m: 0),
        'latitude': null,
        'longitude': null,
        'location_name': null,
      },
      {
        'description': 'Δείπνο στο Pellegrino',
        'amount': 62.40,
        'category_id': cIds['dining'],
        'date_time': when(55, h: 21, m: 0),
        'latitude': 40.6298,
        'longitude': 22.9421,
        'location_name': 'Pellegrino Λευκός Πύργος',
      },
      {
        'description': 'Tedi είδη μπάνιου',
        'amount': 18.20,
        'category_id': cIds['home'],
        'date_time': when(62, h: 12, m: 30),
        'latitude': 40.6580,
        'longitude': 22.9505,
        'location_name': 'Tedi Παύλος Μελάς',
      },
      {
        'description': 'Καφές με φίλους',
        'amount': 9.80,
        'category_id': cIds['coffee'],
        'date_time': when(70, h: 18, m: 30),
        'latitude': 40.6256,
        'longitude': 22.9485,
        'location_name': 'Coffee Island Νέα Παραλία',
      },
      {
        'description': 'AB Βασιλόπουλος εβδομαδιαία',
        'amount': 64.85,
        'category_id': cIds['market'],
        'date_time': when(78, h: 19, m: 30),
        'latitude': 40.6347,
        'longitude': 22.9468,
        'location_name': 'AB Βασιλόπουλος Λευκός Πύργος',
      },
      {
        'description': 'Nike sneakers',
        'amount': 109.99,
        'category_id': cIds['clothing'],
        'date_time': when(85, h: 16, m: 20),
        'latitude': 40.5814,
        'longitude': 22.9961,
        'location_name': 'Nike Store Mediterranean Cosmos',
      },
    ];

    for (final row in all) {
      await db.insert('expenses', row);
    }
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
