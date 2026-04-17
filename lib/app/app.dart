import 'package:eu_sou/core/deeplinks/bloc/deeplink_bloc.dart';
import 'package:eu_sou/core/design_system/theme/theme_data.dart';
import 'package:eu_sou/core/design_system/theme/theme_extension.dart';
import 'package:eu_sou/core/localization/bloc/locale_bloc.dart';
import 'package:eu_sou/core/localization/generated/app_localizations.dart';
import 'package:eu_sou/core/notifications/notification_handler.dart';
import 'package:eu_sou/core/services/deeplink_service.dart';
import 'package:eu_sou/core/services/toast_service.dart';
import 'package:eu_sou/features/biblia/bloc/biblia_bloc.dart';
import 'package:eu_sou/features/biblia/bloc/book_selection_cubit.dart';
import 'package:eu_sou/features/biblia/bloc/reading_settings_cubit.dart';
import 'package:eu_sou/features/biblia/data/repositories/reading_settings_repository.dart';
import 'package:eu_sou/features/deep_understanding/presentation/pages/deep_understanding_page.dart';
import 'package:eu_sou/features/onboarding/presentation/splash_page.dart';
import 'package:eu_sou/features/profile/domain/repositories/i_verse_history_repository.dart';
import 'package:eu_sou/features/profile/presentation/bloc/verse_history_bloc.dart';
import 'package:eu_sou/features/search/presentation/bloc/search_bloc.dart';
import 'package:eu_sou/features/theme/presentation/bloc/theme_bloc.dart';
import 'package:eu_sou/features/verse_of_the_day/presentation/bloc/verse_of_the_day_bloc.dart';
import 'package:eu_sou/features/verse_of_the_day/presentation/bloc/verse_of_the_day_event.dart';
import 'package:eu_sou/shared/cubit/bible_version_cubit.dart';
import 'package:eu_sou/shared/cubit/tab_controller_cubit.dart';
import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Main App widget that configures the application using BLoC pattern.
class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
    _setupNotificationListener();
  }

  void _setupNotificationListener() {
    notificationHandler.addOnNotificationTapListener((payload) {
      if (payload != null && payload.startsWith('deep_understanding:')) {
        // Since we don't have the original query or results here easily,
        // we might just want to show the results page if it was already in success state.
        // Or the Bloc should handle loading from session ID if we implement a LoadSession event.

        // For now, let's just push the page if it's the result of our feature.
        toastService.navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (_) => const DeepUnderstandingPage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BetterFeedback(
        child: MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => context.read<ThemeBloc>()),
        BlocProvider(create: (_) => LocaleBloc()),
        BlocProvider(create: (_) => BibleVersionCubit()),
        BlocProvider(
            create: (context) => ReadingSettingsCubit(
                context.read<ReadingSettingsRepository>())),
        BlocProvider(create: (_) => BookSelectionCubit()),
        BlocProvider(
            create: (context) =>
                DeeplinkBloc(context.read<IDeeplinkService>())),
        BlocProvider(
          create: (context) => BibliaBloc(context.read(), context.read()),
        ),
        BlocProvider(
          create: (context) => SearchBloc(context.read(), context.read())
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
              return MaterialApp(
                title: 'Eu Sou',
                navigatorKey: toastService.navigatorKey,
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
