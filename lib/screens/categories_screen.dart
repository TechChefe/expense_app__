// lib/screens/categories_screen.dart
// ΠΧ1 – Δημιουργία κατηγοριών εξόδων

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category.dart' as cat_model;
import '../services/app_provider.dart';
import '../utils/app_theme.dart';

typedef Category = cat_model.Category;

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Κατηγορίες Εξόδων')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCategoryDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Νέα Κατηγορία'),
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          final categories = provider.categories;
          if (categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.category_outlined,
                      size: 72,
                      color: AppTheme.textSecondary.withValues(alpha: 0.4)),
                  const SizedBox(height: 16),
                  const Text('Δεν υπάρχουν κατηγορίες',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary)),
                  const SizedBox(height: 8),
                  const Text(
                    'Πατήστε το κουμπί + για να δημιουργήσετε\nμία νέα κατηγορία εξόδων.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final category = categories[index];
              return _CategoryCard(
                category: category,
                colorIndex: index % AppTheme.categoryColors.length,
                onEdit: () => _showCategoryDialog(context, category: category),
                onDelete: () => _confirmDelete(context, category, provider),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _showCategoryDialog(BuildContext context,
      {Category? category}) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => _CategoryDialog(category: category),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, Category category, AppProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Διαγραφή Κατηγορίας'),
        content: Text(
            'Είστε σίγουρος/η ότι θέλετε να διαγράψετε την κατηγορία "${category.name}";\n\nΠροσοχή: Θα διαγραφούν και όλα τα σχετικά έξοδα!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Ακύρωση'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Διαγραφή'),
          ),
        ],
      ),
    );
    if (confirmed == true && category.id != null) {
      await provider.deleteCategory(category.id!);
    }
  }
}

class _CategoryCard extends StatelessWidget {
  final Category category;
  final int colorIndex;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CategoryCard({
    required this.category,
    required this.colorIndex,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.categoryColors[colorIndex];
    return Card(
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Text(
            category.name.isNotEmpty
                ? category.name[0].toUpperCase()
                : '?',
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        title: Text(category.name,
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: AppTheme.textPrimary)),
        subtitle: (category.description != null &&
                category.description!.isNotEmpty)
            ? Text(category.description!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppTheme.textSecondary))
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              color: AppTheme.primaryLight,
              onPressed: onEdit,
              tooltip: 'Επεξεργασία',
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: AppTheme.error,
              onPressed: onDelete,
              tooltip: 'Διαγραφή',
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryDialog extends StatefulWidget {
  final Category? category;
  const _CategoryDialog({this.category});

  @override
  State<_CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<_CategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.category?.name ?? '');
    _descCtrl =
        TextEditingController(text: widget.category?.description ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.category != null;
    return AlertDialog(
      title: Text(isEdit ? 'Επεξεργασία Κατηγορίας' : 'Νέα Κατηγορία'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Όνομα κατηγορίας *',
                hintText: 'π.χ. Σούπερ μάρκετ',
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Το όνομα είναι υποχρεωτικό'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descCtrl,
              decoration: const InputDecoration(
                labelText: 'Περιγραφή (προαιρετικό)',
                hintText: 'π.χ. Αγορές τροφίμων',
              ),
              textCapitalization: TextCapitalization.sentences,
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Ακύρωση'),
        ),
        ElevatedButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : Text(isEdit ? 'Αποθήκευση' : 'Δημιουργία'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final provider = context.read<AppProvider>();
    final name = _nameCtrl.text.trim();
    final desc =
        _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim();
    try {
      if (widget.category == null) {
        await provider.addCategory(name, description: desc);
      } else {
        await provider
            .updateCategory(widget.category!.copyWith(name: name, description: desc));
      }
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
