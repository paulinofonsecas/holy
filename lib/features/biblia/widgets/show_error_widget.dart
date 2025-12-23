import 'package:eu_sou/shared/bible_models.dart';
import 'package:eu_sou/features/biblia/bloc/biblia_bloc.dart';
import 'package:eu_sou/shared/cubit/bible_version_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class ShowErrorWidget extends StatelessWidget {
  const ShowErrorWidget({
    super.key,
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            Gap(16),
            ElevatedButton(
              onPressed: () {
                context.read<BibliaBloc>()
                  ..add(
                    GetChapter(
                      context.read<BibleVersionCubit>().state.version.id,
                      BibleBooks.genesis.bookId,
                      '1',
                    ),
                  );
              },
              child: Text("Tentar novamente"),
            ),
          ],
        ),
      ),
    );
  }
}
