import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/deep_understanding_bloc.dart';
import 'deep_understanding_page.dart';

class DeepUnderstandingHistoryPage extends StatefulWidget {
  const DeepUnderstandingHistoryPage({super.key});

  @override
  State<DeepUnderstandingHistoryPage> createState() => _DeepUnderstandingHistoryPageState();
}

class _DeepUnderstandingHistoryPageState extends State<DeepUnderstandingHistoryPage> {
  @override
  void initState() {
    super.initState();
    context.read<DeepUnderstandingBloc>().add(const LoadHistoryEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Entendimentos'),
      ),
      body: BlocBuilder<DeepUnderstandingBloc, DeepUnderstandingState>(
        builder: (context, state) {
          if (state is DeepUnderstandingInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DeepUnderstandingHistoryLoaded) {
            final sessions = state.sessions;
            if (sessions.isEmpty) {
              return const Center(
                child: Text('Nenhuma análise realizada ainda.'),
              );
            }

            return ListView.separated(
              itemCount: sessions.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final session = sessions[index];
                final date = DateFormat('dd/MM/yyyy HH:mm').format(session.updatedAt);
                
                return ListTile(
                  leading: const Icon(Icons.history_edu, color: Colors.blue),
                  title: Text(
                    session.query,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('$date • Status: ${session.status}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => _confirmDelete(context, session.sessionId),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                  onTap: () {
                    if (session.status == 'completed') {
                      context.read<DeepUnderstandingBloc>().add(ViewSessionEvent(session));
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const DeepUnderstandingPage()),
                      );
                    } else if (session.status == 'error' || session.status == 'cancelled' || session.status == 'embedding') {
                        // For non-completed, we might want to resume or show error
                        // For now, let's just show a snackbar if it's not completed
                         ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Esta análise está com status: ${session.status}')),
                        );
                    }
                  },
                );
              },
            );
          }

          if (state is DeepUnderstandingHistoryError) {
            return Center(child: Text('Erro ao carregar histórico: ${state.error}'));
          }

          // If we are in other states (like Success from a previous view), we might need to reload.
          // But usually we'd want a separate Bloc for history if it becomes complex.
          // For simplicity, if we are not in a history state, we show a loader and trigger load.
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, String sessionId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir Análise?'),
        content: const Text('Deseja realmente excluir este registro do histórico?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<DeepUnderstandingBloc>().add(DeleteHistorySessionEvent(sessionId));
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
