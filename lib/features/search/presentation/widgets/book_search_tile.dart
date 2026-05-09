import 'package:bible_handler/bible_handler.dart';
import 'package:eu_sou/shared/widgets/app_huge_icon.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter/material.dart';

class BookSearchTile extends StatelessWidget {
  final Book livro;
  final VoidCallback onTap;

  const BookSearchTile({
    super.key,
    required this.livro,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const AppHugeIcon(icon: HugeIcons.strokeRoundedBook01),
      title: Text(livro.name),
      onTap: onTap,
    );
  }
}
