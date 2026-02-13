import 'dart:developer' show log;

import 'package:eu_sou/shared/cubit/tab_controller_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

final GlobalKey keyBibleContentTab = GlobalKey();
final GlobalKey keyBibleVersionTab = GlobalKey();
final GlobalKey keySearchField = GlobalKey();

/// Mixin to handle tutorials in widgets.
mixin TutorialMixin<T extends StatefulWidget> on State<T> {
  final List<TargetFocus> _targets = [];

  /// Key for the Bible tab target.
  GlobalKey get keyBibleTab;

  /// Key for the Search tab target.
  GlobalKey get keySearchTab;

  /// Key for the Profile tab target.
  GlobalKey get keyProfileTab;

  void initTargets() {
    _targets.clear();
    _targets.add(
      TargetFocus(
        identify: "BibleTarget",
        keyTarget: keyBibleTab,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Bíblia Sagrada",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20.0,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Text(
                      "Aqui você pode ler e explorar todos os livros da Bíblia.",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );

    _targets.add(
      TargetFocus(
        identify: "BibleContentTarget",
        keyTarget: keyBibleContentTab,
        radius: 100,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return const Align(
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 100),
                    Text(
                      "Seletor de livro e capitulo",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20.0,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Text(
                        "Aqui você pode selecionar o livro e capitulo deseja.",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );

    _targets.add(
      TargetFocus(
        identify: "BibleVersionTarget",
        keyTarget: keyBibleVersionTab,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return const Align(
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 100),
                    Text(
                      "Versões da Bíblia",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20.0,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Text(
                        "Troque facilmente a versão da Bíblia para obter um entendimento mais aprofundados sobre a Palavra de Deus.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );

    _targets.add(
      TargetFocus(
        identify: "SearchTarget",
        keyTarget: keySearchField,
        contents: [
          TargetContent(
            customPosition: CustomTargetContentPosition(
              top: 100,
              left: 100,
            ),
            builder: (context, controller) {
              return const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 200),
                  Text(
                    "Pesquisa Avançada",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20.0,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Text(
                      "Encontre rapidamente versículos, temas ou palavras-chave em toda a Bíblia.",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.0,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );

    _targets.add(
      TargetFocus(
        identify: "ProfileTarget",
        keyTarget: keyProfileTab,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Seu Perfil e Ajustes",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 20.0,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text(
                    "Acesse seus versículos marcados, mude o tema do app e configure notificações aqui.",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void showTutorial() {
    initTargets();
    TutorialCoachMark(
      targets: _targets,
      alignSkip: AlignmentGeometry.topRight,
      colorShadow: Colors.black.withValues(alpha: 0.8),
      textSkip: "Pular",
      onClickTarget: (target) {
        log(target.toString(), name: "TutorialCoachMark");

        if (target.identify == "BibleVersionTarget") {
          context.read<TabControllerCubit>().goToSearch();
        }

        if (target.identify == "SearchTarget") {
          log('Going to profile page');
          context.read<TabControllerCubit>().goToProfile();
        }
      },
      onSkip: () {
        debugPrint("skip");
        return true;
      },
      onFinish: () {
        debugPrint("finish");
      },
    ).show(context: context);
  }
}
