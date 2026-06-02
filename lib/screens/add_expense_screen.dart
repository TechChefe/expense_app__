// lib/screens/add_expense_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/category.dart' as cat_model;
import '../models/expense.dart';
import '../services/app_provider.dart';
import '../services/location_service.dart';
import '../utils/app_theme.dart';
import '../utils/category_style.dart';
import '../utils/formatters.dart';

typedef Category = cat_model.Category;

class AddExpenseScreen extends StatefulWidget {
  final Expense? expense;
  const AddExpenseScreen({super.key, this.expense});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _locationNameCtrl = TextEditingController();

  Category? _selectedCategory;
  DateTime _dateTime = DateTime.now();
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
      _amountCtrl.text = e.amount.toStringAsFixed(2).replaceAll('.', ',');
      _descCtrl.text = e.description ?? '';
      _locationNameCtrl.text = e.locationName ?? '';
      _dateTime = e.dateTime;
      _latitude = e.latitude;
      _longitude = e.longitude;
      // category set in build via provider once available
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descCtrl.dispose();
    _locationNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme(
            brightness: AppTheme.isDark(ctx) ? Brightness.dark : Brightness.light,
            primary: AppTheme.primary,
            onPrimary: Colors.white,
            secondary: AppTheme.accent,
            onSecondary: Colors.white,
            surface: AppTheme.surface(context),
            onSurface: AppTheme.textPrimary(context),
            error: AppTheme.error,
            onError: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (date == null) return;
    if (!mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dateTime),
    );
    setState(() {
      _dateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time?.hour ?? _dateTime.hour,
        time?.minute ?? _dateTime.minute,
      );
    });
  }

  Future<void> _getLocation() async {
    setState(() => _loadingLocation = true);
    final result = await LocationService().getCurrentLocation();
    if (!mounted) return;
    if (result == null) {
      setState(() => _loadingLocation = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Δεν ήταν δυνατή η λήψη τοποθεσίας. Ελέγξτε τις άδειες.')),
      );
      return;
    }
    setState(() {
      _latitude = result.latitude;
      _longitude = result.longitude;
      if ((result.address ?? '').isNotEmpty &&
          _locationNameCtrl.text.isEmpty) {
        _locationNameCtrl.text = result.address!;
      }
      _loadingLocation = false;
    });
  }

  void _clearLocation() {
    setState(() {
      _latitude = null;
      _longitude = null;
      _locationNameCtrl.clear();
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Επιλέξτε κατηγορία')),
      );
      return;
    }
    setState(() => _saving = true);

    final amount = double.parse(
        _amountCtrl.text.trim().replaceAll(',', '.'));
    final desc = _descCtrl.text.trim();
    final loc = _locationNameCtrl.text.trim();

    final provider = context.read<AppProvider>();
    if (_isEdit) {
      await provider.updateExpense(
        widget.expense!.copyWith(
          amount: amount,
          description: desc.isEmpty ? null : desc,
          categoryId: _selectedCategory!.id!,
          dateTime: _dateTime,
          latitude: _latitude,
          longitude: _longitude,
          locationName: loc.isEmpty ? null : loc,
        ),
      );
    } else {
      await provider.addExpense(
        amount: amount,
        description: desc.isEmpty ? null : desc,
        categoryId: _selectedCategory!.id!,
        dateTime: _dateTime,
        latitude: _latitude,
        longitude: _longitude,
        locationName: loc.isEmpty ? null : loc,
      );
    }

    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    // Resolve initial selected category for edit mode
    if (_isEdit && _selectedCategory == null) {
      _selectedCategory = provider.getCategoryById(widget.expense!.categoryId);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Επεξεργασία Εξόδου' : 'Νέο Έξοδο'),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              // ── Amount field — large and prominent ──
              _SectionLabel('Ποσό', icon: Icons.euro_rounded),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 6),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _amountCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'[0-9.,]')),
                  ],
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                  decoration: const InputDecoration(
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    prefixText: '€ ',
                    prefixStyle: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                    hintText: '0,00',
                    hintStyle: TextStyle(
                      color: Color(0xCCFFFFFF),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Συμπληρώστε το ποσό';
                    }
                    final parsed =
                        double.tryParse(v.trim().replaceAll(',', '.'));
                    if (parsed == null || parsed <= 0) {
                      return 'Δώστε έγκυρο ποσό';
                    }
                    return null;
                  },
                ),
              ),

              // ── Category ──
              const SizedBox(height: 24),
              _SectionLabel('Κατηγορία', icon: Icons.category_rounded),
              if (provider.categories.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.warning.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    'Δεν υπάρχουν κατηγορίες. Πηγαίνετε στην καρτέλα "Κατηγορίες" για να δημιουργήσετε.',
                    style: TextStyle(color: AppTheme.textPrimary(context)),
                  ),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: provider.categories.map((c) {
                    final visual = CategoryStyle.forName(c.name);
                    final selected = _selectedCategory?.id == c.id;
                    return InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => setState(() => _selectedCategory = c),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 9),
                        decoration: BoxDecoration(
                          color: selected
                              ? visual.color
                              : visual.color.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              visual.icon,
                              size: 16,
                              color: selected ? Colors.white : visual.color,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              c.name,
                              style: TextStyle(
                                color: selected
                                    ? Colors.white
                                    : visual.color,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

              // ── Description ──
              const SizedBox(height: 24),
              _SectionLabel('Περιγραφή',
                  icon: Icons.notes_rounded, optional: true),
              TextFormField(
                controller: _descCtrl,
                textCapitalization: TextCapitalization.none,
                decoration: const InputDecoration(
                  hintText: 'π.χ. Καφές και τοστ',
                ),
                maxLines: 2,
              ),

              // ── Date & time ──
              const SizedBox(height: 24),
              _SectionLabel('Ημερομηνία & Ώρα',
                  icon: Icons.event_rounded),
              InkWell(
                onTap: _pickDateTime,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceAlt(context),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.calendar_today_rounded,
                            size: 18, color: AppTheme.primary),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        Formatters.dateTimeFull(_dateTime),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary(context),
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.chevron_right_rounded,
                          color: AppTheme.textTertiary(context)),
                    ],
                  ),
                ),
              ),

              // ── Location ──
              const SizedBox(height: 24),
              _SectionLabel('Τοποθεσία',
                  icon: Icons.place_rounded, optional: true),
              if (_latitude != null && _longitude != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on_rounded,
                          color: AppTheme.accentDark, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Lat: ${_latitude!.toStringAsFixed(5)}\nLng: ${_longitude!.toStringAsFixed(5)}',
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: AppTheme.accentDark,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _clearLocation,
                        icon: const Icon(Icons.close_rounded,
                            color: AppTheme.accentDark),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _loadingLocation ? null : _getLocation,
                  icon: _loadingLocation
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child:
                              CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.my_location_rounded),
                  label: Text(_latitude != null
                      ? 'Ανανέωση τοποθεσίας'
                      : 'Λήψη τρέχουσας τοποθεσίας'),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _locationNameCtrl,
                textCapitalization: TextCapitalization.none,
                decoration: const InputDecoration(
                  labelText: 'Όνομα τοποθεσίας (προαιρετικό)',
                  hintText: 'π.χ. Mikel Coffee',
                  prefixIcon: Icon(Icons.place_outlined),
                ),
              ),

              // ── Save button ──
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          _isEdit
                              ? 'Αποθήκευση αλλαγών'
                              : 'Καταγραφή εξόδου',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w800),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool optional;
  const _SectionLabel(this.text,
      {required this.icon, this.optional = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 4, 0, 10),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppTheme.textSecondary(context)),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.textSecondary(context),
              letterSpacing: 0.3,
            ),
          ),
          if (optional) ...[
            const SizedBox(width: 6),
            Text(
              '· προαιρετικό',
              style: TextStyle(
                fontSize: 11.5,
                color: AppTheme.textTertiary(context),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
