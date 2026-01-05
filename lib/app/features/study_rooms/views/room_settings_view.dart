import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/study_room.dart';
import '../../../services/study_room_service.dart';

class RoomSettingsView extends StatefulWidget {
  final StudyRoom room;
  final String currentUserId;

  const RoomSettingsView({
    super.key,
    required this.room,
    required this.currentUserId,
  });

  @override
  State<RoomSettingsView> createState() => _RoomSettingsViewState();
}

class _RoomSettingsViewState extends State<RoomSettingsView> {
  late bool _isPublic;
  late List<String> _authorizedControllers;
  late TextEditingController _emailController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isPublic = widget.room.isPublic;
    _authorizedControllers = List.from(
      widget.room.metadata['authorized_controllers'] ?? [widget.room.hostId],
    );
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isHost = widget.room.hostId == widget.currentUserId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações da Sala'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Room Info Section
            _buildSectionTitle('Informações da Sala'),
            _buildInfoCard(
              label: 'Nome da Sala',
              value: widget.room.title,
            ),
            _buildInfoCard(
              label: 'ID da Sala',
              value: widget.room.roomId,
            ),
            _buildInfoCard(
              label: 'Host',
              value: widget.room.hostId,
            ),
            const SizedBox(height: 24),

            // Privacy Settings (Host only)
            if (isHost) ...[
              _buildSectionTitle('Privacidade'),
              SwitchListTile(
                title: const Text('Sala Pública'),
                subtitle: _isPublic
                    ? const Text('Qualquer pessoa pode descobrir esta sala')
                    : const Text('Apenas usuários convidados podem entrar'),
                value: _isPublic,
                onChanged: (value) {
                  setState(() {
                    _isPublic = value;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Authorized Controllers Management
              _buildSectionTitle('Controladores Autorizados'),
              _buildAuthorizedControllersList(),
              const SizedBox(height: 16),
              _buildAddControllerSection(),
              const SizedBox(height: 24),

              // Participants Section
              _buildSectionTitle('Participantes'),
              _buildParticipantsCount(),
              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _saveSettings,
                  icon: const Icon(Icons.save),
                  label: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Salvar Configurações'),
                ),
              ),
            ] else ...[
              // Non-host view
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(Icons.lock, size: 48, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Apenas o host pode modificar as configurações da sala',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildInfoCard({required String label, required String value}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthorizedControllersList() {
    if (_authorizedControllers.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('Nenhum controlador autorizado ainda'),
      );
    }

    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _authorizedControllers.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final controller = _authorizedControllers[index];
          final isHost = controller == widget.room.hostId;

          return ListTile(
            title: Text(controller),
            subtitle: isHost ? const Text('Host') : null,
            trailing: !isHost
                ? IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeController(controller),
                  )
                : null,
          );
        },
      ),
    );
  }

  Widget _buildAddControllerSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                hintText: 'Email do novo controlador',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _addController,
                icon: const Icon(Icons.add),
                label: const Text('Adicionar Controlador'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipantsCount() {
    final participantsCount = widget.room.participants.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.people, color: Colors.blue),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Participantes Ativos'),
                Text(
                  '$participantsCount',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _addController() {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, insira um email')),
      );
      return;
    }

    if (_authorizedControllers.contains(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Este usuário já é um controlador')),
      );
      return;
    }

    setState(() {
      _authorizedControllers.add(email);
      _emailController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Controlador adicionado')),
    );
  }

  void _removeController(String controller) {
    if (controller == widget.room.hostId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não é possível remover o host')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover Controlador'),
        content: Text(
          'Tem certeza que deseja remover $controller como controlador?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _authorizedControllers.remove(controller);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Controlador removido')),
              );
            },
            child: const Text('Remover'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final service = context.read<StudyRoomService>();
      await service.updateRoomSettings(
        roomId: widget.room.roomId,
        isPublic: _isPublic,
        authorizedControllers: _authorizedControllers,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Configurações salvas com sucesso'),
            duration: Duration(seconds: 2),
          ),
        );

        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar configurações: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
