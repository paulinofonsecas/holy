import 'package:eu_sou/shared/widgets/app_huge_icon.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class BookSearchModal extends StatefulWidget {
  final ValueChanged<String>? onSearch;

  const BookSearchModal({
    super.key,
    this.onSearch,
  });

  @override
  State<BookSearchModal> createState() => _BookSearchModalState();
}

class _BookSearchModalState extends State<BookSearchModal> {
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _textController,
            autocorrect: false,
            decoration: const InputDecoration(
              hintText: 'Search for a book...',
              prefixIcon:
                  AppHugeIcon(icon: HugeIcons.strokeRoundedBook01, size: 16),
            ),
          ),
          const SizedBox(height: 16),
          IconButton(
            onPressed: () {
              if (_textController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter search criteria'),
                  ),
                );
              } else {
                widget.onSearch?.call(_textController.text);
              }
            },
            icon: const AppHugeIcon(
                icon: HugeIcons.strokeRoundedSearch01, size: 16),
          ),
        ],
      ),
    );
  }
}
