// lib/utils/formatters.dart

import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static final _currency =
      NumberFormat.currency(locale: 'el_GR', symbol: '€', decimalDigits: 2);
  static final _dateShort = DateFormat('dd/MM/yyyy');
  static final _dateTimeFull = DateFormat('dd/MM/yyyy HH:mm');

  static String currency(double amount) => _currency.format(amount);
  static String dateShort(DateTime dt) => _dateShort.format(dt);
  static String dateTimeFull(DateTime dt) => _dateTimeFull.format(dt);

  static String relativeDate(DateTime dt) {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final date = DateTime(dt.year, dt.month, dt.day);
    final diff = todayDate.difference(date).inDays;
    if (diff == 0) return 'Σήμερα';
    if (diff == 1) return 'Χθες';
    return _dateShort.format(dt);
  }
}
