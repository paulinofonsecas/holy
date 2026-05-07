import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AnalysisBanner extends StatelessWidget {
  final double progress;

  const AnalysisBanner({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    final pct = (progress * 100).round();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          color: const Color(0xFF1A1A2E).withOpacity(0.93),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            'Gerando entendimento: $pct%',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.90),
              letterSpacing: 0.3,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        LinearProgressIndicator(
          value: progress > 0 ? progress : null,
          minHeight: 3,
          backgroundColor: const Color(0xFF2D2D4E),
          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6C8EFF)),
        ),
      ],
    );
  }
}
