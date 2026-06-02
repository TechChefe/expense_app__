// lib/screens/expense_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../services/app_provider.dart';
import '../utils/app_theme.dart';
import '../utils/category_style.dart';
import '../utils/formatters.dart';
import 'add_expense_screen.dart';

class ExpenseDetailScreen extends StatelessWidget {
  final Expense expense;
  const ExpenseDetailScreen({super.key, required this.expense});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        // Always pull the freshest version (in case it was edited)
        final current = provider.expenses.firstWhere(
          (e) => e.id == expense.id,
          orElse: () => expense,
        );
        final category = provider.getCategoryById(current.categoryId);
        final categoryName = category?.name ?? 'Άγνωστη';
        final visual = CategoryStyle.forName(categoryName);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Λεπτομέρειες'),
            backgroundColor: Colors.transparent,
            actions: [
              IconButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddExpenseScreen(expense: current),
                  ),
                ),
                icon: const Icon(Icons.edit_rounded),
              ),
              IconButton(
                onPressed: () => _confirmDelete(context, current.id!),
                icon: const Icon(Icons.delete_outline_rounded,
                    color: AppTheme.error),
              ),
            ],
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              children: [
                // ── HERO CARD ──
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: visual.gradient,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: visual.color.withValues(alpha: 0.35),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.22),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(visual.icon,
                                color: Colors.white, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            categoryName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      Text(
                        Formatters.currency(current.amount),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 44,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        Formatters.dateTimeFull(current.dateTime),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── DETAILS LIST ──
                const SizedBox(height: 24),
                if (current.description != null &&
                    current.description!.isNotEmpty)
                  _DetailRow(
                    icon: Icons.notes_rounded,
                    label: 'Περιγραφή',
                    value: current.description!,
                  ),
                if (current.locationName != null &&
                    current.locationName!.isNotEmpty)
                  _DetailRow(
                    icon: Icons.place_rounded,
                    label: 'Τοποθεσία',
                    value: current.locationName!,
                  ),
                if (current.latitude != null && current.longitude != null)
                  _DetailRow(
                    icon: Icons.gps_fixed_rounded,
                    label: 'Συντεταγμένες',
                    value:
                        '${current.latitude!.toStringAsFixed(5)}, ${current.longitude!.toStringAsFixed(5)}',
                  ),
                _DetailRow(
                  icon: Icons.tag_rounded,
                  label: 'ID εγγραφής',
                  value: '#${current.id}',
                ),

                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AddExpenseScreen(expense: current),
                          ),
                        ),
                        icon: const Icon(Icons.edit_rounded),
                        label: const Text('Επεξεργασία'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            _confirmDelete(context, current.id!),
                        icon: const Icon(Icons.delete_rounded),
                        label: const Text('Διαγραφή'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.error,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, int id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Διαγραφή εξόδου;'),
        content: const Text(
            'Είστε σίγουρος ότι θέλετε να διαγράψετε αυτό το έξοδο;'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Ακύρωση')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Διαγραφή'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await context.read<AppProvider>().deleteExpense(id);
      if (context.mounted) Navigator.pop(context);
    }
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, size: 18, color: AppTheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textSecondary(context),
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
