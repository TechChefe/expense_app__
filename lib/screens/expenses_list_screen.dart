// lib/screens/expenses_list_screen.dart
// ΠΧ3 – Επιθεώρηση εξόδων

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../services/app_provider.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';
import 'add_expense_screen.dart';
import 'expense_detail_screen.dart';

class ExpensesListScreen extends StatelessWidget {
  const ExpensesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Έξοδα'),
        actions: [
          Consumer<AppProvider>(
            builder: (_, provider, __) {
              final total = provider.expenses
                  .fold<double>(0.0, (sum, e) => sum + e.amount);
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Σύνολο',
                          style: TextStyle(
                              fontSize: 11, color: Colors.white70)),
                      Text(Formatters.currency(total),
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push<void>(context,
            MaterialPageRoute(builder: (_) => const AddExpenseScreen())),
        icon: const Icon(Icons.add),
        label: const Text('Νέο Έξοδο'),
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          final expenses = provider.expenses;
          if (expenses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined,
                      size: 72,
                      color: AppTheme.textSecondary.withValues(alpha: 0.4)),
                  const SizedBox(height: 16),
                  const Text('Δεν υπάρχουν έξοδα',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary)),
                  const SizedBox(height: 8),
                  const Text(
                    'Πατήστε το κουμπί + για να καταγράψετε\nτο πρώτο σας έξοδο.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ],
              ),
            );
          }

          // Group by date label
          final grouped = <String, List<Expense>>{};
          for (final e in expenses) {
            final key = Formatters.relativeDate(e.dateTime);
            grouped.putIfAbsent(key, () => []).add(e);
          }
          final groups = grouped.entries.toList();

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            itemCount: groups.length,
            itemBuilder: (context, i) {
              final group = groups[i];
              final groupTotal =
                  group.value.fold<double>(0.0, (s, e) => s + e.amount);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _GroupHeader(label: group.key, total: groupTotal),
                  const SizedBox(height: 6),
                  ...group.value.map((expense) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _ExpenseCard(
                          expense: expense,
                          onTap: () => Navigator.push<void>(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    ExpenseDetailScreen(expense: expense)),
                          ),
                        ),
                      )),
                  const SizedBox(height: 4),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  final String label;
  final double total;
  const _GroupHeader({required this.label, required this.total});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textSecondary,
                  letterSpacing: 0.5)),
          Text(Formatters.currency(total),
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary)),
        ],
      ),
    );
  }
}

class _ExpenseCard extends StatelessWidget {
  final Expense expense;
  final VoidCallback onTap;
  const _ExpenseCard({required this.expense, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AppProvider>();
    final category = provider.getCategoryById(expense.categoryId);
    final categoryName = category?.name ?? 'Άγνωστη κατηγορία';
    final colorIdx =
        ((expense.categoryId - 1).abs()) % AppTheme.categoryColors.length;
    final color = AppTheme.categoryColors[colorIdx];

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 48,
                decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(categoryName,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primary)),
                    if (expense.description != null &&
                        expense.description!.isNotEmpty)
                      Text(expense.description!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondary)),
                    if (expense.locationName != null &&
                        expense.locationName!.isNotEmpty)
                      Row(children: [
                        const Icon(Icons.place_outlined,
                            size: 12, color: AppTheme.textSecondary),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(expense.locationName!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary)),
                        ),
                      ]),
                    Text(Formatters.dateTimeFull(expense.dateTime),
                        style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textSecondary)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(Formatters.currency(expense.amount),
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary)),
            ],
          ),
        ),
      ),
    );
  }
}
