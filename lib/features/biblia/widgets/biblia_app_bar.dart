import 'package:eu_sou/app/tuoring.dart';
import 'package:eu_sou/features/biblia/bloc/biblia_bloc.dart';
import 'package:eu_sou/features/biblia/modals/reading_settings_modal.dart';
import 'package:eu_sou/features/biblia/widgets/versao_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class BibleAppBar extends StatelessWidget {
  const BibleAppBar({
    super.key,
    this.onBookTap,
  });

  final VoidCallback? onBookTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    VersaoWidget(key: keyBibleVersionTab),
                    IconButton(
                      onPressed: () => ReadingSettingsModal.show(context),
                      style: IconButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(80),
                        ),
                        backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer,
                      ),
                      icon: Icon(
                        CupertinoIcons.textformat_alt,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                Center(child: BookSelectorWidget(onBookTap: onBookTap)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class BookSelectorWidget extends StatelessWidget {
  const BookSelectorWidget({
    super.key,
    required this.onBookTap,
  });

  final VoidCallback? onBookTap;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BibliaBloc, BibliaState>(
      builder: (context, state) {
        if (state is BibleChapterLoaded) {
          return InkWell(
            onTap: onBookTap,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "${state.chapter.bookName} ${state.chapter.number}",
                    key: keyBibleContentTab,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Gap(4),
                  const Icon(Icons.keyboard_arrow_down_rounded),
                ],
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
