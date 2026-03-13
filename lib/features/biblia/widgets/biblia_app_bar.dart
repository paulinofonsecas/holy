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
    this.actions,
  });

  final VoidCallback? onBookTap;
  final List<Widget>? actions;

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
                Center(child: BookSelectorWidget(onBookTap: onBookTap)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!(ModalRoute.of(context)?.isFirst ?? true)) ...[
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const Gap(8),
                        ],
                        VersaoWidget(
                            key: (ModalRoute.of(context)?.isFirst ?? true)
                                ? keyBibleVersionTab
                                : null),
                      ],
                    ),
                    const Gap(48),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
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
                            size: 18,
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                          ),
                        ),
                        if (actions != null) ...actions!,
                      ],
                    ),
                  ],
                ),
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
          return Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.outline,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: InkWell(
              onTap: onBookTap,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Gap(2),
                    Text(
                      "${state.chapter.bookName} ${state.chapter.number}",
                      key: (ModalRoute.of(context)?.isFirst ?? true)
                          ? keyBibleContentTab
                          : null,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Gap(4),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
