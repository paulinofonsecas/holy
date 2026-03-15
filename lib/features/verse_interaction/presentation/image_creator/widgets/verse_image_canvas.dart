import 'dart:io';

import 'package:flutter/material.dart';

import '../../../domain/models/verse_image_composition.dart';

class VerseImageCanvas extends StatelessWidget {
  final VerseImageComposition composition;
  final GlobalKey repaintKey;
  final Function(Offset)? onTextDrag;
  final String? customBackgroundPath;

  const VerseImageCanvas({
    super.key,
    required this.composition,
    required this.repaintKey,
    this.onTextDrag,
    this.customBackgroundPath,
  });

  // ── Parse helpers ────────────────────────────────────────────────────────────

  /// "João 3:16" → "João"
  String get _bookName {
    final ref = composition.verseReference.trim();
    final lastSpace = ref.lastIndexOf(' ');
    return lastSpace > 0 ? ref.substring(0, lastSpace) : ref;
  }

  /// "João 3:16" → "3:16"
  String get _chapterVerse {
    final ref = composition.verseReference.trim();
    final lastSpace = ref.lastIndexOf(' ');
    return lastSpace > 0 ? ref.substring(lastSpace + 1) : ref;
  }

  /// Chapter number parsed from "3:16" → "3"
  String get _chapterLabel {
    final cv = _chapterVerse;
    final colon = cv.indexOf(':');
    return colon > 0 ? cv.substring(0, colon) : cv;
  }

  /// Verse number(s) parsed from "3:16" → "16"
  String get _verseLabel {
    final cv = _chapterVerse;
    final colon = cv.indexOf(':');
    return colon > 0 ? cv.substring(colon + 1) : '';
  }

  // ── Colours ─────────────────────────────────────────────────────────────────

  Color get _textColor =>
      composition.textColor.withOpacity(composition.textOpacity);

  Color get _accentColor =>
      composition.textColor.withOpacity(composition.textOpacity * 0.55);

  Color get _dimColor =>
      composition.textColor.withOpacity(composition.textOpacity * 0.30);

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: repaintKey,
      child: AspectRatio(
        aspectRatio: composition.aspectRatio.ratio,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Background
            _buildBackground(),

            // 2. Subtle vignette overlay
            _buildVignette(),

            // 3. Decorative grid lines (very faint)
            _buildGridAccent(),

            // 4. Corner brackets
            ..._buildCorners(),

            // 5. Main draggable content
            Positioned.fill(
              child: GestureDetector(
                onPanUpdate: onTextDrag != null
                    ? (details) {
                        final box =
                            context.findRenderObject() as RenderBox;
                        final size = box.size;
                        final local =
                            box.globalToLocal(details.globalPosition);
                        onTextDrag!(Offset(
                          (local.dx / size.width) * 2 - 1,
                          (local.dy / size.height) * 2 - 1,
                        ));
                      }
                    : null,
                child: _buildContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Background ───────────────────────────────────────────────────────────────

  Widget _buildBackground() {
    if (customBackgroundPath != null) {
      return Stack(fit: StackFit.expand, children: [
        Image.file(File(customBackgroundPath!), fit: BoxFit.cover),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.25),
                Colors.black.withOpacity(0.55),
              ],
            ),
          ),
        ),
      ]);
    }

    // Solid-colour background with multi-stop gradient
    final base = composition.backgroundColor;
    final highlight = Color.lerp(base, Colors.white, 0.08)!;
    final shadow = Color.lerp(base, Colors.black, 0.22)!;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [highlight, base, shadow],
          stops: const [0.0, 0.50, 1.0],
        ),
      ),
    );
  }

  Widget _buildVignette() => Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.15,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.18),
            ],
          ),
        ),
      );

  // ── Subtle grid accent ───────────────────────────────────────────────────────

  Widget _buildGridAccent() {
    return Opacity(
      opacity: 0.045,
      child: CustomPaint(painter: _GridPainter(color: composition.textColor)),
    );
  }

  // ── Corner brackets ──────────────────────────────────────────────────────────

  List<Widget> _buildCorners() {
    const m = 14.0;
    const s = 22.0;
    final c = composition.textColor.withOpacity(0.28);

    Widget bracket({
      required bool top,
      required bool left,
    }) =>
        SizedBox(
          width: s,
          height: s,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                top: top
                    ? BorderSide(color: c, width: 1.5)
                    : BorderSide.none,
                bottom: !top
                    ? BorderSide(color: c, width: 1.5)
                    : BorderSide.none,
                left: left
                    ? BorderSide(color: c, width: 1.5)
                    : BorderSide.none,
                right: !left
                    ? BorderSide(color: c, width: 1.5)
                    : BorderSide.none,
              ),
            ),
          ),
        );

    return [
      Positioned(top: m, left: m, child: bracket(top: true, left: true)),
      Positioned(top: m, right: m, child: bracket(top: true, left: false)),
      Positioned(bottom: m, left: m, child: bracket(top: false, left: true)),
      Positioned(bottom: m, right: m, child: bracket(top: false, left: false)),
    ];
  }

  // ── Main content ─────────────────────────────────────────────────────────────

  Widget _buildContent() {
    final alignment = Alignment(
      composition.textPosition.dx,
      composition.textPosition.dy,
    );

    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildHeader(),
            const SizedBox(height: 18),
            _buildDivider(),
            const SizedBox(height: 18),
            _buildVerseBody(),
            const SizedBox(height: 18),
            _buildDivider(),
            const SizedBox(height: 14),
            _buildVersionBadge(),
          ],
        ),
      ),
    );
  }

  // ── Header: book + chapter:verse ─────────────────────────────────────────────

  Widget _buildHeader() {
    final bookStyle = TextStyle(
      fontFamily: composition.fontFamily,
      fontSize: composition.fontSize * 0.52,
      color: _textColor,
      fontWeight: FontWeight.w600,
      letterSpacing: 3.5,
      height: 1.2,
      shadows: _textShadows(),
    );

    final refStyle = TextStyle(
      fontFamily: composition.fontFamily,
      fontSize: composition.fontSize * 0.42,
      color: _accentColor,
      letterSpacing: 1.8,
      height: 1.4,
      shadows: _textShadows(),
    );

    final chap = _chapterLabel;
    final verse = _verseLabel;
    final refText =
        verse.isNotEmpty ? 'Cap. $chap  •  v. $verse' : _chapterVerse;

    return Column(
      children: [
        Text(
          _bookName.toUpperCase(),
          textAlign: TextAlign.center,
          style: bookStyle,
        ),
        if (refText.isNotEmpty) ...[
          const SizedBox(height: 5),
          Text(refText, textAlign: TextAlign.center, style: refStyle),
        ],
      ],
    );
  }

  // ── Thin divider ─────────────────────────────────────────────────────────────

  Widget _buildDivider() => Center(
        child: SizedBox(
          width: 48,
          child: Divider(color: _dimColor, thickness: 1.0, height: 1),
        ),
      );

  // ── Verse text ───────────────────────────────────────────────────────────────

  Widget _buildVerseBody() {
    final hasMultiple = composition.verses.length > 1;
    return hasMultiple ? _buildMultiVerseText() : _buildSingleVerseText();
  }

  Widget _buildSingleVerseText() {
    final verse = composition.verses.first;

    final numberStyle = TextStyle(
      fontFamily: composition.fontFamily,
      fontSize: composition.fontSize * 0.62,
      color: _accentColor,
      fontWeight: FontWeight.w700,
      shadows: _textShadows(),
    );

    final textStyle = TextStyle(
      fontFamily: composition.fontFamily,
      fontSize: composition.fontSize,
      color: _textColor,
      fontStyle: FontStyle.italic,
      height: 1.45,
      shadows: _textShadows(),
    );

    final quoteStyle = TextStyle(
      fontFamily: composition.fontFamily,
      fontSize: composition.fontSize * 2.2,
      color: _dimColor,
      height: 0.6,
      shadows: _textShadows(),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Opening decorative quote
        Align(
          alignment: Alignment.centerLeft,
          child: Text('\u201C', style: quoteStyle),
        ),
        const SizedBox(height: 4),
        RichText(
          textAlign: composition.textAlign,
          text: TextSpan(
            children: [
              TextSpan(text: '${verse.number} ', style: numberStyle),
              TextSpan(text: verse.text, style: textStyle),
            ],
          ),
        ),
        const SizedBox(height: 4),
        // Closing decorative quote
        Align(
          alignment: Alignment.centerRight,
          child: Text('\u201D', style: quoteStyle),
        ),
      ],
    );
  }

  Widget _buildMultiVerseText() {
    final textStyle = TextStyle(
      fontFamily: composition.fontFamily,
      fontSize: composition.fontSize,
      color: _textColor,
      fontStyle: FontStyle.italic,
      height: 1.45,
      shadows: _textShadows(),
    );

    final numberStyle = TextStyle(
      fontFamily: composition.fontFamily,
      fontSize: composition.fontSize * 0.62,
      color: _accentColor,
      fontWeight: FontWeight.w700,
      shadows: _textShadows(),
    );

    return Column(
      children: composition.verses.asMap().entries.expand((entry) {
        final verse = entry.value;
        final isLast = entry.key == composition.verses.length - 1;
        return [
          RichText(
            textAlign: composition.textAlign,
            text: TextSpan(
              children: [
                TextSpan(text: '${verse.number} ', style: numberStyle),
                TextSpan(text: verse.text, style: textStyle),
              ],
            ),
          ),
          if (!isLast) const SizedBox(height: 8),
        ];
      }).toList(),
    );
  }

  // ── Version badge ────────────────────────────────────────────────────────────

  Widget _buildVersionBadge() {
    final version = composition.versionId.isNotEmpty
        ? composition.versionId.toUpperCase()
        : composition.verseReference;

    final style = TextStyle(
      fontFamily: composition.fontFamily,
      fontSize: composition.fontSize * 0.42,
      color: _accentColor,
      letterSpacing: 2.8,
      fontWeight: FontWeight.w300,
      shadows: _textShadows(),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(color: _dimColor, width: 0.8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(version, style: style, textAlign: TextAlign.center),
    );
  }

  // ── Shadow helper ────────────────────────────────────────────────────────────

  List<Shadow> _textShadows() => [
        Shadow(
          offset: const Offset(0, 1),
          blurRadius: 6,
          color: Colors.black.withOpacity(0.35),
        ),
      ];
}

// ── Custom painter for subtle grid ───────────────────────────────────────────

class _GridPainter extends CustomPainter {
  final Color color;
  _GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.8;
    const step = 32.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => old.color != color;
}
