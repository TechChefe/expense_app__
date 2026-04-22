// lib/screens/expense_detail_screen.dart
// ΠΧ3 – Λεπτομέρειες / Διαγραφή / Τροποποίηση εξόδου

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../services/app_provider.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';
import 'add_expense_screen.dart';

class ExpenseDetailScreen extends StatelessWidget {
  final Expense expense;
  const ExpenseDetailScreen({super.key, required this.expense});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final current = provider.expenses.firstWhere(
      (e) => e.id == expense.id,
      orElse: () => expense,
    );
    final category = provider.getCategoryById(current.categoryId);
    final colorIdx =
        ((current.categoryId - 1).abs()) % AppTheme.categoryColors.length;
    final color = AppTheme.categoryColors[colorIdx];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Λεπτομέρειες Εξόδου'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Επεξεργασία',
            onPressed: () => Navigator.push<void>(
              context,
              MaterialPageRoute(
                  builder: (_) => AddExpenseScreen(expense: current)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            color: AppTheme.error,
            tooltip: 'Διαγραφή',
            onPressed: () => _confirmDelete(context, current, provider),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Amount hero
          Card(
            color: AppTheme.primary,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(children: [
                const Text('Ποσό',
                    style:
                        TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 4),
                Text(Formatters.currency(current.amount),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w800)),
              ]),
            ),
          ),
          const SizedBox(height: 16),

          // Details card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                _Row(
                  icon: Icons.category_outlined,
                  label: 'Κατηγορία',
                  value: category?.name ?? 'Άγνωστη',
                  valueColor: color,
                ),
                const Divider(height: 24),
                _Row(
                  icon: Icons.calendar_today_outlined,
                  label: 'Ημερομηνία & Ώρα',
                  value: Formatters.dateTimeFull(current.dateTime),
                ),
                if (current.description != null &&
                    current.description!.isNotEmpty) ...[
                  const Divider(height: 24),
                  _Row(
                    icon: Icons.notes_outlined,
                    label: 'Περιγραφή',
                    value: current.description!,
                  ),
                ],
                if (current.latitude != null &&
                    current.longitude != null) ...[
                  const Divider(height: 24),
                  _Row(
                    icon: Icons.gps_fixed,
                    label: 'Συντεταγμένες',
                    value:
                        '${current.latitude!.toStringAsFixed(6)}, ${current.longitude!.toStringAsFixed(6)}',
                  ),
                ],
                if (current.locationName != null &&
                    current.locationName!.isNotEmpty) ...[
                  const Divider(height: 24),
                  _Row(
                    icon: Icons.place_outlined,
                    label: 'Τοποθεσία',
                    value: current.locationName!,
                  ),
                ],
              ]),
            ),
          ),
          const SizedBox(height: 24),

          Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.edit),
                label: const Text('Επεξεργασία'),
                onPressed: () => Navigator.push<void>(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          AddExpenseScreen(expense: current)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.delete),
                label: const Text('Διαγραφή'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.error),
                onPressed: () =>
                    _confirmDelete(context, current, provider),
              ),
            ),
          ]),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, Expense e, AppProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Διαγραφή Εξόδου'),
        content: Text(
            'Είστε σίγουρος/η ότι θέλετε να διαγράψετε αυτό το έξοδο (${Formatters.currency(e.amount)});'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Ακύρωση')),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Διαγραφή'),
          ),
        ],
      ),
    );
    if (confirmed == true && e.id != null) {
      await provider.deleteExpense(e.id!);
      if (context.mounted) Navigator.pop(context);
    }
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _Row({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppTheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text(value,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: valueColor ?? AppTheme.textPrimary)),
            ],
          ),
        ),
      ],
    );
  }
}
