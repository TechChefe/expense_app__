// lib/services/app_provider.dart

import 'package:flutter/foundation.dart';
import '../models/category.dart' as cat_model;
import '../models/expense.dart';

import 'database_service.dart';

export '../models/category.dart' show Category;

class AppProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();

  List<cat_model.Category> _categories = [];
  List<Expense> _expenses = [];
  bool _isLoading = false;
  bool _isDarkMode = false;

  List<cat_model.Category> get categories => List.unmodifiable(_categories);
  List<Expense> get expenses => List.unmodifiable(_expenses);
  bool get isLoading => _isLoading;
  bool get isDarkMode => _isDarkMode;

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;

    notifyListeners();
  }

  void setDarkMode(bool value) {
    if (_isDarkMode == value) return;
    _isDarkMode = value;

    notifyListeners();
  }

  double get totalAmount =>
      _expenses.fold<double>(0, (sum, e) => sum + e.amount);

  int get expenseCount => _expenses.length;
  int get categoryCount => _categories.length;

  AppProvider() {
    _initAndLoad();
  }

  Future<void> _initAndLoad() async {
    _isLoading = true;
    notifyListeners();
    await _db.database; // ensure DB created + seed run
    await Future.delayed(const Duration(milliseconds: 80));
    _categories = await _db.getAllCategories();
    _expenses = await _db.getAllExpenses();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadAll() async {
    _isLoading = true;
    notifyListeners();
    _categories = await _db.getAllCategories();
    _expenses = await _db.getAllExpenses();
    _isLoading = false;
    notifyListeners();
  }

  // ── Categories ────────────────────────────────────────────────────────────

  Future<cat_model.Category> addCategory(String name,
      {String? description}) async {
    final category = cat_model.Category(name: name, description: description);
    final id = await _db.insertCategory(category);
    final saved = category.copyWith(id: id);
    _categories
      ..add(saved)
      ..sort((a, b) => a.name.compareTo(b.name));
    notifyListeners();
    return saved;
  }

  Future<void> updateCategory(cat_model.Category category) async {
    await _db.updateCategory(category);
    final idx = _categories.indexWhere((c) => c.id == category.id);
    if (idx != -1) {
      _categories[idx] = category;
      _categories.sort((a, b) => a.name.compareTo(b.name));
      notifyListeners();
    }
  }

  Future<void> deleteCategory(int id) async {
    await _db.deleteCategory(id);
    _categories.removeWhere((c) => c.id == id);
    _expenses.removeWhere((e) => e.categoryId == id);
    notifyListeners();
  }

  cat_model.Category? getCategoryById(int id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  // ── Expenses ──────────────────────────────────────────────────────────────

  Future<Expense> addExpense({
    String? description,
    required double amount,
    required int categoryId,
    required DateTime dateTime,
    double? latitude,
    double? longitude,
    String? locationName,
  }) async {
    final expense = Expense(
      description: description,
      amount: amount,
      categoryId: categoryId,
      dateTime: dateTime,
      latitude: latitude,
      longitude: longitude,
      locationName: locationName,
    );
    final id = await _db.insertExpense(expense);
    final saved = expense.copyWith(id: id);
    _expenses
      ..add(saved)
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
    notifyListeners();
    return saved;
  }

  Future<void> updateExpense(Expense expense) async {
    await _db.updateExpense(expense);
    final idx = _expenses.indexWhere((e) => e.id == expense.id);
    if (idx != -1) {
      _expenses[idx] = expense;
      _expenses.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      notifyListeners();
    }
  }

  Future<void> deleteExpense(int id) async {
    await _db.deleteExpense(id);
    _expenses.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  Future<List<CategoryAnalysis>> getAnalysis(
      DateTime start, DateTime end) async {
    final totals = await _db.getTotalsByCategoryInRange(start, end);
    final result = <CategoryAnalysis>[];
    for (final entry in totals.entries) {
      final category = getCategoryById(entry.key);
      if (category != null) {
        result.add(
            CategoryAnalysis(category: category, total: entry.value));
      }
    }
    result.sort((a, b) => b.total.compareTo(a.total));
    return result;
  }
}

class CategoryAnalysis {
  final cat_model.Category category;
  final double total;
  const CategoryAnalysis({required this.category, required this.total});
}
