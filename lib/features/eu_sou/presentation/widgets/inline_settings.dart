import 'package:eu_sou/features/daily_growth/presentation/pages/daily_growth_page.dart';
import 'package:eu_sou/features/eu_sou/presentation/cubit/change_my_name_cubit.dart';
import 'package:eu_sou/features/eu_sou/presentation/widgets/edit_name_dialog.dart';
import 'package:eu_sou/features/eu_sou/presentation/widgets/settings_item.dart';
import 'package:eu_sou/features/feedback/views/about_view.dart';
import 'package:eu_sou/features/profile/domain/repositories/i_marked_verses_repository.dart';
import 'package:eu_sou/features/profile/presentation/bloc/marked_verses_bloc.dart';
import 'package:eu_sou/features/profile/presentation/pages/marked_verses_list_page.dart';
import 'package:eu_sou/features/profile/presentation/pages/theme_settings_page.dart';
import 'package:eu_sou/features/profile/presentation/pages/verse_history_page.dart';
import 'package:eu_sou/features/tutorial/presentation/pages/tutorials_list_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InlineSettings extends StatelessWidget {
  const InlineSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 1),
        const SizedBox(height: 8),
        SettingsItem(
          icon: HugeIcons.strokeRoundedChartUp,
          title: 'Crescimento Diário',
          onTap: () => Navigator.push(
            context,
            DailyGrowthPage.route,
          ),
        ),
        SettingsItem(
          icon: HugeIcons.strokeRoundedBookmark02,
          title: 'Versículos Marcados',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider(
                create: (ctx) =>
                    MarkedVersesBloc(ctx.read<IMarkedVersesRepository>()),
                child: const MarkedVersesListPage(),
              ),
            ),
          ),
        ),
        SettingsItem(
          icon: HugeIcons.strokeRoundedClock03,
          title: 'Histórico de Versículos',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const VerseHistoryPage()),
          ),
        ),
        // _SettingsItem(
        //   icon: HugeIcons.strokeRoundedNotification01,
        //   title: 'Versículo do Dia',
        //   onTap: () {
        //     final versionId =
        //         context.read<BibleVersionCubit>().state.version.id;
        //     context.read<VerseOfTheDayBloc>().add(
        //           LoadVerseOfTheDaySettings(defaultVersionId: versionId),
        //         );
        //     Navigator.push(
        //       context,
        //       MaterialPageRoute(
        //           builder: (_) => const VerseOfTheDaySettingsPage()),
        //     );
        //   },
        // ),

        SettingsItem(
          icon: HugeIcons.strokeRoundedPaintBucket,
          title: 'Tema e Cores',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ThemeSettingsPage()),
          ),
        ),
        SettingsItem(
          icon: HugeIcons.strokeRoundedHelpCircle,
          title: 'Ajuda e Tutoriais',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TutorialsListPage()),
          ),
        ),
        SettingsItem(
          icon: HugeIcons.strokeRoundedInformationCircle,
          title: 'Sobre',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AboutView()),
          ),
        ),
        SettingsItem(
          icon: HugeIcons.strokeRoundedUser,
          title: 'Meu Nome',
          onTap: () => editName(context),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  static Future<void> editName(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getString('eu_sou_user_name') ?? '';
    if (!context.mounted) return;

    // Delegate lifecycle of the controller to a StatefulWidget inside the dialog
    await showDialog<void>(
      context: context,
      builder: (ctx) => EditNameDialog(
        initialValue: current,
        onSave: (name) async {
          await prefs.setString('eu_sou_user_name', name);
          if (ctx.mounted) {
            context.read<ChangeMyNameCubit>().changeName(name);
          }
        },
      ),
    );
  }
}
