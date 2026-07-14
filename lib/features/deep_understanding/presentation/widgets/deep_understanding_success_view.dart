import 'package:eu_sou/shared/widgets/max_width_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../bloc/deep_understanding_bloc.dart';
import 'deep_understanding_benchmarks.dart';
import 'deep_understanding_hero_banner.dart';

class DeepUnderstandingSuccessView extends StatelessWidget {
  final DeepUnderstandingSuccess state;
  final Function(String) onLinkTap;
  final double fontScale;

  const DeepUnderstandingSuccessView({
    super.key,
    required this.state,
    required this.onLinkTap,
    this.fontScale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark
        ? Theme.of(context).colorScheme.onSurface
        : const Color(0xFF2D1B13);
    final secondaryTextColor = isDark
        ? Theme.of(context).colorScheme.onSurfaceVariant
        : const Color(0xFF5A4034);
    final accentTextColor = isDark
        ? Theme.of(context).colorScheme.primary
        : const Color(0xFFB05B3B);
    final accentColor = isDark
        ? Theme.of(context).colorScheme.primary
        : const Color(0xFF3B5E53);
    final ruleColor = isDark
        ? Theme.of(context).colorScheme.outlineVariant
        : const Color(0xFFE6E0D4);
    final blockquoteBg = isDark
        ? Theme.of(context).colorScheme.surfaceContainer
        : const Color(0xFFFDF5EB);

    // Extract a short first-paragraph teaser from the result
    String teaser = state.result;
    teaser = teaser.replaceAll(RegExp(r'\*\*|\*|#|`|\[.*?\]\(.*?\)'), '');
    teaser = teaser.trim();
    if (teaser.length > 120) teaser = '${teaser.substring(0, 120)}...';

    return MaxWidthContainer(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DeepUnderstandingHeroBanner(
              query: state.query,
              teaser: teaser,
              isDark: isDark,
            ),

            // ── Main Markdown body ────────────────────────────────────────

            // ── Main Markdown body ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: MarkdownBody(
                data: state.result,
                selectable: true,
                onTapLink: (text, href, title) {
                  if (href != null) {
                    onLinkTap(href);
                  }
                },
                styleSheet: MarkdownStyleSheet(
                  p: TextStyle(
                    fontSize: 15 * fontScale,
                    height: 1.7,
                    color: primaryTextColor,
                  ),
                  h1: TextStyle(
                    fontSize: 24 * fontScale,
                    fontFamily: 'Georgia',
                    fontWeight: FontWeight.bold,
                    color: primaryTextColor,
                    height: 2.0,
                  ),
                  h2: TextStyle(
                    fontSize: 20 * fontScale,
                    fontFamily: 'Georgia',
                    fontWeight: FontWeight.bold,
                    color: primaryTextColor,
                    height: 2.0,
                    decoration: TextDecoration.none,
                  ),
                  h3: TextStyle(
                    fontSize: 16 * fontScale,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                  strong: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: primaryTextColor,
                  ),
                  em: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: secondaryTextColor,
                  ),
                  a: TextStyle(
                    color: accentTextColor,
                    decoration: TextDecoration.underline,
                  ),
                  blockquote: TextStyle(
                    fontSize: 15 * fontScale,
                    fontFamily: 'Georgia',
                    fontStyle: FontStyle.italic,
                    color: accentTextColor,
                    height: 1.6,
                  ),
                  blockquoteDecoration: BoxDecoration(
                    color: blockquoteBg,
                    borderRadius: BorderRadius.circular(4),
                    border: Border(
                      left: BorderSide(color: accentTextColor, width: 4),
                    ),
                  ),
                  blockquotePadding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  h2Padding: const EdgeInsets.only(top: 8),
                  h1Padding: const EdgeInsets.only(top: 8),
                  horizontalRuleDecoration: BoxDecoration(
                    border:
                        Border(bottom: BorderSide(color: ruleColor, width: 1)),
                  ),
                ),
              ),
            ),

            // ── Benchmarks ────────────────────────────────────────────────
            Container(
              margin: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: DeepUnderstandingBenchmarks(state: state),
            ),
          ],
        ),
      ),
    );
  }
}
