import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import '../bloc/deep_understanding_bloc.dart';
import 'deep_understanding_page.dart';
import '../../data/models/analysis_session.dart';

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
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F0), // Warm off-white
      // appBar: AppBar(
      //   backgroundColor: Colors.transparent,
      //   elevation: 0,
      //   iconTheme: const IconThemeData(color: Color(0xFF4A2B1D)),
      // ),
      body: BlocBuilder<DeepUnderstandingBloc, DeepUnderstandingState>(
        builder: (context, state) {
          if (state is DeepUnderstandingInitial) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFF4A2B1D)));
          }

          if (state is DeepUnderstandingHistoryLoaded) {
            final sessions = state.sessions.toList()
              ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

            if (sessions.isEmpty) {
              return const Center(
                child: Text(
                  'Nenhuma reflexão registrada ainda.',
                  style: TextStyle(color: Color(0xFF8C7D70), fontSize: 16),
                ),
              );
            }

            final grouped = <String, List<AnalysisSession>>{};
            for (var s in sessions) {
              final dateStr = _formatDate(s.updatedAt);
              grouped.putIfAbsent(dateStr, () => []).add(s);
            }

            return SafeArea(
              child: CustomScrollView(
                slivers: [
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(top: 16.0, bottom: 40.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Gap(24),
                          Text(
                            'Jornada da Alma',
                            style: TextStyle(
                              fontSize: 34,
                              fontFamily:
                                  'Times New Roman', // General Serif fallback
                              color: Color(0xFF2D1B13),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'REGISTRO DE ESTUDOS E REFLEXÕES',
                            style: TextStyle(
                              fontSize: 11,
                              letterSpacing: 2.0,
                              color: Color(0xFF8B7765),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final keys = grouped.keys.toList();
                          final dateStr = keys[index];
                          final dateSessions = grouped[dateStr]!;
                          return _buildDateGroup(dateStr, dateSessions);
                        },
                        childCount: grouped.keys.length,
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 40)),
                ],
              ),
            );
          }

          if (state is DeepUnderstandingHistoryError) {
            return Center(
                child: Text('Erro ao carregar histórico: ${state.error}'));
          }

          return const Center(
              child: CircularProgressIndicator(color: Color(0xFF4A2B1D)));
        },
      ),
    );
  }

  Widget _buildDateGroup(String dateStr, List<AnalysisSession> sessions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: Color(0xFF3B5E53), // Dark green dot
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              dateStr,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3B5E53),
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
                  color: const Color(0xFFE6E0D4),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16.0, bottom: 24.0),
                  child: Column(
                    children: sessions.map((s) => _buildCard(s)).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCard(AnalysisSession session) {
    // Extract a snippet without markdown links maybe?
    String snippet = session.result ?? '';
    // Basic clean of some markdown tags
    snippet = snippet.replaceAll(RegExp(r'\*\*|\*|#|`'), '');
    if (snippet.length > 90) {
      snippet = snippet.substring(0, 90) + '...';
    } else if (snippet.isEmpty) {
      snippet = 'Sem resumo disponível.';
    }

    final timeStr = DateFormat('HH:mm').format(session.updatedAt);

    String statusStr = 'Em Processo';
    if (session.status == 'completed')
      statusStr = 'Insight Concluído';
    else if (session.status == 'error')
      statusStr = 'Erro';
    else if (session.status == 'cancelled')
      statusStr = 'Registro Arquivado';
    else if (session.status == 'embedding') statusStr = 'Vetorizando...';

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
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE6E0D4), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
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
                  const Text(
                    'ESTUDO BÍBLICO',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      color: Color(0xFF8B7765),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _confirmDelete(context, session.sessionId),
                    child: const Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: Color(0xFFE2C9B6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                session.query.isEmpty ? 'Estudo' : session.query,
                style: const TextStyle(
                  fontSize: 20,
                  fontFamily: 'Georgia',
                  color: Color(0xFF2D1B13),
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '"$snippet"',
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'Georgia',
                  fontStyle: FontStyle.italic,
                  color: Color(0xFF6B5A51),
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              const Divider(color: Color(0xFFF0EBE1), height: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$timeStr • $statusStr',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF8B7765),
                    ),
                  ),
                  Row(
                    children: [
                      if (session.status == 'completed')
                        const Text(
                          'ANALISAR',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            color: Color(0xFF3B5E53),
                          ),
                        ),
                      if (session.status == 'completed')
                        const SizedBox(width: 4),
                      Icon(
                        session.status == 'completed'
                            ? Icons.arrow_forward
                            : Icons.chevron_right,
                        size: 16,
                        color: session.status == 'completed'
                            ? const Color(0xFF3B5E53)
                            : const Color(0xFFE2C9B6),
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
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir Análise?',
            style: TextStyle(color: Color(0xFF2D1B13))),
        content: const Text(
            'Deseja realmente excluir este registro do histórico?',
            style: TextStyle(color: Color(0xFF6B5A51))),
        backgroundColor: const Color(0xFFF9F6F0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar',
                style: TextStyle(color: Color(0xFF8B7765))),
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
