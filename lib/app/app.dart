import 'package:eu_sou/core/design_system/theme/theme_data.dart';
import 'package:eu_sou/core/design_system/theme/theme_extension.dart';
import 'package:eu_sou/core/localization/bloc/locale_bloc.dart';
import 'package:eu_sou/core/localization/generated/app_localizations.dart';
import 'package:eu_sou/features/search/presentation/bloc/search_bloc.dart';
import 'package:eu_sou/features/theme/presentation/bloc/theme_bloc.dart';
import 'package:eu_sou/shared/cubit/bible_version_cubit.dart';
import 'package:eu_sou/shared/widgets/main_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Main App widget that configures the application using BLoC pattern.
class App extends StatelessWidget {
  /// Creates a new App instance.
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => context.read<ThemeBloc>()),
        BlocProvider(create: (_) => LocaleBloc()),
        BlocProvider(create: (_) => BibleVersionCubit()),
        BlocProvider(create: (_) => SearchBloc(context.read())),
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
                home: const MainScaffold(),
              );
            },
          );
        },
      ),
    );
  }
}
