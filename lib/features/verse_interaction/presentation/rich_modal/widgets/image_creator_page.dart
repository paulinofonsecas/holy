import 'dart:typed_data';

import 'package:eu_sou/shared/bible_models.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:stacked/stacked.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

import '../../../domain/services/image_generator_service.dart';
import '../../image_creator/image_creator_viewmodel.dart';
import '../../image_creator/widgets/aspect_ratio_selector.dart';
import '../../image_creator/widgets/background_picker.dart';
import '../../image_creator/widgets/typography_controls.dart';
import '../../image_creator/widgets/verse_image_canvas.dart';

class ImageCreatorPage extends StatefulWidget {
  final List<BibleVerse> verses;
  final String verseReference;

  const ImageCreatorPage({
    super.key,
    required this.verses,
    required this.verseReference,
  });

  static WoltModalSheetPage build({
    required BuildContext context,
    required List<BibleVerse> verses,
    required String verseReference,
  }) {
    return WoltModalSheetPage(
      hasTopBarLayer: true,
      isTopBarLayerAlwaysVisible: true,
      topBarTitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Criar Imagem',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
          ),
          if (verses.length > 1)
            Text(
              '${verses.length} versículos selecionados',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: Colors.grey.shade600,
              ),
            ),
        ],
      ),
      trailingNavBarWidget: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () => Navigator.of(context).pop(),
      ),
      child: ImageCreatorPage(
        verses: verses,
        verseReference: verseReference,
      ),
    );
  }

  @override
  State<ImageCreatorPage> createState() => _ImageCreatorPageState();
}

class _ImageCreatorPageState extends State<ImageCreatorPage> {
  late GlobalKey _repaintKey;
  final ImageGeneratorService _imageService = ImageGeneratorService();

  @override
  void initState() {
    super.initState();
    _repaintKey = GlobalKey();
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ImageCreatorViewModel>.reactive(
      viewModelBuilder: () => ImageCreatorViewModel(),
      onViewModelReady: (viewModel) =>
          viewModel.initialize(widget.verses, widget.verseReference),
      builder: (context, viewModel, child) {
        if (viewModel.isBusy) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(48.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (viewModel.composition == null) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(48.0),
              child: Text('Erro ao carregar composição'),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Canvas Preview - Constrained for better responsiveness
              LayoutBuilder(
                builder: (context, constraints) {
                  // Limit canvas width on larger screens for better UX
                  final maxWidth =
                      constraints.maxWidth > 600 ? 600.0 : constraints.maxWidth;

                  return Center(
                    child: SizedBox(
                      width: maxWidth,
                      child: VerseImageCanvas(
                        composition: viewModel.composition!,
                        repaintKey: _repaintKey,
                        customBackgroundPath: viewModel.customBackgroundPath,
                        onTextDrag: (position) {
                          viewModel.updateTextPosition(position);
                        },
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 8),

              // Drag hint
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.touch_app,
                        size: 16, color: Colors.blue.shade700),
                    const SizedBox(width: 8),
                    Text(
                      'Arraste o texto para posicioná-lo',
                      style:
                          TextStyle(fontSize: 12, color: Colors.blue.shade700),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Aspect Ratio Selector
              AspectRatioSelector(viewModel: viewModel),

              const SizedBox(height: 32),

              // Share Button
              ElevatedButton.icon(
                onPressed: viewModel.isGenerating
                    ? null
                    : () async {
                        await _generateAndShareImage(viewModel);
                      },
                icon: viewModel.isGenerating
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.share),
                label: Text(
                  viewModel.isGenerating ? 'Gerando...' : 'Partilhar Imagem',
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),

              const SizedBox(height: 24),

              // Background Picker
              BackgroundPicker(viewModel: viewModel),

              const SizedBox(height: 24),

              // Typography Controls
              TypographyControls(viewModel: viewModel),

              const SizedBox(height: 16),
              // Download Button
              OutlinedButton.icon(
                onPressed: viewModel.isGenerating
                    ? null
                    : () async {
                        await _saveImageToGallery(viewModel);
                      },
                icon: const Icon(Icons.download),
                label: Text(
                  viewModel.isGenerating ? 'Gerando...' : 'Baixar Imagem',
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Future<void> _generateAndShareImage(
    ImageCreatorViewModel viewModel,
  ) async {
    viewModel.setGenerating(true);

    try {
      // Wait a frame to ensure RepaintBoundary is ready
      await Future.delayed(const Duration(milliseconds: 100));

      // Capture image with aspect ratio
      final Uint8List? imageBytes = await _imageService.captureAsPng(
        _repaintKey,
        targetAspectRatio: viewModel.composition!.aspectRatio,
      );

      if (imageBytes == null) {
        throw Exception('Falha ao gerar imagem');
      }

      // Share the image
      await Share.shareXFiles(
        [
          XFile.fromData(
            imageBytes,
            name: 'verse_${DateTime.now().millisecondsSinceEpoch}.png',
            mimeType: 'image/png',
          ),
        ],
        text:
            '${viewModel.composition!.fullText}\n\n${viewModel.composition!.verseReference}',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao gerar imagem: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      viewModel.setGenerating(false);
    }
  }

  Future<void> _saveImageToGallery(
    ImageCreatorViewModel viewModel,
  ) async {
    viewModel.setGenerating(true);

    try {
      // Wait a frame to ensure RepaintBoundary is ready
      await Future.delayed(const Duration(milliseconds: 100));

      // Capture image with aspect ratio
      final Uint8List? imageBytes = await _imageService.captureAsPng(
        _repaintKey,
        targetAspectRatio: viewModel.composition!.aspectRatio,
      );

      if (imageBytes == null) {
        throw Exception('Falha ao gerar imagem');
      }

      // Save the image to gallery
      final bool success =
          await _imageService.saveImageToGallery(imageBytes);

      if (!success) {
        throw Exception('Falha ao salvar imagem na galeria');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Imagem salva na galeria com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar imagem: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      viewModel.setGenerating(false);
    }
  }
}
