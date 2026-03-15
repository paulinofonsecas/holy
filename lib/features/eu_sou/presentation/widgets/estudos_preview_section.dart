import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../deep_understanding/data/models/analysis_session.dart';
import '../../../deep_understanding/presentation/bloc/deep_understanding_bloc.dart';
import '../../../deep_understanding/presentation/pages/deep_understanding_history_page.dart';
import '../../../deep_understanding/presentation/pages/deep_understanding_page.dart';
import '../../data/models/analysis_session_preview.dart';

/// Preview horizontal dos últimos estudos dentro da aba EU.
class EstudosPreviewSection extends StatelessWidget {
  final List<AnalysisSessionPreview> studies;

  const EstudosPreviewSection({super.key, required this.studies});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor =
        isDark ? colorScheme.primary : const Color(0xFF3B5E53);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Divisor de seção
        Divider(color: colorScheme.onSurface.withOpacity(0.12), height: 1),
        const SizedBox(height: 28),

        // Label de seção
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'ESTUDOS E REFLEXÕES',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.5,
                color: colorScheme.onSurface.withOpacity(0.40),
              ),
            ),
            GestureDetector(
              onTap: () => _navigateToAllStudies(context),
              child: Text(
                'VER TODOS →',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: accentColor,
                  decoration: TextDecoration.underline,
                  decorationColor: accentColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        if (studies.isEmpty)
          _EmptyStudiesHint(accentColor: accentColor)
        else
          ...studies.map((s) => _StudyCard(study: s, accentColor: accentColor)),

        const SizedBox(height: 8),
      ],
    );
  }

  void _navigateToAllStudies(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<DeepUnderstandingBloc>(),
          child: const DeepUnderstandingHistoryPage(),
        ),
      ),
    );
  }
}

class _StudyCard extends StatelessWidget {
  final AnalysisSessionPreview study;
  final Color accentColor;

  const _StudyCard({required this.study, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? colorScheme.surfaceContainer : Colors.white;
    final borderColor = isDark
        ? colorScheme.outlineVariant
        : const Color(0xFFE6E0D4);

    return GestureDetector(
      onTap: () => _openStudy(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor, width: 1),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ESTUDO BÍBLICO',
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: colorScheme.onSurface.withOpacity(0.40),
                  ),
                ),
                Text(
                  DateFormat('dd/MM').format(study.updatedAt),
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: colorScheme.onSurface.withOpacity(0.40),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              study.query,
              style: GoogleFonts.playfairDisplay(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              '"${study.snippet}"',
              style: GoogleFonts.playfairDisplay(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: colorScheme.onSurface.withOpacity(0.60),
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (study.status == 'completed') ...[
                  Text(
                    'ANALISAR',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: accentColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
                Icon(Icons.arrow_forward,
                    size: 14,
                    color: study.status == 'completed'
                        ? accentColor
                        : colorScheme.onSurface.withOpacity(0.30)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openStudy(BuildContext context) {
    if (study.status != 'completed') return;

    final sessions = context.read<DeepUnderstandingBloc>().state.sessions;
    final session = sessions
        .cast<AnalysisSession?>()
        .firstWhere((s) => s?.sessionId == study.sessionId, orElse: () => null);

    if (session == null) return;

    context
        .read<DeepUnderstandingBloc>()
        .add(ViewSessionEvent(session));

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DeepUnderstandingPage()),
    );
  }
}

class _EmptyStudiesHint extends StatelessWidget {
  final Color accentColor;
  const _EmptyStudiesHint({required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        'Nenhum estudo ainda. Selecione versículos na Bíblia e inicie uma análise profunda.',
        style: GoogleFonts.inter(
          fontSize: 14,
          fontStyle: FontStyle.italic,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.45),
          height: 1.6,
        ),
      ),
    );
  }
}
