import 'package:eu_sou/features/search/presentation/bloc/search_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchInputBar extends StatefulWidget {
  final String initialValue;
  final ValueChanged<String> onChanged;
  final VoidCallback? onRemove;
  final bool showRemove;
  final String hintText;
  final Widget? dragHandle;

  const SearchInputBar({
    super.key,
    this.initialValue = '',
    required this.onChanged,
    this.onRemove,
    this.showRemove = false,
    this.hintText = 'Termo de busca...',
    this.dragHandle,
  });

  @override
  State<SearchInputBar> createState() => _SearchInputBarState();
}

class _SearchInputBarState extends State<SearchInputBar> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(SearchInputBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != _controller.text &&
        !FocusScope.of(context).hasFocus) {
      _controller.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = context.watch<SearchBloc>().state;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          if (widget.dragHandle != null) ...[
            widget.dragHandle!,
            const SizedBox(width: 4),
          ],
          Expanded(
            child: TextField(
              controller: _controller,
              autocorrect: false,
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: TextStyle(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  size: 22,
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
                isDense: true,
                filled: true,
                fillColor:
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () {
                          _controller.clear();
                          widget.onChanged('');
                        },
                      )
                    : null,
              ),
              onChanged: widget.onChanged,
            ),
          ),
          if (widget.showRemove) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.remove_circle_outline,
                  color: Colors.redAccent, size: 22),
              onPressed: widget.onRemove,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ] else if (searchState is BuscaCarregada &&
              searchState.consultas.length < 2) ...[
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'advanced') {
                  final text = _controller.text.trim();
                  if (text.isEmpty || !text.contains(' ')) {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.info_outline,
                                    size: 48, color: Colors.blue),
                                const SizedBox(height: 16),
                                const Text(
                                  'Digite pelo menos duas palavras para transformar em pesquisa avançada.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 24),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Entendido'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                    return;
                  }
                  context.read<SearchBloc>().add(TransformarEmBuscaAvancada());
                } else if (value == 'add') {
                  context.read<SearchBloc>().add(AdicionarConsulta());
                }
              },
              padding: EdgeInsets.zero,
              offset: const Offset(0, 40),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              icon: Icon(CupertinoIcons.ellipsis_vertical,
                  size: 24, color: Theme.of(context).colorScheme.onSurface),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'advanced',
                  child: Row(
                    children: [
                      Icon(Icons.auto_awesome, size: 18),
                      SizedBox(width: 12),
                      Text('Pesquisa Avançada'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'add',
                  child: Row(
                    children: [
                      Icon(Icons.add_circle_outline, size: 18),
                      SizedBox(width: 12),
                      Text('Novo campo'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
