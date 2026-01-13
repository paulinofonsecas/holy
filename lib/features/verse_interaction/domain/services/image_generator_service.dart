import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import '../../../../core/utils/web_utils.dart';

import '../models/verse_image_composition.dart';

class ImageGeneratorService {
  /// Captures a widget as PNG image with optional aspect ratio cropping
  Future<Uint8List?> captureAsPng(
    GlobalKey repaintBoundaryKey, {
    AspectRatioOption? targetAspectRatio,
  }) async {
    try {
      // Find the RenderRepaintBoundary from the key
      RenderRepaintBoundary? boundary = repaintBoundaryKey.currentContext
          ?.findRenderObject() as RenderRepaintBoundary?;

      if (boundary == null) {
        return null;
      }

      // Capture the full image
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);

      // If no aspect ratio cropping needed, return full image
      if (targetAspectRatio == null) {
        ByteData? byteData =
            await image.toByteData(format: ui.ImageByteFormat.png);
        return byteData?.buffer.asUint8List();
      }

      // Crop to target aspect ratio
      final croppedImage = await _cropToAspectRatio(image, targetAspectRatio);
      ByteData? byteData =
          await croppedImage.toByteData(format: ui.ImageByteFormat.png);

      // Clean up
      image.dispose();
      croppedImage.dispose();

      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error capturing image: $e');
      return null;
    }
  }

  /// Crops image to match target aspect ratio (center crop)
  Future<ui.Image> _cropToAspectRatio(
    ui.Image sourceImage,
    AspectRatioOption targetAspectRatio,
  ) async {
    final sourceWidth = sourceImage.width;
    final sourceHeight = sourceImage.height;
    final sourceRatio = sourceWidth / sourceHeight;
    final targetRatio = targetAspectRatio.ratio;

    int cropWidth, cropHeight, cropX, cropY;

    if (sourceRatio > targetRatio) {
      // Source is wider, crop width
      cropHeight = sourceHeight;
      cropWidth = (sourceHeight * targetRatio).round();
      cropX = (sourceWidth - cropWidth) ~/ 2;
      cropY = 0;
    } else {
      // Source is taller, crop height
      cropWidth = sourceWidth;
      cropHeight = (sourceWidth / targetRatio).round();
      cropX = 0;
      cropY = (sourceHeight - cropHeight) ~/ 2;
    }

    // Create a recorder to draw cropped portion
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Draw the cropped portion
    final srcRect = Rect.fromLTWH(
      cropX.toDouble(),
      cropY.toDouble(),
      cropWidth.toDouble(),
      cropHeight.toDouble(),
    );
    final dstRect =
        Rect.fromLTWH(0, 0, cropWidth.toDouble(), cropHeight.toDouble());

    canvas.drawImageRect(sourceImage, srcRect, dstRect, Paint());

    // Convert to image
    final picture = recorder.endRecording();
    return await picture.toImage(cropWidth, cropHeight);
  }

  /// Validates if text will fit at current font size
  /// Returns recommended font size if current is too large, otherwise null
  double? validateTextFit(
      String text, double currentFontSize, Size canvasSize) {
    // Rough heuristic: Character count vs canvas area
    final textLength = text.length;
    final canvasArea = canvasSize.width * canvasSize.height;
    final charDensity = textLength / canvasArea * 10000; // chars per 100x100 px

    if (charDensity > 50 && currentFontSize > 24) {
      return 24.0;
    } else if (charDensity > 30 && currentFontSize > 28) {
      return 28.0;
    }

    return null; // Size is OK
  }

  Future<bool> saveImageToGallery(Uint8List imageBytes) async {
    if (imageBytes.isEmpty) {
      return false;
    }

    final String fileName =
        'holy_verse_${DateTime.now().millisecondsSinceEpoch}';

    if (kIsWeb) {
      try {
        downloadBytes(imageBytes, fileName);
        return true;
      } catch (e) {
        debugPrint('Error downloading image on web: $e');
        return false;
      }
    }

    try {
      if (!await Gal.hasAccess()) {
        await Gal.requestAccess();

        if (!await Gal.hasAccess()) {
          return false;
        }
      }

      await Gal.putImageBytes(
        imageBytes,
        name: fileName,
      );

      return true;
    } on GalException catch (e) {
      debugPrint('Gal error while saving image: ${e.type}');
      return false;
    } catch (e) {
      debugPrint('Error saving image to gallery: $e');
      return false;
    }
  }
}
