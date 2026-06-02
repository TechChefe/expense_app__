// lib/screens/analysis_screen.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_provider.dart';
import '../utils/app_theme.dart';
import '../utils/category_style.dart';
import '../utils/formatters.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  late DateTime _start;
  late DateTime _end;
  List<CategoryAnalysis> _data = [];
  bool _loading = false;
  int _touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _end = now;
    _start = now.subtract(const Duration(days: 30));
    WidgetsBinding.instance.addPostFrameCallback((_) => _runAnalysis());
  }

  Future<void> _runAnalysis() async {
    setState(() => _loading = true);
    final provider = context.read<AppProvider>();
    final result = await provider.getAnalysis(_start, _end);
    if (!mounted) return;
    setState(() {
      _data = result;
      _loading = false;
    });
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _start : _end,
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
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _start = picked;
      } else {
        _end = picked;
      }
    });
    await _runAnalysis();
  }

  void _setPreset(int days) {
    setState(() {
      _end = DateTime.now();
      _start = _end.subtract(Duration(days: days));
    });
    _runAnalysis();
  }

  @override
  Widget build(BuildContext context) {
    final total = _data.fold<double>(0, (s, e) => s + e.total);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ανάλυση'),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _runAnalysis,
          color: AppTheme.primary,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
            children: [
              // ── DATE RANGE ROW ──
              Row(
                children: [
                  Expanded(
                      child: _DateBox(
                          label: 'Από',
                          date: _start,
                          onTap: () => _pickDate(true))),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _DateBox(
                          label: 'Έως',
                          date: _end,
                          onTap: () => _pickDate(false))),
                ],
              ),

              // ── PRESETS ──
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  _PresetChip('7 ημέρες', onTap: () => _setPreset(7)),
                  _PresetChip('30 ημέρες', onTap: () => _setPreset(30)),
                  _PresetChip('90 ημέρες', onTap: () => _setPreset(90)),
                ],
              ),

              // ── TOTAL CARD ──
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.30),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.insights_rounded,
                            color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Σύνολο εξόδων',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: total),
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeOutCubic,
                      builder: (_, v, __) => Text(
                        Formatters.currency(v),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_data.length} ${_data.length == 1 ? "κατηγορία" : "κατηγορίες"}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // ── PIE CHART ──
              if (_loading)
                const Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: Center(
                      child: CircularProgressIndicator(
                          color: AppTheme.primary)),
                )
              else if (_data.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 60),
                  child: _EmptyAnalysis(),
                )
              else ...[
                const SizedBox(height: 22),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.surface(context),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: Text(
                          'Κατανομή ανά κατηγορία',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary(context),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 220,
                        child: PieChart(
                          PieChartData(
                            sections: _buildSections(total),
                            centerSpaceRadius: 56,
                            sectionsSpace: 3,
                            pieTouchData: PieTouchData(
                              touchCallback: (event, response) {
                                setState(() {
                                  if (!event.isInterestedForInteractions ||
                                      response?.touchedSection == null) {
                                    _touchedIndex = -1;
                                    return;
                                  }
                                  _touchedIndex = response!
                                      .touchedSection!.touchedSectionIndex;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── RANKED LIST ──
                const SizedBox(height: 22),
                Padding(
                  padding: EdgeInsets.fromLTRB(4, 0, 0, 12),
                  child: Text(
                    'Κατάταξη κατηγοριών',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary(context),
                    ),
                  ),
                ),
                ..._data.asMap().entries.map((entry) {
                  final i = entry.key;
                  final item = entry.value;
                  final visual = CategoryStyle.forName(item.category.name);
                  final percent = total > 0 ? item.total / total : 0.0;

                  return TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: percent),
                    duration:
                        Duration(milliseconds: 600 + (i.clamp(0, 8) * 80)),
                    curve: Curves.easeOutCubic,
                    builder: (_, animatedPercent, __) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.surface(context),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    gradient: visual.gradient,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(visual.icon,
                                      color: Colors.white, size: 19),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    item.category.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.textPrimary(context),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  Formatters.currency(item.total),
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.textPrimary(context),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: animatedPercent,
                                minHeight: 8,
                                backgroundColor:
                                    visual.color.withValues(alpha: 0.12),
                                valueColor: AlwaysStoppedAnimation(
                                    visual.color),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${(animatedPercent * 100).toStringAsFixed(1)}% του συνόλου',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: AppTheme.textSecondary(context),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildSections(double total) {
    if (total == 0) return [];
    return _data.asMap().entries.map((entry) {
      final i = entry.key;
      final item = entry.value;
      final visual = CategoryStyle.forName(item.category.name);
      final isTouched = i == _touchedIndex;
      final radius = isTouched ? 78.0 : 64.0;
      final percentage = (item.total / total) * 100;

      return PieChartSectionData(
        color: visual.color,
        value: item.total,
        title: percentage >= 7 ? '${percentage.toStringAsFixed(0)}%' : '',
        radius: radius,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      );
    }).toList();
  }
}

class _DateBox extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onTap;
  const _DateBox({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surface(context),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.event_rounded,
                    color: AppTheme.primary, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.textSecondary(context),
                            fontWeight: FontWeight.w600)),
                    Text(
                      Formatters.dateShort(date),
                      style: TextStyle(
                          fontSize: 13.5,
                          color: AppTheme.textPrimary(context),
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _PresetChip(this.label, {required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: AppTheme.primary.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: AppTheme.primary,
            fontWeight: FontWeight.w700,
            fontSize: 12.5,
          ),
        ),
      ),
    );
  }
}

class _EmptyAnalysis extends StatelessWidget {
  const _EmptyAnalysis();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.insights_rounded,
                size: 44, color: AppTheme.primary),
          ),
          const SizedBox(height: 16),
          Text(
            'Δεν υπάρχουν έξοδα στην περίοδο',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary(context)),
          ),
          const SizedBox(height: 4),
          Text(
            'Δοκιμάστε διαφορετική χρονική περίοδο.',
            style: TextStyle(color: AppTheme.textSecondary(context)),
          ),
        ],
      ),
    );
  }
}
