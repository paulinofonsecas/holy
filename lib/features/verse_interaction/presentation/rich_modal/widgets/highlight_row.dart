import 'package:eu_sou/shared/widgets/app_huge_icon.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class HighlightRow extends StatefulWidget {
  final Function(String colorHex) onColorSelected;
  final VoidCallback onRemoveHighlight;

  const HighlightRow({
    super.key,
    required this.onColorSelected,
    required this.onRemoveHighlight,
  });

  @override
  State<HighlightRow> createState() => _HighlightRowState();
}

class _HighlightRowState extends State<HighlightRow> {
  bool isOpen = false;

  static const List<Map<String, dynamic>> colors = [
    {'name': 'Yellow', 'color': Color(0xFFFFF176), 'hex': 'FFFFF176'},
    {'name': 'Green', 'color': Color(0xFFAED581), 'hex': 'FFAED581'},
    {'name': 'Blue', 'color': Color(0xFF81D4FA), 'hex': 'FF81D4FA'},
    {'name': 'Pink', 'color': Color(0xFFF48FB1), 'hex': 'FFF48FB1'},
    {'name': 'Purple', 'color': Color(0xFFCE93D8), 'hex': 'FFCE93D8'},
    {'name': 'Orange', 'color': Color(0xFFFFB74D), 'hex': 'FFFFB74D'},
    {'name': 'Red', 'color': Color(0xFFE57373), 'hex': 'FFE57373'},
    {'name': 'Brown', 'color': Color(0xFFA1887F), 'hex': 'FFA1887F'},
    {'name': 'Black', 'color': Color(0xFF000000), 'hex': 'FF000000'},
  ];

  @override
  Widget build(BuildContext context) {
    return !isOpen
        ? Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: .095),
                borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                ...colors.take(2).map(
                  (e) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: ColorItemWidget(
                        onColorSelected: widget.onColorSelected,
                        hexColor: e['hex'],
                        color: e['color'],
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
                _switchExpansionColorsWidget()
              ],
            ),
          )
        : Row(
            children: [
              IconButton(
                icon:
                    const AppHugeIcon(icon: HugeIcons.strokeRoundedPaintBucket),
                onPressed: () {
                  widget.onRemoveHighlight.call();
                },
                tooltip: 'Remover destaque',
              ),
              const SizedBox(width: 8),
              ...colors.map((colorData) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: ColorItemWidget(
                    onColorSelected: widget.onColorSelected,
                    hexColor: colorData['hex'],
                    color: colorData['color'],
                  ),
                );
              }),
              const SizedBox(width: 8),
              _switchExpansionColorsWidget(),
            ],
          );
  }

  InkWell _switchExpansionColorsWidget() {
    return InkWell(
      onTap: () {
        setState(() {
          isOpen = !isOpen;
        });
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: AppHugeIcon(
            icon: !isOpen
                ? HugeIcons.strokeRoundedArrowRight01
                : HugeIcons.strokeRoundedArrowLeft01),
      ),
    );
  }
}

class ColorItemWidget extends StatelessWidget {
  const ColorItemWidget({
    super.key,
    required this.onColorSelected,
    required this.hexColor,
    this.color,
  });

  final Function(String colorHex) onColorSelected;
  final Color? color;
  final String hexColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onColorSelected.call(hexColor),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
    );
  }
}
