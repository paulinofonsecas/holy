import 'package:flutter/widgets.dart';
import 'package:hugeicons/hugeicons.dart';

typedef AppIconAsset = List<List<dynamic>>;

class AppHugeIcon extends StatelessWidget {
  final AppIconAsset icon;
  final double? size;
  final Color? color;
  final Color? secondaryColor;
  final double? strokeWidth;

  const AppHugeIcon({
    super.key,
    required this.icon,
    this.size,
    this.color,
    this.secondaryColor,
    this.strokeWidth,
  });

  @override
  Widget build(BuildContext context) {
    return HugeIcon(
      icon: icon,
      size: size,
      color: color,
      secondaryColor: secondaryColor,
      strokeWidth: strokeWidth,
    );
  }
}