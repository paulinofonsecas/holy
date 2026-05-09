import 'package:eu_sou/shared/widgets/app_huge_icon.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:gap/gap.dart';
import 'package:bible_handler/bible_handler.dart';
import 'search_export_service.dart';

class SearchExportBottomSheet extends StatelessWidget {
  final List<SearchResult> results;
  final String? query;

  const SearchExportBottomSheet({
    super.key,
    required this.results,
    this.query,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Exportar Resultados',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: const AppHugeIcon(icon: HugeIcons.strokeRoundedCopy01),
            title: const Text('Copiar Texto'),
            onTap: () {
              Navigator.pop(context);
              SearchExportService.copyToClipboard(results, query: query);
            },
          ),
          ListTile(
            leading: const AppHugeIcon(icon: HugeIcons.strokeRoundedFile01),
            title: const Text('Exportar como .TXT'),
            onTap: () {
              Navigator.pop(context);
              SearchExportService.exportToTxt(results, query: query);
            },
          ),
          ListTile(
            leading: const AppHugeIcon(icon: HugeIcons.strokeRoundedFile02),
            title: const Text('Exportar como .MD (Markdown)'),
            onTap: () {
              Navigator.pop(context);
              SearchExportService.exportToMd(results, query: query);
            },
          ),
          ListTile(
            leading: const AppHugeIcon(icon: HugeIcons.strokeRoundedPdf01),
            title: const Text('Exportar como .PDF'),
            onTap: () {
              Navigator.pop(context);
              SearchExportService.exportToPdf(results, query: query);
            },
          ),
          const Gap(16),
        ],
      ),
    );
  }

  static void show(BuildContext context, List<SearchResult> results,
      {String? query}) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) =>
          SearchExportBottomSheet(results: results, query: query),
    );
  }
}
