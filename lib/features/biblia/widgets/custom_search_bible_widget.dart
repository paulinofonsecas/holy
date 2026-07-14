import 'package:bible_handler/bible_handler.dart';
import 'package:eu_sou/features/biblia/bloc/biblia_bloc.dart';
import 'package:eu_sou/features/search/presentation/bloc/search_bloc.dart';
import 'package:eu_sou/features/search/presentation/pages/search_screen.dart';
import 'package:eu_sou/shared/cubit/bible_version_cubit.dart';
import 'package:eu_sou/shared/widgets/app_huge_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';

class CustomSearchBibleWidget extends StatelessWidget {
  const CustomSearchBibleWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchBloc, EstadoBusca>(
      builder: (context, state) {
        final hasSearch =
            state is BuscaCarregada && state.resultados.results.isNotEmpty;
        return IconButton(
          onPressed: () async {
            final bibliaBloc = context.read<BibliaBloc>();
            final searchBloc = context.read<SearchBloc>();
            final resultado = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (newContext) => MultiBlocProvider(
                  providers: [
                    BlocProvider.value(value: bibliaBloc),
                    BlocProvider.value(value: searchBloc),
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
          icon: Stack(
            children: [
              AppHugeIcon(
                icon: HugeIcons.strokeRoundedSearch01,
                color: hasSearch ? Theme.of(context).colorScheme.primary : null,
                size: 16,
              ),
              if (hasSearch)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 8,
                      minHeight: 8,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
