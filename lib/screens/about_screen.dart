// lib/screens/about_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/app_provider.dart';
import '../utils/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Σχετικά'),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
          children: [
            // ── DEVELOPER (at the top) ──
            _SectionTitle('Δημιουργός'),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surface(context),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: AppTheme.accentGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.accent.withValues(alpha: 0.35),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.person_rounded,
                        color: Colors.white, size: 40),
                  ),
                  const SizedBox(height: 14),
                  InkWell(
                    onTap: () async {
                      final uri = Uri.parse(
                          'https://www.linkedin.com/in/stylianos-seferidis-093a65255/');
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri,
                            mode: LaunchMode.externalApplication);
                      }
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Στυλιανός Σεφερίδης',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primary,
                              decoration: TextDecoration.underline,
                              decorationColor: AppTheme.primary,
                              decorationThickness: 1.5,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            Icons.open_in_new_rounded,
                            size: 15,
                            color: AppTheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Μηχανική Λογισμικού για Διαδικτυακές\n& Φορητές Εφαρμογές',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary(context),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            // ── DARK MODE TOGGLE ──
            const SizedBox(height: 24),
            _SectionTitle('Εμφάνιση'),
            const _DarkModeCard(),

            // ── ABOUT PROJECT ──
            const SizedBox(height: 24),
            _SectionTitle('Σχετικά με το Project'),
            _InfoCard(
              icon: Icons.flag_rounded,
              title: 'Στόχος',
              text:
                  'Η δημιουργία μιας πλήρους εφαρμογής για κινητές συσκευές με '
                  'χρήση Flutter, που επιτρέπει στον χρήστη να καταγράφει, '
                  'επεξεργάζεται και αναλύει τα καθημερινά του έξοδα τοπικά '
                  'στη συσκευή του.',
            ),
            _InfoCard(
              icon: Icons.lightbulb_rounded,
              title: 'Σκεπτικό σχεδίασης',
              text:
                  'Δόθηκε έμφαση σε μοντέρνα οπτική σχεδίαση, ομαλές '
                  'αλληλεπιδράσεις και άμεση ανταπόκριση. Κάθε κατηγορία έχει '
                  'τη δική της οπτική ταυτότητα μέσω εικονιδίου και χρώματος, '
                  'ενώ προστέθηκαν διαδραστικά στοιχεία όπως φίλτρα '
                  'κατηγοριών και κινούμενα γραφήματα.',
            ),

            // ── FEATURES ──
            const SizedBox(height: 24),
            _SectionTitle('Λειτουργίες'),
            const _FeatureItem(
              icon: Icons.category_rounded,
              text:
                  'Δημιουργία και διαχείριση προσαρμοσμένων κατηγοριών εξόδων',
            ),
            const _FeatureItem(
              icon: Icons.add_circle_rounded,
              text:
                  'Καταγραφή εξόδων με ποσό, κατηγορία, ημερομηνία και τοποθεσία GPS',
            ),
            const _FeatureItem(
              icon: Icons.list_alt_rounded,
              text:
                  'Επιθεώρηση, επεξεργασία και διαγραφή καταχωρημένων εξόδων',
            ),
            const _FeatureItem(
              icon: Icons.pie_chart_rounded,
              text:
                  'Ανάλυση δαπανών ανά κατηγορία για επιλεγμένη χρονική περίοδο',
            ),

            // ── TECH STACK ──
            const SizedBox(height: 24),
            _SectionTitle('Τεχνολογίες'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const [
                _TechChip('Flutter', Icons.flutter_dash_rounded,
                    Color(0xFF02569B)),
                _TechChip('Dart', Icons.code_rounded, Color(0xFF0175C2)),
                _TechChip('SQLite', Icons.storage_rounded, Color(0xFF003B57)),
                _TechChip('Provider', Icons.share_rounded, Color(0xFF6C5CE7)),
                _TechChip('Geolocator', Icons.gps_fixed_rounded,
                    Color(0xFF00B894)),
                _TechChip('fl_chart', Icons.pie_chart_rounded,
                    Color(0xFFE17055)),
              ],
            ),

            // ── HERO (at the bottom) ──
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.30),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Icon(
                      Icons.payments_rounded,
                      color: Colors.white,
                      size: 44,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Expense App',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),
            Center(
              child: Text(
                '© 2026 — Expense App',
                style: TextStyle(
                  color: AppTheme.textTertiary(context),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── DARK MODE PILL TOGGLE ──────────────────────────────────────────────
class _DarkModeCard extends StatelessWidget {
  const _DarkModeCard();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isDark = provider.isDarkMode;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              color: AppTheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dark Mode',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isDark
                      ? 'Σκούρο θέμα ενεργοποιημένο'
                      : 'Φωτεινό θέμα ενεργοποιημένο',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: AppTheme.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
          // Custom pill toggle
          _PillToggle(
            value: isDark,
            onChanged: (_) => provider.toggleDarkMode(),
          ),
        ],
      ),
    );
  }
}

class _PillToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const _PillToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        width: 72,
        height: 36,
        decoration: BoxDecoration(
          color: value ? const Color(0xFF1A1A2E) : const Color(0xFFFF7A3D),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: (value
                      ? const Color(0xFF1A1A2E)
                      : const Color(0xFFFF7A3D))
                  .withValues(alpha: 0.35),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Sun / Moon icon
            AnimatedPositioned(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              left: value ? 8 : 36,
              top: 8,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                child: Icon(
                  value ? Icons.dark_mode : Icons.light_mode,
                  key: ValueKey(value),
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            // White circle indicator
            AnimatedPositioned(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              left: value ? 38 : 4,
              top: 4,
              child: Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── HELPERS ──────────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 0, 12),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w800,
          color: AppTheme.textPrimary(context),
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;
  const _InfoCard(
      {required this.icon, required this.title, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary(context))),
                const SizedBox(height: 6),
                Text(text,
                    style: TextStyle(
                        fontSize: 13.5,
                        color: AppTheme.textSecondary(context),
                        height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TechChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  const _TechChip(this.label, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;
  const _FeatureItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: AppTheme.accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.accentDark, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 13.5,
                  color: AppTheme.textPrimary(context),
                  height: 1.45,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
