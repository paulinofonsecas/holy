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

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: repaintKey,
      child: AspectRatio(
        aspectRatio: composition.aspectRatio.ratio,
        child: Stack(
          children: [
            // Background layer
            Positioned.fill(
              child: _buildBackground(),
            ),

            // Draggable text overlay
            Positioned.fill(
              child: GestureDetector(
                onPanUpdate: onTextDrag != null
                    ? (details) {
                        // Convert drag delta to normalized position [-1, 1]
                        final RenderBox box =
                            context.findRenderObject() as RenderBox;
                        final size = box.size;
                        final localPosition =
                            box.globalToLocal(details.globalPosition);

                        // Normalize to [-1, 1]
                        final normalizedX =
                            (localPosition.dx / size.width) * 2 - 1;
                        final normalizedY =
                            (localPosition.dy / size.height) * 2 - 1;

                        onTextDrag!(Offset(normalizedX, normalizedY));
                      }
                    : null,
                child: _buildTextOverlay(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground() {
    if (customBackgroundPath != null) {
      return Image.file(
        File(customBackgroundPath!),
        fit: BoxFit.cover,
      );
    }

    // Use color background with gradient effect
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            composition.backgroundColor,
            composition.backgroundColor.withOpacity(0.8),
          ],
        ),
      ),
    );
  }

  Widget _buildTextOverlay(BuildContext context) {
    // Convert normalized position [-1, 1] to alignment
    final alignment = Alignment(
      composition.textPosition.dx,
      composition.textPosition.dy,
    );

    // Check if we have multiple verses for enhanced rendering
    final hasMultipleVerses = composition.verses.length > 1;

    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(32.0), // Increased padding
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Main verse text - with verse numbers if multiple
            if (hasMultipleVerses)
              ..._buildMultiVerseText()
            else
              Text(
                composition.fullText,
                textAlign: composition.textAlign,
                style: TextStyle(
                  fontFamily: composition.fontFamily,
                  fontSize: composition.fontSize,
                  color: composition.textColor
                      .withOpacity(composition.textOpacity),
                  shadows: [
                    Shadow(
                      offset: const Offset(1, 1),
                      blurRadius: 3,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ],
                  height: 1.3,
                ),
              ),

            const SizedBox(height: 16),

            // Verse reference
            Text(
              composition.verseReference,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: composition.fontFamily,
                fontSize: composition.fontSize,
                color: composition.textColor
                    .withOpacity(composition.textOpacity * 0.8),
                fontStyle: FontStyle.italic,
                shadows: [
                  Shadow(
                    offset: const Offset(1, 1),
                    blurRadius: 3,
                    color: Colors.black.withOpacity(0.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildMultiVerseText() {
    final textStyle = TextStyle(
      fontFamily: composition.fontFamily,
      fontSize: composition.fontSize,
      color: composition.textColor.withOpacity(composition.textOpacity),
      shadows: [
        Shadow(
          offset: const Offset(1, 1),
          blurRadius: 3,
          color: Colors.black.withOpacity(0.5),
        ),
      ],
      height: 1.3,
    );

    final numberStyle = TextStyle(
      fontFamily: composition.fontFamily,
      fontSize: composition.fontSize * 0.75,
      color: composition.textColor.withOpacity(composition.textOpacity * 0.7),
      fontWeight: FontWeight.bold,
      shadows: [
        Shadow(
          offset: const Offset(1, 1),
          blurRadius: 3,
          color: Colors.black.withOpacity(0.5),
        ),
      ],
    );

    return composition.verses.asMap().entries.expand((entry) {
      final verse = entry.value;
      final isLast = entry.key == composition.verses.length - 1;

      return [
        RichText(
          textAlign: composition.textAlign,
          text: TextSpan(
            children: [
              TextSpan(
                text: '${verse.number} ',
                style: numberStyle,
              ),
              TextSpan(
                text: verse.text,
                style: textStyle,
              ),
            ],
          ),
        ),
        if (!isLast) const SizedBox(height: 6),
      ];
    }).toList();
  }
}
