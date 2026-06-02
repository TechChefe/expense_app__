// lib/utils/category_style.dart

import 'package:flutter/material.dart';
import 'app_theme.dart';

class CategoryVisual {
  final IconData icon;
  final Color color;
  const CategoryVisual({required this.icon, required this.color});

  Color get softBackground => color.withValues(alpha: 0.12);
  Color get tintedBorder => color.withValues(alpha: 0.25);

  LinearGradient get gradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [color, Color.lerp(color, Colors.black, 0.28) ?? color],
      );
}

class CategoryStyle {
  CategoryStyle._();

  // Keyword → visual map (matches Greek words found in category names)
  static final List<_Rule> _rules = [
    _Rule(['καφέ', 'καφε', 'σνακ', 'coffee'],
        Icons.local_cafe_rounded, const Color(0xFF8B5E3C)),
    _Rule(['ένδυση', 'ενδυση', 'αθλητικά', 'αθλητικα', 'ρούχα', 'ρουχα'],
        Icons.checkroom_rounded, const Color(0xFFFF6B6B)),
    _Rule(['συνδρομ', 'streaming', 'netflix'],
        Icons.subscriptions_rounded, const Color(0xFF6C5CE7)),
    _Rule(['ταξίδ', 'ταξιδ', 'αεροπορ', 'flight'],
        Icons.flight_takeoff_rounded, const Color(0xFF0984E3)),
    _Rule(['εστίαση', 'εστιαση', 'φαγητ', 'restaurant', 'delivery'],
        Icons.restaurant_rounded, const Color(0xFFE17055)),
    _Rule(['σπίτι', 'σπιτι', 'διάφορα', 'διαφορα', 'tedi', 'jumbo'],
        Icons.shopping_basket_rounded, const Color(0xFF00B894)),
    _Rule(['σούπερ', 'σουπερ', 'market', 'τρόφιμα', 'τροφιμα'],
        Icons.shopping_cart_rounded, const Color(0xFFFDCB6E)),
    _Rule(['μεταφορ', 'βενζίνη', 'βενζινη', 'καύσιμ', 'καυσιμ', 'transport'],
        Icons.directions_car_filled_rounded, const Color(0xFF74B9FF)),
    _Rule(['υγεία', 'υγεια', 'φαρμακ', 'γιατρ'],
        Icons.favorite_rounded, const Color(0xFFFD79A8)),
    _Rule(['ψυχαγωγία', 'ψυχαγωγια', 'σινεμά', 'σινεμα', 'παιχν'],
        Icons.movie_rounded, const Color(0xFFA29BFE)),
    _Rule(['λογαριασμ', 'δεη', 'νερό', 'νερο', 'τηλέφων', 'τηλεφων', 'internet'],
        Icons.receipt_long_rounded, const Color(0xFFE84393)),
    _Rule(['εκπαίδ', 'εκπαιδ', 'βιβλί', 'βιβλι', 'σχολ'],
        Icons.menu_book_rounded, const Color(0xFF26C6DA)),
  ];

  /// Resolve visual based on category name (Greek + English keyword matching).
  /// Falls back to deterministic palette based on hash of name.
  static CategoryVisual forName(String name) {
    final lower = name.toLowerCase().trim();
    for (final rule in _rules) {
      for (final kw in rule.keywords) {
        if (lower.contains(kw)) {
          return CategoryVisual(icon: rule.icon, color: rule.color);
        }
      }
    }
    // Fallback — hash-based deterministic color
    final hash = name.codeUnits.fold<int>(0, (a, b) => (a + b) % 1000);
    return CategoryVisual(
      icon: Icons.label_rounded,
      color: AppTheme.palette[hash % AppTheme.palette.length],
    );
  }
}

class _Rule {
  final List<String> keywords;
  final IconData icon;
  final Color color;
  _Rule(this.keywords, this.icon, this.color);
}
