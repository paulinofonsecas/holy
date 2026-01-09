import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../data/repositories/background_repository.dart';
import '../../image_creator/image_creator_viewmodel.dart';

class BackgroundPicker extends StatelessWidget {
  final ImageCreatorViewModel viewModel;

  const BackgroundPicker({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Fundo',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            TextButton.icon(
              onPressed: () => _pickImageFromGallery(context),
              icon: const Icon(Icons.photo_library, size: 16),
              label: const Text('Galeria'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 75,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: viewModel.backgrounds.length +
                (viewModel.customBackgroundPath != null ? 1 : 0),
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              // Show custom background first if available
              if (viewModel.customBackgroundPath != null && index == 0) {
                return _buildCustomBackgroundTile(context);
              }

              final bgIndex =
                  viewModel.customBackgroundPath != null ? index - 1 : index;
              final background = viewModel.backgrounds[bgIndex];
              final isSelected =
                  viewModel.composition?.backgroundId == background.id &&
                      viewModel.customBackgroundPath == null;

              return _buildBackgroundTile(
                context: context,
                background: background,
                isSelected: isSelected,
                onTap: () => viewModel.selectBackground(background),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBackgroundTile({
    required BuildContext context,
    required BackgroundOption background,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.grey.shade300,
                width: isSelected ? 3 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  background.color,
                  background.color.withOpacity(0.8),
                ],
              ),
            ),
          ),
          const SizedBox(height: 2),
          SizedBox(
            width: 60,
            child: Text(
              background.label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomBackgroundTile(BuildContext context) {
    final isSelected = viewModel.customBackgroundPath != null;

    return GestureDetector(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.grey.shade300,
                width: isSelected ? 3 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: Image.file(
                    File(viewModel.customBackgroundPath!),
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 2,
                  right: 2,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.photo,
                      color: Colors.white,
                      size: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          const SizedBox(
            width: 60,
            child: Text(
              'Minha foto',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 9),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImageFromGallery(BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        viewModel.setCustomBackground(image.path);
      }
    } on Exception catch (e) {
      if (context.mounted) {
        String message = 'Erro ao selecionar imagem';

        // Check for common permission denial patterns
        final errorStr = e.toString().toLowerCase();
        if (errorStr.contains('permission') ||
            errorStr.contains('denied') ||
            errorStr.contains('access')) {
          message =
              'Permissão negada. Por favor, habilite o acesso à galeria nas configurações do app.';
        } else if (errorStr.contains('camera') ||
            errorStr.contains('photo library')) {
          message =
              'Não foi possível acessar a galeria. Verifique as permissões do app.';
        } else {
          message = 'Erro ao selecionar imagem: $e';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            action:
                errorStr.contains('permission') || errorStr.contains('denied')
                    ? SnackBarAction(
                        label: 'Configurações',
                        textColor: Colors.white,
                        onPressed: () {
                          // TODO: Open app settings
                          // This would require app_settings package
                        },
                      )
                    : null,
          ),
        );
      }
    }
  }
}
