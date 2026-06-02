// lib/screens/categories_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category.dart' as cat_model;
import '../services/app_provider.dart';
import '../utils/app_theme.dart';
import '../utils/category_style.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Κατηγορίες'),
        backgroundColor: Colors.transparent,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCategoryDialog(context),
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Νέα Κατηγορία',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        elevation: 8,
      ),
      body: SafeArea(
        bottom: false,
        child: Consumer<AppProvider>(
          builder: (context, provider, _) {
            if (provider.categories.isEmpty) {
              return const _EmptyCategories();
            }

            // Count expenses per category for the badge
            final counts = <int, int>{};
            for (final e in provider.expenses) {
              counts[e.categoryId] = (counts[e.categoryId] ?? 0) + 1;
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
              itemCount: provider.categories.length,
              itemBuilder: (context, index) {
                final c = provider.categories[index];
                final count = counts[c.id] ?? 0;
                return _CategoryTile(
                  category: c,
                  expenseCount: count,
                  index: index,
                  onEdit: () => _showCategoryDialog(context, existing: c),
                  onDelete: () => _confirmDelete(context, c),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _showCategoryDialog(BuildContext context,
      {cat_model.Category? existing}) async {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final descCtrl =
        TextEditingController(text: existing?.description ?? '');
    final formKey = GlobalKey<FormState>();
    final isEdit = existing != null;

    await showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isEdit
                            ? Icons.edit_rounded
                            : Icons.add_circle_outline_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isEdit ? 'Επεξεργασία' : 'Νέα Κατηγορία',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary(context),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                TextFormField(
                  controller: nameCtrl,
                  autofocus: true,
                  textCapitalization: TextCapitalization.none,
                  decoration: const InputDecoration(
                    labelText: 'Όνομα κατηγορίας *',
                    hintText: 'π.χ. Σούπερ μάρκετ',
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Συμπληρώστε το όνομα'
                      : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: descCtrl,
                  textCapitalization: TextCapitalization.none,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Περιγραφή (προαιρετικό)',
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Ακύρωση'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;
                        final name = nameCtrl.text.trim();
                        final desc = descCtrl.text.trim();
                        final provider =
                            context.read<AppProvider>();
                        if (isEdit) {
                          await provider.updateCategory(
                            existing.copyWith(
                              name: name,
                              description: desc.isEmpty ? null : desc,
                            ),
                          );
                        } else {
                          await provider.addCategory(name,
                              description: desc.isEmpty ? null : desc);
                        }
                        if (ctx.mounted) Navigator.pop(ctx);
                      },
                      child: Text(isEdit ? 'Αποθήκευση' : 'Δημιουργία'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, cat_model.Category category) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Διαγραφή κατηγορίας;'),
        content: Text(
            'Θα διαγραφεί η κατηγορία "${category.name}" και όλα τα συσχετισμένα έξοδα.'),
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
      await context.read<AppProvider>().deleteCategory(category.id!);
    }
  }
}

class _CategoryTile extends StatelessWidget {
  final cat_model.Category category;
  final int expenseCount;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CategoryTile({
    required this.category,
    required this.expenseCount,
    required this.index,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final visual = CategoryStyle.forName(category.name);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 280 + (index.clamp(0, 8) * 50)),
      curve: Curves.easeOutCubic,
      builder: (_, t, child) => Transform.translate(
        offset: Offset(0, (1 - t) * 16),
        child: Opacity(opacity: t, child: child),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Material(
          color: AppTheme.surface(context),
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onEdit,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      gradient: visual.gradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: visual.color.withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(visual.icon, color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary(context),
                          ),
                        ),
                        if (category.description != null &&
                            category.description!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            category.description!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: AppTheme.textSecondary(context),
                            ),
                          ),
                        ],
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: visual.softBackground,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$expenseCount έξοδα',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: visual.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onEdit,
                    icon: Icon(Icons.edit_outlined,
                        color: AppTheme.textSecondary(context)),
                    visualDensity: VisualDensity.compact,
                  ),
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline_rounded,
                        color: AppTheme.error),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyCategories extends StatelessWidget {
  const _EmptyCategories();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.category_rounded,
                size: 48, color: AppTheme.primary),
          ),
          const SizedBox(height: 20),
          Text(
            'Καμία κατηγορία',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary(context)),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Πατήστε "+ Νέα Κατηγορία" για να ξεκινήσετε.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary(context)),
            ),
          ),
        ],
      ),
    );
  }
}
