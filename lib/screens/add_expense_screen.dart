// lib/screens/add_expense_screen.dart
// ΠΧ2 – Καταγραφή εξόδων / ΠΧ3 – Επεξεργασία

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/category.dart' as cat_model;
import '../models/expense.dart';
import '../services/app_provider.dart';
import '../services/location_service.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';

// Alias for convenience
typedef Category = cat_model.Category;

class AddExpenseScreen extends StatefulWidget {
  final Expense? expense;
  const AddExpenseScreen({super.key, this.expense});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _locationNameCtrl = TextEditingController();

  Category? _selectedCategory;
  DateTime _selectedDateTime = DateTime.now();
  double? _latitude;
  double? _longitude;
  bool _loadingLocation = false;
  bool _saving = false;

  bool get _isEdit => widget.expense != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final e = widget.expense!;
      _descCtrl.text = e.description ?? '';
      _amountCtrl.text = e.amount.toStringAsFixed(2);
      _selectedDateTime = e.dateTime;
      _latitude = e.latitude;
      _longitude = e.longitude;
      _locationNameCtrl.text = e.locationName ?? '';
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isEdit && _selectedCategory == null) {
      _selectedCategory = context
          .read<AppProvider>()
          .getCategoryById(widget.expense!.categoryId);
    }
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _amountCtrl.dispose();
    _locationNameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<AppProvider>().categories;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Επεξεργασία Εξόδου' : 'Νέο Έξοδο'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Amount ──────────────────────────────────────────────────────
            const _Label('Ποσό *'),
            TextFormField(
              controller: _amountCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              decoration: const InputDecoration(
                  prefixText: '€ ', hintText: '0.00'),
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w700),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Το ποσό είναι υποχρεωτικό';
                }
                final parsed = double.tryParse(v.replaceAll(',', '.'));
                if (parsed == null || parsed <= 0) {
                  return 'Εισάγετε έγκυρο ποσό';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // ── Category ────────────────────────────────────────────────────
            const _Label('Κατηγορία *'),
            if (categories.isEmpty)
              OutlinedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Δημιουργία κατηγορίας'),
                onPressed: () => _openQuickCategory(context),
              )
            else
              DropdownButtonFormField<Category>(
                value: _selectedCategory,
                isExpanded: true,
                decoration: const InputDecoration(
                    hintText: 'Επιλέξτε κατηγορία'),
                items: categories
                    .map((Category cat) => DropdownMenuItem<Category>(
                          value: cat,
                          child: Text(cat.name),
                        ))
                    .toList(),
                onChanged: (Category? v) =>
                    setState(() => _selectedCategory = v),
                validator: (_) => _selectedCategory == null
                    ? 'Επιλέξτε κατηγορία'
                    : null,
              ),
            if (categories.isNotEmpty)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Νέα κατηγορία'),
                  style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primaryLight),
                  onPressed: () => _openQuickCategory(context),
                ),
              ),
            const SizedBox(height: 8),

            // ── Description ─────────────────────────────────────────────────
            const _Label('Περιγραφή (προαιρετικό)'),
            TextFormField(
              controller: _descCtrl,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 2,
              decoration: const InputDecoration(
                  hintText: 'π.χ. Εβδομαδιαία αγορά σούπερ μάρκετ'),
            ),
            const SizedBox(height: 20),

            // ── Date / Time ──────────────────────────────────────────────────
            const _Label('Ημερομηνία & Ώρα'),
            InkWell(
              onTap: _pickDateTime,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.divider),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        color: AppTheme.primary, size: 20),
                    const SizedBox(width: 12),
                    Text(Formatters.dateTimeFull(_selectedDateTime),
                        style: const TextStyle(
                            fontSize: 15,
                            color: AppTheme.textPrimary)),
                    const Spacer(),
                    const Icon(Icons.chevron_right,
                        color: AppTheme.textSecondary),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Location ────────────────────────────────────────────────────
            const _Label('Τοποθεσία'),
            if (_latitude != null && _longitude != null)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: AppTheme.accent.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on,
                        color: AppTheme.accent, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Lat: ${_latitude!.toStringAsFixed(5)}, '
                        'Lng: ${_longitude!.toStringAsFixed(5)}',
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close,
                          color: AppTheme.textSecondary, size: 18),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => setState(() {
                        _latitude = null;
                        _longitude = null;
                      }),
                    ),
                  ],
                ),
              ),
            OutlinedButton.icon(
              icon: _loadingLocation
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child:
                          CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.my_location),
              label: Text(_latitude != null
                  ? 'Ανανέωση τοποθεσίας'
                  : 'Λήψη τρέχουσας τοποθεσίας'),
              onPressed: _loadingLocation ? null : _getLocation,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _locationNameCtrl,
              decoration: const InputDecoration(
                labelText: 'Όνομα τοποθεσίας (προαιρετικό)',
                hintText: 'π.χ. Sklavenitis Kalamaria',
                prefixIcon: Icon(Icons.place_outlined),
              ),
            ),
            const SizedBox(height: 32),

            // ── Save ────────────────────────────────────────────────────────
            ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52)),
              child: _saving
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : Text(
                      _isEdit
                          ? 'Αποθήκευση αλλαγών'
                          : 'Καταγραφή εξόδου',
                      style: const TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );
    if (time == null) return;

    setState(() {
      _selectedDateTime = DateTime(
          date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _getLocation() async {
    setState(() => _loadingLocation = true);
    try {
      final result = await LocationService().getCurrentLocation();
      if (result != null) {
        setState(() {
          _latitude = result.latitude;
          _longitude = result.longitude;
          if (result.address != null &&
              _locationNameCtrl.text.isEmpty) {
            _locationNameCtrl.text = result.address!;
          }
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
                  'Δεν ήταν δυνατή η λήψη τοποθεσίας.')));
        }
      }
    } finally {
      if (mounted) setState(() => _loadingLocation = false);
    }
  }

  Future<void> _openQuickCategory(BuildContext context) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => const _QuickCategoryScreen()),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final provider = context.read<AppProvider>();
    try {
      final amount =
          double.parse(_amountCtrl.text.trim().replaceAll(',', '.'));
      final description = _descCtrl.text.trim().isEmpty
          ? null
          : _descCtrl.text.trim();
      final locationName = _locationNameCtrl.text.trim().isEmpty
          ? null
          : _locationNameCtrl.text.trim();

      if (_isEdit) {
        await provider.updateExpense(widget.expense!.copyWith(
          description: description,
          amount: amount,
          categoryId: _selectedCategory!.id!,
          dateTime: _selectedDateTime,
          latitude: _latitude,
          longitude: _longitude,
          locationName: locationName,
        ));
      } else {
        await provider.addExpense(
          description: description,
          amount: amount,
          categoryId: _selectedCategory!.id!,
          dateTime: _selectedDateTime,
          latitude: _latitude,
          longitude: _longitude,
          locationName: locationName,
        );
      }
      if (mounted) Navigator.pop(context, true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

// ── Section label widget ──────────────────────────────────────────────────────

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
            letterSpacing: 0.5,
          )),
    );
  }
}

// ── Quick category creation screen ───────────────────────────────────────────

class _QuickCategoryScreen extends StatefulWidget {
  const _QuickCategoryScreen();

  @override
  State<_QuickCategoryScreen> createState() =>
      _QuickCategoryScreenState();
}

class _QuickCategoryScreenState extends State<_QuickCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Νέα Κατηγορία')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                    labelText: 'Όνομα κατηγορίας *'),
                textCapitalization: TextCapitalization.sentences,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Υποχρεωτικό πεδίο'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(
                    labelText: 'Περιγραφή (προαιρετικό)'),
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50)),
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Δημιουργία'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final provider = context.read<AppProvider>();
      final desc = _descCtrl.text.trim().isEmpty
          ? null
          : _descCtrl.text.trim();
      await provider.addCategory(_nameCtrl.text.trim(),
          description: desc);
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
