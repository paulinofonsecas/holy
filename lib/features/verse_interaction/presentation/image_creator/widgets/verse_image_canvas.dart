import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:eu_sou/shared/cubit/bible_version_cubit.dart';
import 'package:eu_sou/shared/widgets/app_huge_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../domain/models/verse_image_composition.dart';

class VerseImageCanvas extends StatefulWidget {
  final VerseImageComposition composition;
  final GlobalKey repaintKey;
  final bool isEditing;
  final void Function(List<CanvasElement>)? onElementsUpdate;
  final String? customBackgroundPath;
  final Uint8List? customBackgroundBytes;

  const VerseImageCanvas({
    super.key,
    required this.composition,
    required this.repaintKey,
    this.isEditing = true,
    this.onElementsUpdate,
    this.customBackgroundPath,
    this.customBackgroundBytes,
  });

  @override
  State<VerseImageCanvas> createState() => _VerseImageCanvasState();
}

class _VerseImageCanvasState extends State<VerseImageCanvas> {
  CanvasElementType? _selected;
  late List<CanvasElement> _elements;

  double _scaleStart = 1.0;
  double _rotationStart = 0.0;

  @override
  void initState() {
    super.initState();
    _elements = List.from(widget.composition.elements);
  }

  @override
  void didUpdateWidget(VerseImageCanvas old) {
    super.didUpdateWidget(old);
    if (!widget.isEditing) _selected = null;
    if (old.composition.elements != widget.composition.elements &&
        widget.composition.elements != _elements) {
      _elements = List.from(widget.composition.elements);
    }
  }

  CanvasElement _el(CanvasElementType t) =>
      _elements.firstWhere((e) => e.type == t);

  void _update(CanvasElement updated) {
    setState(() {
      final idx = _elements.indexWhere((e) => e.type == updated.type);
      if (idx >= 0) _elements[idx] = updated;
    });
    widget.onElementsUpdate?.call(List.unmodifiable(_elements));
  }

  // ── Colour helpers ─────────────────────────────────────────────────────────

  Color get _textColor =>
      widget.composition.textColor.withOpacity(widget.composition.textOpacity);

  Color get _accentColor => widget.composition.textColor
      .withOpacity(widget.composition.textOpacity * 0.55);

  Color get _dimColor => widget.composition.textColor
      .withOpacity(widget.composition.textOpacity * 0.30);

  // ── Reference helpers ──────────────────────────────────────────────────────

  String get _bookName {
    final ref = widget.composition.verseReference.trim();
    final ls = ref.lastIndexOf(' ');
    return ls > 0 ? ref.substring(0, ls) : ref;
  }

  String get _chapterVerse {
    final ref = widget.composition.verseReference.trim();
    final ls = ref.lastIndexOf(' ');
    return ls > 0 ? ref.substring(ls + 1) : ref;
  }

  String get _chapterLabel {
    final cv = _chapterVerse;
    final c = cv.indexOf(':');
    return c > 0 ? cv.substring(0, c) : cv;
  }

  String get _verseLabel {
    final cv = _chapterVerse;
    final c = cv.indexOf(':');
    return c > 0 ? cv.substring(c + 1) : '';
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: widget.repaintKey,
      child: AspectRatio(
        aspectRatio: widget.composition.aspectRatio.ratio,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final sz = constraints.biggest;
            return GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => setState(() => _selected = null),
              child: Stack(
                fit: StackFit.expand,
                clipBehavior: Clip.hardEdge,
                children: [
                  _buildBackground(),
                  _buildVignette(),
                  _buildGridAccent(),
                  ..._buildCorners(),
                  // ── Draggable verse body sticker ─────────────────────────
                  _positionedEl(
                      CanvasElementType.verseBody, sz, _buildVerseBody(sz)),
                  // ── Safe-zone metadata rendered on top (always readable) ──
                  Positioned(
                    top: 28,
                    left: 24,
                    right: 24,
                    child: IgnorePointer(child: _buildHeader()),
                  ),
                  Positioned(
                    bottom: 24,
                    left: 24,
                    right: 24,
                    child: IgnorePointer(child: _buildBadge()),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Positioned + interactive wrapper ──────────────────────────────────────

  Widget _positionedEl(CanvasElementType type, Size sz, Widget child) {
    final el = _el(type);
    final isSelected = widget.isEditing && _selected == type;

    final px = (el.position.dx + 1) / 2 * sz.width;
    final py = (el.position.dy + 1) / 2 * sz.height;

    return Positioned(
      left: px,
      top: py,
      child: FractionalTranslation(
        translation: const Offset(-0.5, -0.5),
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..rotateZ(el.rotation)
            ..scale(el.scale),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.isEditing
                ? () => setState(() => _selected = type)
                : null,
            onScaleStart: widget.isEditing
                ? (d) {
                    _scaleStart = el.scale;
                    _rotationStart = el.rotation;
                    setState(() => _selected = type);
                  }
                : null,
            onScaleUpdate: widget.isEditing
                ? (d) {
                    final current = _el(type);
                    final ndx = d.focalPointDelta.dx / sz.width * 2;
                    final ndy = d.focalPointDelta.dy / sz.height * 2;
                    _update(current.copyWith(
                      position: Offset(
                        (current.position.dx + ndx).clamp(-1.0, 1.0),
                        (current.position.dy + ndy).clamp(-1.0, 1.0),
                      ),
                      scale: (_scaleStart * d.scale).clamp(0.25, 4.0),
                      rotation: _rotationStart + d.rotation,
                    ));
                  }
                : null,
            child: _selectionWrapper(isSelected, child),
          ),
        ),
      ),
    );
  }

  Widget _selectionWrapper(bool selected, Widget child) {
    if (!selected) return child;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CustomPaint(
          painter: _DashedBorderPainter(
            color: Colors.white.withOpacity(0.85),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: child,
          ),
        ),
        // Corner dots
        Positioned(left: -5, top: -5, child: _cornerDot()),
        Positioned(right: -5, top: -5, child: _cornerDot()),
        Positioned(left: -5, bottom: -5, child: _cornerDot()),
        // Scale handle (bottom-right, slightly larger)
        Positioned(
          right: -6,
          bottom: -6,
          child: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: const AppHugeIcon(
                icon: HugeIcons.strokeRoundedArrowExpand01,
                size: 8,
                color: Colors.black54),
          ),
        ),
      ],
    );
  }

  Widget _cornerDot() => Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 3,
              spreadRadius: 1,
            ),
          ],
        ),
      );

  // ── Background ─────────────────────────────────────────────────────────────

  Widget _buildBackground() {
    if (widget.customBackgroundPath != null) {
      final comp = widget.composition;
      Widget image = widget.customBackgroundBytes != null
          ? Image.memory(
              widget.customBackgroundBytes!,
              fit: BoxFit.cover,
              gaplessPlayback: true,
            )
          : const SizedBox.expand(child: ColoredBox(color: Colors.grey));

      image = _applyImageFilters(image, comp);

      return Stack(fit: StackFit.expand, children: [
        image,
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
    final base = widget.composition.backgroundColor;
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

  Widget _applyImageFilters(Widget image, VerseImageComposition comp) {
    final blur = comp.backgroundBlur;
    final brightness = comp.backgroundBrightness;
    final contrast = comp.backgroundContrast;
    final saturation = comp.backgroundSaturation;

    final hasFilters =
        blur > 0 || brightness != 0.0 || contrast != 1.0 || saturation != 1.0;

    if (!hasFilters) return image;

    Widget filtered = image;

    if (blur > 0) {
      filtered = ImageFiltered(
        imageFilter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: filtered,
      );
    }

    if (brightness != 0.0 || contrast != 1.0 || saturation != 1.0) {
      final b = brightness;
      final c = contrast;
      final s = saturation;

      // Saturation via luminance weighting
      const lr = 0.2126;
      const lg = 0.7152;
      const lb = 0.0722;

      final sr = (1 - s) * lr;
      final sg = (1 - s) * lg;
      final sb = (1 - s) * lb;

      // Combined 4x5 color matrix: brightness + contrast + saturation
      final List<double> matrix = [
        c * (sr + s),
        c * sg,
        c * sb,
        0,
        b,
        sr * c,
        c * (sg + s),
        c * sb,
        0,
        b,
        sr * c,
        sg * c,
        c * (sb + s),
        0,
        b,
        0.0,
        0.0,
        0.0,
        1.0,
        0.0,
      ];

      filtered = ColorFiltered(
        colorFilter: ColorFilter.matrix(matrix),
        child: filtered,
      );
    }

    return filtered;
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

  Widget _buildGridAccent() => Opacity(
        opacity: 0.045,
        child: CustomPaint(
            painter: _GridPainter(color: widget.composition.textColor)),
      );

  List<Widget> _buildCorners() {
    const m = 14.0, s = 22.0;
    final c = widget.composition.textColor.withOpacity(0.28);
    Widget b({required bool top, required bool left}) => SizedBox(
          width: s,
          height: s,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                top: top ? BorderSide(color: c, width: 1.5) : BorderSide.none,
                bottom:
                    !top ? BorderSide(color: c, width: 1.5) : BorderSide.none,
                left: left ? BorderSide(color: c, width: 1.5) : BorderSide.none,
                right:
                    !left ? BorderSide(color: c, width: 1.5) : BorderSide.none,
              ),
            ),
          ),
        );
    return [
      Positioned(top: m, left: m, child: b(top: true, left: true)),
      Positioned(top: m, right: m, child: b(top: true, left: false)),
      Positioned(bottom: m, left: m, child: b(top: false, left: true)),
      Positioned(bottom: m, right: m, child: b(top: false, left: false)),
    ];
  }

  // ── Element widgets ────────────────────────────────────────────────────────

  Widget _buildHeader() {
    final comp = widget.composition;
    final bookStyle = TextStyle(
      fontFamily: comp.fontFamily,
      fontSize: comp.fontSize * 0.52,
      color: _textColor,
      fontWeight: FontWeight.w600,
      letterSpacing: 3.5,
      height: 1.2,
      shadows: _shadows(),
    );
    final refStyle = TextStyle(
      fontFamily: comp.fontFamily,
      fontSize: comp.fontSize * 0.42,
      color: _accentColor,
      letterSpacing: 1.8,
      height: 1.4,
      shadows: _shadows(),
    );
    final chap = _chapterLabel;
    final verse = _verseLabel;
    final refText =
        verse.isNotEmpty ? 'Cap. $chap  •  v. $verse' : _chapterVerse;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(_bookName.toUpperCase(),
            textAlign: TextAlign.center, style: bookStyle),
        if (refText.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(refText, textAlign: TextAlign.center, style: refStyle),
        ],
      ],
    );
  }

  Widget _buildVerseBody(Size sz) {
    final comp = widget.composition;
    final hasMulti = comp.verses.length > 1;
    final quoteStyle = TextStyle(
      fontFamily: comp.fontFamily,
      fontSize: comp.fontSize * 2.2,
      color: _dimColor,
      height: 0.6,
      shadows: _shadows(),
    );
    final textStyle = TextStyle(
      fontFamily: comp.fontFamily,
      fontSize: comp.fontSize,
      color: _textColor,
      fontStyle: FontStyle.italic,
      height: 1.45,
      shadows: _shadows(),
    );
    final numStyle = TextStyle(
      fontFamily: comp.fontFamily,
      fontSize: comp.fontSize * 0.62,
      color: _accentColor,
      fontWeight: FontWeight.w700,
      shadows: _shadows(),
    );

    Widget body;
    if (!hasMulti) {
      final verse = comp.verses.first;
      body = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text('\u201C', style: quoteStyle),
          ),
          const SizedBox(height: 4),
          RichText(
            textAlign: comp.textAlign,
            text: TextSpan(children: [
              TextSpan(text: '${verse.number} ', style: numStyle),
              TextSpan(text: verse.text, style: textStyle),
            ]),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text('\u201D', style: quoteStyle),
          ),
        ],
      );
    } else {
      body = Column(
        mainAxisSize: MainAxisSize.min,
        children: comp.verses.asMap().entries.expand((e) {
          final isLast = e.key == comp.verses.length - 1;
          return [
            RichText(
              textAlign: comp.textAlign,
              text: TextSpan(children: [
                TextSpan(text: '${e.value.number} ', style: numStyle),
                TextSpan(text: e.value.text, style: textStyle),
              ]),
            ),
            if (!isLast) const SizedBox(height: 8),
          ];
        }).toList(),
      );
    }

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: sz.width * 0.78),
      child: body,
    );
  }

  Widget _buildBadge() {
    final comp = widget.composition;
    final version = comp.versionId.isNotEmpty
        ? comp.versionId.toUpperCase()
        : comp.verseReference;
    final style = TextStyle(
      fontFamily: comp.fontFamily,
      fontSize: comp.fontSize * 0.42,
      color: _accentColor,
      letterSpacing: 2.8,
      fontWeight: FontWeight.w300,
      shadows: _shadows(),
    );
    final currentVersion = context.read<BibleVersionCubit>().state;

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        child: Column(
          children: [
            Text('Eu Sou', style: style, textAlign: TextAlign.center),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(version, style: style, textAlign: TextAlign.center),
                Text(' •   ', style: style, textAlign: TextAlign.center),
                Text(fullVersionName(currentVersion.version.name),
                    style: style, textAlign: TextAlign.center),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String fullVersionName(String versionId) {
    switch (versionId.toLowerCase()) {
      case 'nvi':
        return 'Nova Versão Internacional';
      case 'ara':
        return 'Almeida Revista e Atualizada';
      case 'acf':
        return 'Almeida Corrigida Fiel';
      case 'nvt':
        return 'Nova Versão Transformadora';
      case 'nvt-pt':
        return 'Nova Versão Transformadora (PT)';
      default:
        return versionId;
    }
  }

  List<Shadow> _shadows() => [
        Shadow(
          offset: const Offset(0, 1),
          blurRadius: 6,
          color: Colors.black.withOpacity(0.35),
        ),
      ];
}

// ── Dashed border painter ─────────────────────────────────────────────────────

class _DashedBorderPainter extends CustomPainter {
  final Color color;

  const _DashedBorderPainter({required this.color});

  static const double strokeWidth = 1.5;
  static const double dashWidth = 6;
  static const double dashSpace = 4;
  static const double borderRadius = 6;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    final path = Path()
      ..addRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(borderRadius)));

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + dashWidth),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) => old.color != color;
}

// ── Grid painter ──────────────────────────────────────────────────────────────

class _GridPainter extends CustomPainter {
  final Color color;
  const _GridPainter({required this.color});

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
