import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../shared/widgets/app_huge_icon.dart';
import '../../data/repositories/eu_sou_repository.dart';
import '../../domain/models/daily_reflection.dart';
import '../utils/verse_navigation.dart';

class ReflexoesAnterioresPage extends StatefulWidget {
  const ReflexoesAnterioresPage({super.key});

  @override
  State<ReflexoesAnterioresPage> createState() =>
      _ReflexoesAnterioresPageState();
}

class _ReflexoesAnterioresPageState extends State<ReflexoesAnterioresPage> {
  static const _pageSize = 10;

  List<DailyReflection> _allHistory = [];
  List<DailyReflection> _displayed = [];
  bool _loading = true;
  bool _loadingMore = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _load();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _load() async {
    final repository = context.read<EuSouRepository>();
    final history = await repository.getReflectionHistory();
    if (!mounted) return;
    setState(() {
      _allHistory = history;
      _displayed = history.take(_pageSize).toList();
      _loading = false;
    });
  }

  Future<void> _loadMore() async {
    if (_loadingMore || _displayed.length >= _allHistory.length) return;
    setState(() => _loadingMore = true);
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    setState(() {
      _displayed.addAll(
        _allHistory.skip(_displayed.length).take(_pageSize),
      );
      _loadingMore = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bgColor = colorScheme.surface;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: kIsWeb
          ? null
          : AppBar(
              backgroundColor: bgColor,
              elevation: 0,
              scrolledUnderElevation: 0,
              title: Text(
                'REFLEXÕES ANTERIORES',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.5,
                  color: colorScheme.onSurface.withOpacity(0.55),
                ),
              ),
              centerTitle: true,
            ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _allHistory.isEmpty
              ? _EmptyState()
              : ListView.separated(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(28),
                  itemCount:
                      _displayed.length + (_loadingMore ? 1 : 0),
                  separatorBuilder: (_, __) => Divider(
                    height: 48,
                    color: colorScheme.onSurface.withOpacity(0.08),
                  ),
                  itemBuilder: (context, index) {
                    if (index == _displayed.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    return _ReflexaoCard(reflection: _displayed[index]);
                  },
                ),
    );
  }
}

class _ReflexaoCard extends StatelessWidget {
  final DailyReflection reflection;
  const _ReflexaoCard({required this.reflection});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _formatDate(reflection.date).toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.5,
            color: colorScheme.onSurface.withOpacity(0.40),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          '"${reflection.verseText}"',
          style: GoogleFonts.playfairDisplay(
            fontSize: 18,
            fontStyle: FontStyle.italic,
            color: colorScheme.onSurface,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        Builder(
          builder: (context) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final accentColor = isDark
                ? Theme.of(context).colorScheme.primary
                : const Color(0xFF3B5E53);
            final canNavigate =
                VerseNavigation.isNavigable(reflection.verseReference);

            return GestureDetector(
              onTap: canNavigate
                  ? () => VerseNavigation.openInBible(
                      context, reflection.verseReference)
                  : null,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    reflection.verseReference.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2.0,
                      color: canNavigate
                          ? accentColor
                          : colorScheme.onSurface.withOpacity(0.45),
                      decoration: canNavigate ? TextDecoration.underline : null,
                      decorationColor: accentColor,
                    ),
                  ),
                  if (canNavigate) ...[
                    const SizedBox(width: 4),
                    AppHugeIcon(
                      icon: HugeIcons.strokeRoundedLinkSquare02,
                      size: 10,
                      color: accentColor,
                    ),
                  ],
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        Text(
          reflection.essencia,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: colorScheme.onSurface.withOpacity(0.75),
            height: 1.6,
          ),
        ),
      ],
    );
  }

  static const _months = [
    'janeiro',
    'fevereiro',
    'março',
    'abril',
    'maio',
    'junho',
    'julho',
    'agosto',
    'setembro',
    'outubro',
    'novembro',
    'dezembro',
  ];

  String _formatDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      return '${dt.day} de ${_months[dt.month - 1]} de ${dt.year}';
    } catch (_) {
      return dateStr;
    }
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Text(
          'As reflexões dos próximos dias irão aparecer aqui.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontStyle: FontStyle.italic,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.40),
            height: 1.7,
          ),
        ),
      ),
    );
  }
}
