import 'dart:typed_data';

import 'package:eu_sou/core/services/toast_service.dart';
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
  final List<GlobalKey> _repaintKeys = [];
  final ImageGeneratorService _imageService = ImageGeneratorService();
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _syncRepaintKeys(int count) {
    if (_repaintKeys.length != count) {
      _repaintKeys.clear();
      for (int i = 0; i < count; i++) {
        _repaintKeys.add(GlobalKey());
      }
    }
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

        if (viewModel.compositions.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(48.0),
              child: Text('Erro ao carregar composição'),
            ),
          );
        }

        _syncRepaintKeys(viewModel.compositions.length);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Canvas Preview - PageView for multiple images
              LayoutBuilder(
                builder: (context, constraints) {
                  final maxWidth =
                      constraints.maxWidth > 600 ? 600.0 : constraints.maxWidth;
                  final aspectRatio =
                      viewModel.currentComposition!.aspectRatio.ratio;
                  final height = maxWidth / aspectRatio;

                  return Column(
                    children: [
                      Center(
                        child: SizedBox(
                          width: maxWidth,
                          height: height,
                          child: PageView.builder(
                            controller: _pageController,
                            onPageChanged: (index) {
                              viewModel.setCurrentIndex(index);
                            },
                            itemCount: viewModel.compositions.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: VerseImageCanvas(
                                  composition: viewModel.compositions[index],
                                  repaintKey: _repaintKeys[index],
                                  customBackgroundPath:
                                      viewModel.customBackgroundPath,
                                  onTextDrag: (position) {
                                    viewModel.updateTextPosition(position);
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      if (viewModel.compositions.length > 1) ...[
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            viewModel.compositions.length,
                            (index) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: viewModel.currentIndex == index
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey.shade300,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),

              const SizedBox(height: 24),

              // Aspect Ratio Selector
              AspectRatioSelector(viewModel: viewModel),

              const SizedBox(height: 16),

              // Share Button
              ElevatedButton.icon(
                onPressed: (viewModel.isGenerating ||
                        viewModel.compositions.length > 1)
                    ? null
                    : () async {
                        await _generateAndShareImages(viewModel);
                      },
                icon: viewModel.isGenerating
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.share),
                label: Text(
                  viewModel.isGenerating
                      ? 'Gerando...'
                      : viewModel.compositions.length > 1
                          ? 'Partilha múltipla indisponível'
                          : 'Partilhar Imagem',
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
              ElevatedButton.icon(
                onPressed: viewModel.isGenerating
                    ? null
                    : () async {
                        await _saveImagesToGallery(viewModel);
                      },
                icon: const Icon(Icons.download),
                label: Text(
                  viewModel.isGenerating
                      ? 'Gerando...'
                      : viewModel.compositions.length > 1
                          ? 'Baixar Todas'
                          : 'Baixar Imagem',
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

  Future<void> _generateAndShareImages(
    ImageCreatorViewModel viewModel,
  ) async {
    viewModel.setGenerating(true);

    try {
      await Future.delayed(const Duration(milliseconds: 100));

      final List<XFile> xFiles = [];

      for (int i = 0; i < viewModel.compositions.length; i++) {
        final Uint8List? imageBytes = await _imageService.captureAsPng(
          _repaintKeys[i],
          targetAspectRatio: viewModel.compositions[i].aspectRatio,
        );

        if (imageBytes != null) {
          xFiles.add(XFile.fromData(
            imageBytes,
            name: 'verse_${i}_${DateTime.now().millisecondsSinceEpoch}.png',
            mimeType: 'image/png',
          ));
        }
      }

      if (xFiles.isEmpty) {
        throw Exception('Falha ao gerar imagens');
      }

      await Share.shareXFiles(
        xFiles,
        text:
            '${viewModel.compositions.map((c) => c.fullText).join('\n\n')}\n\n${viewModel.compositions.first.verseReference}',
      );
    } catch (e) {
      toastService.showError('Erro ao gerar imagens: $e');
    } finally {
      viewModel.setGenerating(false);
    }
  }

  Future<void> _saveImagesToGallery(
    ImageCreatorViewModel viewModel,
  ) async {
    viewModel.setGenerating(true);

    try {
      await Future.delayed(const Duration(milliseconds: 100));

      int successCount = 0;

      for (int i = 0; i < viewModel.compositions.length; i++) {
        final Uint8List? imageBytes = await _imageService.captureAsPng(
          _repaintKeys[i],
          targetAspectRatio: viewModel.compositions[i].aspectRatio,
        );

        if (imageBytes != null) {
          final bool success =
              await _imageService.saveImageToGallery(imageBytes);
          if (success) successCount++;
        }
      }

            if (successCount == viewModel.compositions.length) {

              toastService

                  .showSuccess('Todas as imagens foram salvas na galeria!');

            } else if (successCount > 0) {

              toastService.showWarning(

                  '$successCount de ${viewModel.compositions.length} imagens salvas.');

            } else {

              throw Exception('Nenhuma imagem foi salva');

            }

          } catch (e) {

            toastService.showError('Erro ao salvar imagens: $e');

          } finally {

            viewModel.setGenerating(false);

          }

        }

      }

      
