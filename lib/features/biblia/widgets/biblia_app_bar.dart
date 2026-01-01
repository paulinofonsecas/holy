import 'package:bible_handler/bible_handler.dart';
import 'package:eu_sou/features/biblia/bloc/biblia_bloc.dart';
import 'package:eu_sou/features/biblia/widgets/versao_widget.dart';
import 'package:eu_sou/features/search/data/repositories/search_repository.dart';
import 'package:eu_sou/features/search/presentation/bloc/search_bloc.dart';
import 'package:eu_sou/features/search/presentation/pages/search_screen.dart';
import 'package:eu_sou/shared/cubit/bible_version_cubit.dart';
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
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          VersaoWidget(),
          Expanded(
            child: BlocBuilder<BibliaBloc, BibliaState>(
              builder: (context, state) {
                if (state is BibleChapterLoaded) {
                  return InkWell(
                    onTap: onBookTap,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              "${state.chapter.bookName} ${state.chapter.number}",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Gap(4),
                          Icon(Icons.keyboard_arrow_down_rounded),
                        ],
                      ),
                    ),
                  );
                }
                return SizedBox.shrink();
              },
            ),
          ),
          IconButton(
            onPressed: () async {
              final resultado = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (newContext) => MultiBlocProvider(
                    providers: [
                      BlocProvider.value(value: context.read<BibliaBloc>()),
                      BlocProvider(
                        create: (context) => SearchBloc(
                          context.read<RepositorioBusca>(),
                          idVersao: context
                              .read<BibleVersionCubit>()
                              .state
                              .version
                              .id,
                        ),
                      ),
                    ],
                    child: const TelaBusca(),
                  ),
                ),
              );

              if (resultado != null && context.mounted) {
                if (resultado is SearchResult) {
                  context.read<BibliaBloc>().add(
                        GetChapter(
                          resultado.versionId,
                          resultado.book.id,
                          resultado.chapter.number.toString(),
                          verse: resultado.verse.number,
                        ),
                      );
                } else if (resultado is Book) {
                  final idVersao =
                      context.read<BibleVersionCubit>().state.version.id;
                  context.read<BibliaBloc>().add(
                        GetChapter(
                          idVersao,
                          resultado.id,
                          '1',
                        ),
                      );
                }
              }
            },
            icon: Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.more_vert),
          ),
        ],
      ),
    );
  }
}
