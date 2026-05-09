import 'package:eu_sou/shared/widgets/app_huge_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';

import '../../data/models/analysis_session.dart';
import '../bloc/deep_understanding_bloc.dart';
import 'deep_understanding_page.dart';

class DeepUnderstandingHistoryPage extends StatefulWidget {
  const DeepUnderstandingHistoryPage({super.key});

  @override
  State<DeepUnderstandingHistoryPage> createState() =>
      _DeepUnderstandingHistoryPageState();
}

class _DeepUnderstandingHistoryPageState
    extends State<DeepUnderstandingHistoryPage> {
  @override
  void initState() {
    super.initState();
    context.read<DeepUnderstandingBloc>().add(const LoadHistoryEvent());
  }

  String _formatDate(DateTime date) {
    const months = [
      'JANEIRO',
      'FEVEREIRO',
      'MARÇO',
      'ABRIL',
      'MAIO',
      'JUNHO',
      'JULHO',
      'AGOSTO',
      'SETEMBRO',
      'OUTUBRO',
      'NOVEMBRO',
      'DEZEMBRO'
    ];
    return '${date.day} DE ${months[date.month - 1]}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? Theme.of(context).colorScheme.surface
        : const Color(0xFFF9F6F0);
    final primaryTextColor = isDark
        ? Theme.of(context).colorScheme.onSurface
        : const Color(0xFF2D1B13);
    final secondaryTextColor = isDark
        ? Theme.of(context).colorScheme.onSurfaceVariant
        : const Color(0xFF8B7765);
    final accentColor = isDark
        ? Theme.of(context).colorScheme.primary
        : const Color(0xFF3B5E53);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: BlocBuilder<DeepUnderstandingBloc, DeepUnderstandingState>(
        builder: (context, state) {
          if (state is DeepUnderstandingInitial && state.sessions.isEmpty) {
            return Center(child: CircularProgressIndicator(color: accentColor));
          }

          final sessions = state.sessions.toList()
            ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

          // if (sessions.isEmpty && state is! DeepUnderstandingInProgress) {
          //   if (state is DeepUnderstandingHistoryError) {
          //     return Center(
          //         child: Text('Erro ao carregar histórico: ${state.error}'));
          //   }
          //   return Center(
          //     child: Text(
          //       'Nenhuma reflexão registrada ainda.',
          //       style: TextStyle(color: secondaryTextColor, fontSize: 16),
          //     ),
          //   );
          // }

          final grouped = <String, List<AnalysisSession>>{};
          for (var s in sessions) {
            final dateStr = _formatDate(s.updatedAt);
            grouped.putIfAbsent(dateStr, () => []).add(s);
          }

          return SafeArea(
            child: Stack(
              children: [
                CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 16.0, bottom: 40.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: BackButton(),
                              ),
                            ),
                            Text(
                              'Eu Sou',
                              style: TextStyle(
                                fontSize: 34,
                                fontFamily:
                                    'Times New Roman', // General Serif fallback
                                color: primaryTextColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (grouped.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Text(
                            'Nenhuma reflexão registrada ainda.',
                            style: TextStyle(
                                color: secondaryTextColor, fontSize: 16),
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final keys = grouped.keys.toList();
                              final dateStr = keys[index];
                              final dateSessions = grouped[dateStr]!;
                              return _buildDateGroup(
                                  context, dateStr, dateSessions);
                            },
                            childCount: grouped.keys.length,
                          ),
                        ),
                      ),
                    const SliverToBoxAdapter(child: SizedBox(height: 40)),
                  ],
                ),
                if (state is DeepUnderstandingInProgress)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Column(
                      children: [
                        LinearProgressIndicator(
                          value: state.progress,
                          backgroundColor: Colors.transparent,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(accentColor),
                          minHeight: 4,
                        ),
                        Container(
                          width: double.infinity,
                          color: accentColor.withOpacity(0.1),
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            'Gerando entendimento: ${(state.progress * 100).toInt()}%',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: accentColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateGroup(
      BuildContext context, String dateStr, List<AnalysisSession> sessions) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark
        ? Theme.of(context).colorScheme.primary
        : const Color(0xFF3B5E53);
    final lineColor = isDark
        ? Theme.of(context).colorScheme.outlineVariant
        : const Color(0xFFE6E0D4);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: accentColor, // Dark green dot
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              dateStr,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: accentColor,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 12,
                alignment: Alignment.center,
                child: Container(
                  width: 1.5,
                  color: lineColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16.0, bottom: 24.0),
                  child: Column(
                    children:
                        sessions.map((s) => _buildCard(context, s)).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCard(BuildContext context, AnalysisSession session) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor =
        isDark ? Theme.of(context).colorScheme.surfaceContainer : Colors.white;
    final borderColor = isDark
        ? Theme.of(context).colorScheme.outlineVariant
        : const Color(0xFFE6E0D4);
    final primaryTextColor = isDark
        ? Theme.of(context).colorScheme.onSurface
        : const Color(0xFF2D1B13);
    final secondaryTextColor = isDark
        ? Theme.of(context).colorScheme.onSurfaceVariant
        : const Color(0xFF8B7765);
    final quoteTextColor = isDark
        ? Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.8)
        : const Color(0xFF6B5A51);
    final dividerColor = isDark
        ? Theme.of(context).colorScheme.outlineVariant
        : const Color(0xFFF0EBE1);
    final accentColor = isDark
        ? Theme.of(context).colorScheme.primary
        : const Color(0xFF3B5E53);
    final iconColor = isDark
        ? Theme.of(context).colorScheme.primary.withOpacity(0.5)
        : const Color(0xFFE2C9B6);

    // Extract a snippet without markdown links maybe?
    String snippet = session.result ?? '';
    // Basic clean of some markdown tags
    snippet = snippet.replaceAll(RegExp(r'\*\*|\*|#|`'), '');
    if (snippet.length > 90) {
      snippet = '${snippet.substring(0, 90)}...';
    } else if (snippet.isEmpty) {
      snippet = 'Sem resumo disponível.';
    }

    final timeStr = DateFormat('HH:mm').format(session.updatedAt);

    String statusStr = 'Em Processo';
    if (session.status == 'completed') {
      statusStr = 'Insight Concluído';
    } else if (session.status == 'error') {
      statusStr = 'Erro';
    } else if (session.status == 'cancelled') {
      statusStr = 'Registro Arquivado';
    } else if (session.status == 'embedding') {
      statusStr = 'Vetorizando...';
    }

    return GestureDetector(
      onTap: () {
        if (session.status == 'completed') {
          context.read<DeepUnderstandingBloc>().add(ViewSessionEvent(session));
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DeepUnderstandingPage()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Esta análise está com status: ${session.status}')),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ESTUDO BÍBLICO',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      color: secondaryTextColor,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _confirmDelete(context, session.sessionId),
                    child: AppHugeIcon(
                      icon: HugeIcons.strokeRoundedDelete01,
                      size: 20,
                      color: iconColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                session.query.isEmpty ? 'Estudo' : session.query,
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Georgia',
                  color: primaryTextColor,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '"$snippet"',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Georgia',
                  fontStyle: FontStyle.italic,
                  color: quoteTextColor,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Divider(color: dividerColor, height: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$timeStr • $statusStr',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: secondaryTextColor,
                    ),
                  ),
                  Row(
                    children: [
                      if (session.status == 'completed')
                        Text(
                          'ANALISAR',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            color: accentColor,
                          ),
                        ),
                      if (session.status == 'completed')
                        const SizedBox(width: 4),
                      AppHugeIcon(
                        icon: session.status == 'completed'
                            ? HugeIcons.strokeRoundedArrowRight01
                            : HugeIcons.strokeRoundedArrowRight01,
                        size: 16,
                        color: session.status == 'completed'
                            ? accentColor
                            : iconColor,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String sessionId) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? Theme.of(context).colorScheme.surface
        : const Color(0xFFF9F6F0);
    final primaryTextColor = isDark
        ? Theme.of(context).colorScheme.onSurface
        : const Color(0xFF2D1B13);
    final secondaryTextColor = isDark
        ? Theme.of(context).colorScheme.onSurfaceVariant
        : const Color(0xFF8B7765);
    final bodyTextColor = isDark
        ? Theme.of(context).colorScheme.onSurfaceVariant
        : const Color(0xFF6B5A51);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title:
            Text('Excluir Análise?', style: TextStyle(color: primaryTextColor)),
        content: Text('Deseja realmente excluir este registro do histórico?',
            style: TextStyle(color: bodyTextColor)),
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child:
                Text('Cancelar', style: TextStyle(color: secondaryTextColor)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context
                  .read<DeepUnderstandingBloc>()
                  .add(DeleteHistorySessionEvent(sessionId));
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
