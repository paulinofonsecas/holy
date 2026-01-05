import 'package:eu_sou/app/models/sync_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/study_room.dart';
import '../../../services/study_room_service.dart';
import '../bloc/study_room_bloc.dart';

class CommunityView extends StatefulWidget {
  const CommunityView({super.key});

  @override
  State<CommunityView> createState() => _CommunityViewState();
}

class _CommunityViewState extends State<CommunityView> {
  final TextEditingController _roomNameController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();

  @override
  void dispose() {
    _roomNameController.dispose();
    _userNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comunidade de Estudo'),
      ),
      body: BlocBuilder<StudyRoomBloc, StudyRoomState>(
        builder: (context, state) {
          if (state is StudyRoomJoined) {
            return _buildJoinedView(context, state);
          }
          return _buildDiscoveryView(context);
        },
      ),
      floatingActionButton: BlocBuilder<StudyRoomBloc, StudyRoomState>(
        builder: (context, state) {
          if (state is StudyRoomJoined) return const SizedBox.shrink();
          return FloatingActionButton.extended(
            onPressed: () => _showCreateRoomDialog(context),
            label: const Text('Criar Sala'),
            icon: const Icon(Icons.add),
          );
        },
      ),
    );
  }

  Widget _buildDiscoveryView(BuildContext context) {
    return StreamBuilder<List<StudyRoom>>(
      stream: context.read<StudyRoomService>().getPublicRooms(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Erro: ${snapshot.error}'));
        }
        final rooms = snapshot.data ?? [];
        if (rooms.isEmpty) {
          return const Center(
            child: Text('Nenhuma sala pública ativa no momento.'),
          );
        }
        return ListView.builder(
          itemCount: rooms.length,
          itemBuilder: (context, index) {
            final room = rooms[index];
            return ListTile(
              title: Text(room.title),
              subtitle: Text('Host ID: ${room.hostId}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showJoinRoomDialog(context, room),
            );
          },
        );
      },
    );
  }

  Widget _buildJoinedView(BuildContext context, StudyRoomJoined state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.group, size: 64, color: Colors.green),
          const SizedBox(height: 16),
          Text(
            'Você está na sala: ${state.roomId}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            state.isHost
                ? 'Você é o host'
                : 'Status: ${state.status == SyncStatus.following ? "Seguindo" : "Desconectado"}',
            style: TextStyle(
              fontWeight: state.isHost ? FontWeight.bold : FontWeight.normal,
              color: state.isHost ? Colors.blue : Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          if (state.isHost)
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(
                          'Funcionalidade de compartilhar versículo em desenvolvimento')),
                );
              },
              child: const Text('Compartilhar Versículo'),
            )
          else
            ElevatedButton(
              onPressed: () {
                context.read<StudyRoomBloc>().add(ToggleFollow());
              },
              child: Text(state.status == SyncStatus.following
                  ? 'Parar de Seguir'
                  : 'Seguir Host'),
            ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              context.read<StudyRoomBloc>().add(LeaveRoom(
                    roomId: state.roomId,
                    userId: state.userId,
                  ));
            },
            child:
                const Text('Sair da Sala', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showCreateRoomDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Criar Nova Sala'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _roomNameController,
              decoration: const InputDecoration(labelText: 'Nome da Sala'),
            ),
            TextField(
              controller: _userNameController,
              decoration: const InputDecoration(labelText: 'Seu Nome'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final roomName = _roomNameController.text;
              final userName = _userNameController.text;
              if (roomName.isNotEmpty && userName.isNotEmpty) {
                final service = context.read<StudyRoomService>();
                final userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
                final roomId = await service.createRoom(
                  StudyRoom(
                    roomId: '', // Will be set by service
                    title: roomName,
                    hostId: userId,
                    isPublic: true,
                  ),
                );
                if (context.mounted) {
                  context.read<StudyRoomBloc>().add(JoinRoom(
                        roomId: roomId,
                        userId: userId,
                        displayName: userName,
                      ));
                  Navigator.pop(context);
                }
              }
            },
            child: const Text('Criar'),
          ),
        ],
      ),
    );
  }

  void _showJoinRoomDialog(BuildContext context, StudyRoom room) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Entrar em ${room.title}'),
        content: TextField(
          controller: _userNameController,
          decoration: const InputDecoration(labelText: 'Seu Nome'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final userName = _userNameController.text;
              if (userName.isNotEmpty) {
                context.read<StudyRoomBloc>().add(JoinRoom(
                      roomId: room.roomId,
                      userId: 'user_${DateTime.now().millisecondsSinceEpoch}',
                      displayName: userName,
                    ));
                Navigator.pop(context);
              }
            },
            child: const Text('Entrar'),
          ),
        ],
      ),
    );
  }
}
