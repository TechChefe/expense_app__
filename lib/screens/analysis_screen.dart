// lib/screens/analysis_screen.dart
// ΠΧ4 – Ανάλυση εξόδων

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_provider.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  DateTime _start = DateTime.now().subtract(const Duration(days: 30));
  DateTime _end = DateTime.now();
  List<CategoryAnalysis>? _results;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _runAnalysis());
  }

  Future<void> _runAnalysis() async {
    setState(() => _loading = true);
    try {
      final results =
          await context.read<AppProvider>().getAnalysis(_start, _end);
      if (mounted) setState(() => _results = results);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _start : _end,
      firstDate: isStart ? DateTime(2020) : _start,
      lastDate: isStart
          ? _end
          : DateTime.now().add(const Duration(days: 1)),
    );
    if (picked == null) return;
    setState(() => isStart ? _start = picked : _end = picked);
    await _runAnalysis();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ανάλυση Εξόδων')),
      body: Column(
        children: [
          // Date range picker bar
          Container(
            color: AppTheme.primary,
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                    child: _DateBtn(
                        label: 'Από',
                        date: _start,
                        onTap: () => _pickDate(true))),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.arrow_forward,
                      color: Colors.white70, size: 18),
                ),
                Expanded(
                    child: _DateBtn(
                        label: 'Έως',
                        date: _end,
                        onTap: () => _pickDate(false))),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: _runAnalysis,
                  tooltip: 'Ανανέωση',
                ),
              ],
            ),
          ),

          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : (_results == null || _results!.isEmpty)
                    ? _EmptyState(start: _start, end: _end)
                    : _Results(results: _results!),
          ),
        ],
      ),
    );
  }
}

class _DateBtn extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onTap;
  const _DateBtn(
      {required this.label, required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 10, color: Colors.white70)),
            Text(Formatters.dateShort(date),
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final DateTime start;
  final DateTime end;
  const _EmptyState({required this.start, required this.end});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart_outlined,
              size: 72,
              color: AppTheme.textSecondary.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          const Text('Δεν βρέθηκαν έξοδα',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary)),
          const SizedBox(height: 8),
          Text(
            'για την περίοδο\n${Formatters.dateShort(start)} – ${Formatters.dateShort(end)}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _Results extends StatelessWidget {
  final List<CategoryAnalysis> results;
  const _Results({required this.results});

  @override
  Widget build(BuildContext context) {
    final total = results.fold<double>(0.0, (s, r) => s + r.total);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Summary card
        Card(
          color: AppTheme.primary,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              const Text('Συνολικά Έξοδα',
                  style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 4),
              Text(Formatters.currency(total),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w800)),
              Text('${results.length} κατηγορίες',
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 12)),
            ]),
          ),
        ),
        const SizedBox(height: 16),

        // Pie chart
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Κατανομή',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: AppTheme.textPrimary)),
                const SizedBox(height: 16),
                SizedBox(
                  height: 220,
                  child: PieChart(PieChartData(
                    sections: results.asMap().entries.map((entry) {
                      final i = entry.key;
                      final r = entry.value;
                      final color = AppTheme.categoryColors[
                          i % AppTheme.categoryColors.length];
                      final pct =
                          total > 0 ? r.total / total * 100 : 0.0;
                      return PieChartSectionData(
                        value: r.total,
                        color: color,
                        radius: 80,
                        title: '${pct.toStringAsFixed(1)}%',
                        titleStyle: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      );
                    }).toList(),
                    centerSpaceRadius: 40,
                    sectionsSpace: 2,
                  )),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: results.asMap().entries.map((entry) {
                    final color = AppTheme.categoryColors[
                        entry.key % AppTheme.categoryColors.length];
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                                color: color, shape: BoxShape.circle)),
                        const SizedBox(width: 4),
                        Text(entry.value.category.name,
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary)),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        const Text('Κατατάξη κατηγοριών',
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: AppTheme.textPrimary)),
        const SizedBox(height: 8),

        // Ranked list – descending
        ...results.asMap().entries.map((entry) {
          final i = entry.key;
          final r = entry.value;
          final color = AppTheme
              .categoryColors[i % AppTheme.categoryColors.length];
          final pct = total > 0 ? r.total / total : 0.0;

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          shape: BoxShape.circle),
                      child: Center(
                        child: Text('${i + 1}',
                            style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.w800,
                                fontSize: 14)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(r.category.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: AppTheme.textPrimary)),
                    ),
                    Text(Formatters.currency(r.total),
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: AppTheme.primary)),
                  ]),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct,
                      minHeight: 6,
                      backgroundColor: color.withValues(alpha: 0.15),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('${(pct * 100).toStringAsFixed(1)}% του συνόλου',
                      style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary)),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
