import 'package:eu_sou/shared/widgets/app_huge_icon.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class SearchInputBar extends StatefulWidget {
  final String initialValue;
  final ValueChanged<String> onChanged;
  final VoidCallback? onRemove;
  final bool showRemove;
  final String hintText;
  final Widget? dragHandle;
  final Widget? suffixIcon;

  const SearchInputBar({
    super.key,
    this.initialValue = '',
    required this.onChanged,
    this.onRemove,
    this.showRemove = false,
    this.hintText = 'Termo de busca...',
    this.dragHandle,
    this.suffixIcon,
  });

  @override
  State<SearchInputBar> createState() => _SearchInputBarState();
}

class _SearchInputBarState extends State<SearchInputBar> {
  late final FocusNode _focusNode;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        autofocus: true,
        autocorrect: false,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            fontSize: 14,
          ),
          prefixIcon: AppHugeIcon(
            icon: HugeIcons.strokeRoundedSearch01,
            size: 13,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
          isDense: true,
          filled: true,
          fillColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
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
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              width: 1,
            ),
          ),
          suffixIcon: _buildSuffixIcon(),
        ),
        onChanged: widget.onChanged,
      ),
    );
  }

  Widget? _buildSuffixIcon() {
    final hasClear = _controller.text.isNotEmpty;
    final hasFilter = widget.suffixIcon != null;

    if (!hasClear && !hasFilter) return null;
    if (!hasClear && hasFilter) return widget.suffixIcon;
    if (hasClear && !hasFilter) {
      return IconButton(
        icon: const AppHugeIcon(icon: HugeIcons.strokeRoundedCancel01, size: 18),
        onPressed: () {
          _controller.clear();
          widget.onChanged('');
        },
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const AppHugeIcon(icon: HugeIcons.strokeRoundedCancel01, size: 18),
          onPressed: () {
            _controller.clear();
            widget.onChanged('');
          },
        ),
        widget.suffixIcon!,
      ],
    );
  }
}
