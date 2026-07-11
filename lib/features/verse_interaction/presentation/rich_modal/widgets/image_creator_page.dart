import 'dart:typed_data';

import 'package:eu_sou/core/services/toast_service.dart';
import 'package:eu_sou/shared/bible_models.dart';
import 'package:eu_sou/shared/widgets/app_huge_icon.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:stacked/stacked.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

import '../../../domain/services/image_generator_service.dart';
import '../../image_creator/image_creator_viewmodel.dart';
import '../../image_creator/widgets/aspect_ratio_selector.dart';
import '../../image_creator/widgets/background_editor.dart';
import '../../image_creator/widgets/background_picker.dart';
import '../../image_creator/widgets/typography_controls.dart';
import '../../image_creator/widgets/verse_image_canvas.dart';

class ImageCreatorPage extends StatefulWidget {
  final List<BibleVerse> verses;
  final String verseReference;
  final String versionId;

  const ImageCreatorPage({
    super.key,
    required this.verses,
    required this.verseReference,
    this.versionId = '',
  });

  static WoltModalSheetPage build({
    required BuildContext context,
    required List<BibleVerse> verses,
    required String verseReference,
    String versionId = '',
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
        icon: const AppHugeIcon(icon: HugeIcons.strokeRoundedCancel01),
        onPressed: () => Navigator.of(context).pop(),
      ),
      child: ImageCreatorPage(
        verses: verses,
        verseReference: verseReference,
        versionId: versionId,
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

  // While capturing we hide editing handles so they don't appear in the image
  bool _isCanvasEditing = true;

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
      onViewModelReady: (viewModel) => viewModel.initialize(
          widget.verses, widget.verseReference, widget.versionId),
      builder: (context, viewModel, child) {
        if (viewModel.isBusy) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(48.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Preparando composição...',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        if (viewModel.compositions.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(48.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Erro ao carregar composição',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () => viewModel.initialize(
                        widget.verses, widget.verseReference, widget.versionId),
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            ),
          );
        }

        _syncRepaintKeys(viewModel.compositions.length);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Editing hint
              if (_isCanvasEditing)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppHugeIcon(icon: HugeIcons.strokeRoundedTouch01,
                          size: 14,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.45)),
                      const SizedBox(width: 4),
                      Text(
                        'Toque para selecionar • Arraste para mover • Pinça para escalar',
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.45),
                        ),
                      ),
                    ],
                  ),
                ),

              // Canvas Preview - PageView for multiple images
              LayoutBuilder(
                builder: (context, constraints) {
                  final maxWidth = constraints.maxWidth > 600
                      ? 600.0
                      : constraints.maxWidth;
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
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0),
                                child: VerseImageCanvas(
                                  composition: viewModel.compositions[index],
                                  repaintKey: _repaintKeys[index],
                                  isEditing: _isCanvasEditing,
                                  customBackgroundPath:
                                      viewModel.customBackgroundPath,
                                  customBackgroundBytes:
                                      viewModel.customBackgroundBytes,
                                  onElementsUpdate: (elements) {
                                    viewModel.updateElements(elements);
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      if (viewModel.compositions.length > 1) ...[
                        const SizedBox(height: 12),
                        SmoothPageIndicator(
                          controller: _pageController,
                          count: viewModel.compositions.length,
                          effect: ExpandingDotsEffect(
                            dotWidth: 6,
                            dotHeight: 6,
                            expansionFactor: 3,
                            spacing: 5,
                            activeDotColor: Theme.of(context).primaryColor,
                            dotColor: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.18),
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),

              const SizedBox(height: 24),

              BackgroundPicker(viewModel: viewModel),

              const SizedBox(height: 24),

              BackgroundEditor(viewModel: viewModel),

              const SizedBox(height: 24),

              TypographyControls(viewModel: viewModel),

              const SizedBox(height: 24),

              AspectRatioSelector(viewModel: viewModel),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: viewModel.isGenerating
                          ? null
                          : () async {
                              await _generateAndShareImages(viewModel);
                            },
                      icon: viewModel.isGenerating
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const AppHugeIcon(
                              icon: HugeIcons.strokeRoundedShare01),
                      label: Text(
                        viewModel.isGenerating
                            ? 'Gerando...'
                            : 'Partilhar',
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: viewModel.isGenerating
                          ? null
                          : () async {
                              await _saveImagesToGallery(viewModel);
                            },
                      icon: const AppHugeIcon(
                          icon: HugeIcons.strokeRoundedDownload01),
                      label: Text(
                        viewModel.isGenerating
                            ? 'Gerando...'
                            : viewModel.compositions.length > 1
                                ? 'Baixar Todas'
                                : 'Baixar',
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Future<void> _prepareCanvasForCapture() async {
    setState(() => _isCanvasEditing = false);
    await WidgetsBinding.instance.endOfFrame;
    await WidgetsBinding.instance.endOfFrame;
  }

  void _restoreCanvasAfterCapture() {
    if (mounted) setState(() => _isCanvasEditing = true);
  }

  Future<void> _generateAndShareImages(
    ImageCreatorViewModel viewModel,
  ) async {
    viewModel.setGenerating(true);
    await _prepareCanvasForCapture();

    try {
      final List<XFile> xFiles = [];

      for (int i = 0; i < viewModel.compositions.length; i++) {
        final Uint8List? imageBytes = await _imageService.captureAsPng(
          _repaintKeys[i],
          targetAspectRatio: viewModel.compositions[i].aspectRatio,
        );

        if (imageBytes != null) {
          xFiles.add(XFile.fromData(
            imageBytes,
            name:
                'verse_${i}_${DateTime.now().millisecondsSinceEpoch}.png',
            mimeType: 'image/png',
          ));
        }
      }

      if (xFiles.isEmpty) throw Exception('Falha ao gerar imagens');

      await Share.shareXFiles(
        xFiles,
        text:
            '${viewModel.compositions.map((c) => c.fullText).join('\n\n')}\n\n${viewModel.compositions.first.verseReference}',
      );
    } catch (e) {
      toastService.showError('Não foi possível gerar as imagens.');
    } finally {
      viewModel.setGenerating(false);
      _restoreCanvasAfterCapture();
    }
  }

  Future<void> _saveImagesToGallery(
    ImageCreatorViewModel viewModel,
  ) async {
    viewModel.setGenerating(true);
    await _prepareCanvasForCapture();

    try {
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
        toastService.showSuccess('Todas as imagens foram salvas na galeria!');
      } else if (successCount > 0) {
        toastService
            .showWarning('$successCount de ${viewModel.compositions.length} imagens salvas.');
      } else {
        throw Exception('save_failed');
      }
    } catch (e) {
      toastService.showError('Não foi possível salvar as imagens.');
    } finally {
      viewModel.setGenerating(false);
      _restoreCanvasAfterCapture();
    }
  }
}
