import 'package:eu_sou/shared/widgets/app_huge_icon.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

class SettingsItem extends StatelessWidget {
  final AppIconAsset icon;
  final String title;
  final VoidCallback onTap;

  const SettingsItem({super.key, 
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: AppHugeIcon(
          icon: icon,
          size: 22,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.65)),
      title: Text(title,
          style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w400)),
      trailing: AppHugeIcon(
          icon: HugeIcons.strokeRoundedArrowRight01,
          size: 18,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.30)),
      onTap: onTap,
    );
  }
}