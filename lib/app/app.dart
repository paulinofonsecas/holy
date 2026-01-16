import 'package:eu_sou/core/design_system/theme/theme_data.dart';
import 'package:eu_sou/core/design_system/theme/theme_extension.dart';
import 'package:eu_sou/core/localization/bloc/locale_bloc.dart';
import 'package:eu_sou/core/localization/generated/app_localizations.dart';
import 'package:eu_sou/features/biblia/bloc/biblia_bloc.dart';
import 'package:eu_sou/features/biblia/bloc/book_selection_cubit.dart';
import 'package:eu_sou/features/onboarding/presentation/splash_page.dart';
import 'package:eu_sou/features/profile/domain/repositories/i_verse_history_repository.dart';
import 'package:eu_sou/features/profile/presentation/bloc/verse_history_bloc.dart';
import 'package:eu_sou/features/search/presentation/bloc/search_bloc.dart';
import 'package:eu_sou/features/theme/presentation/bloc/theme_bloc.dart';
import 'package:eu_sou/features/verse_of_the_day/presentation/bloc/verse_of_the_day_bloc.dart';
import 'package:eu_sou/shared/bible_models.dart';
import 'package:eu_sou/shared/cubit/bible_version_cubit.dart';
import 'package:eu_sou/shared/cubit/tab_controller_cubit.dart';
import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Main App widget that configures the application using BLoC pattern.
class App extends StatelessWidget {
  /// Creates a new App instance.
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return BetterFeedback(
        child: MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => context.read<ThemeBloc>()),
        BlocProvider(create: (_) => LocaleBloc()),
        BlocProvider(create: (_) => BibleVersionCubit()),
        BlocProvider(create: (_) => BookSelectionCubit()),
        BlocProvider(
          create: (context) {
            final bibleVersion =
                context.read<BibleVersionCubit>().state.version;
            return BibliaBloc(context.read())
              ..add(
                GetChapter(bibleVersion.id, BibleBooks.genesis.bookId, '1'),
              );
          },
        ),
        BlocProvider(
          create: (context) => SearchBloc(context.read())
            ..add(CarregarVersao(
              idVersao: context.read<BibleVersionCubit>().state.version.id,
            )),
        ),
        BlocProvider(
          create: (context) => VerseHistoryBloc(
            context.read<IVerseHistoryRepository>(),
          )..add(LoadVerseHistory()),
        ),
        BlocProvider(
          create: (context) => VerseOfTheDayBloc(
            repository: context.read(),
            service: context.read(),
          )..add(const LoadVerseOfTheDaySettings()),
        ),
        BlocProvider(create: (_) => TabControllerCubit()),
      ],
      child: Builder(
        builder: (context) {
          return BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, themeState) {
              if (!themeState.isInitialized) {
                return const MaterialApp(
                  home: Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                );
              }

              return MaterialApp(
                title: 'eu_sou',
                debugShowCheckedModeBanner: false,
                theme: AppThemeData.light(themeState.primaryColor).copyWith(
                  extensions: [
                    AppThemeExtension.light(themeState.primaryColor)
                  ],
                ),
                darkTheme: AppThemeData.dark(themeState.primaryColor).copyWith(
                  extensions: [AppThemeExtension.dark(themeState.primaryColor)],
                ),
                themeMode: themeState.themeMode,
                supportedLocales: AppLocalizations.supportedLocales,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                locale: context.watch<LocaleBloc>().state.locale,
                home: const SplashPage(),
              );
            },
          );
        },
      ),
    ));
  }
}
