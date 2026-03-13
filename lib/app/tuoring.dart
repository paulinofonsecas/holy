import 'dart:developer' show log;

import 'package:eu_sou/shared/cubit/tab_controller_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

const String tutorialShownKey = 'tutorial_shown';

final GlobalKey keyBibleContentTab = GlobalKey();
final GlobalKey keyBibleVersionTab = GlobalKey();
final GlobalKey keySearchField = GlobalKey();
final GlobalKey keyTutorialField = GlobalKey();

// New keys for bottom navigation
final GlobalKey keyBibleTab = GlobalKey();
final GlobalKey keySearchTab = GlobalKey();
final GlobalKey keyStudiesTab = GlobalKey();
final GlobalKey keyProfileTab = GlobalKey();

/// Mixin to handle tutorials in widgets.
mixin TutorialMixin<T extends StatefulWidget> on State<T> {
  final List<TargetFocus> _targets = [];

  void initTargets() {
    _targets.clear();
    
    // 1. Bible Tab (Bottom Bar)
    _targets.add(
      TargetFocus(
        identify: "BibleTabTarget",
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

    // 2. Book & Chapter Selector
    _targets.add(
      TargetFocus(
        identify: "BibleContentTarget",
        keyTarget: keyBibleContentTab,
        shape: ShapeLightFocus.RRect,
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
                      "Seletor de livro e capítulo",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20.0,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Text(
                        "Aqui você pode selecionar o livro e capítulo que deseja.",
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

    // 3. Bible Version
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
                        "Troque facilmente a versão da Bíblia para obter um entendimento mais aprofundado sobre a Palavra de Deus.",
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

    // 4. Search Tab (Bottom Bar)
    _targets.add(
      TargetFocus(
        identify: "SearchTabTarget",
        keyTarget: keySearchTab,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Pesquisa Bíblica",
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

    // 5. Studies Tab (Bottom Bar) - NEW
    _targets.add(
      TargetFocus(
        identify: "StudiesTabTarget",
        keyTarget: keyStudiesTab,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Estudos e Histórico",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20.0,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Text(
                      "Acesse suas análises profundas por IA e o histórico de navegação.",
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

    // 6. Profile Tab (Bottom Bar)
    _targets.add(
      TargetFocus(
        identify: "ProfileTabTarget",
        keyTarget: keyProfileTab,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Seu Perfil",
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

    // 7. Tutorial Option inside Profile
    _targets.add(
      TargetFocus(
        identify: "TutorialTarget",
        keyTarget: keyTutorialField,
        shape: ShapeLightFocus.RRect,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Tutorial",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 20.0,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text(
                    "Volte a este tutorial sempre que achar necessário clicando aqui.",
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
      hideSkip: true,
      useSafeArea: true,
      skipWidget: null,
      showSkipInLastTarget: false,
      onClickTarget: (target) {
        log(target.toString(), name: "TutorialCoachMark");

        // Logic to switch tabs during tutorial
        if (target.identify == "BibleVersionTarget") {
          context.read<TabControllerCubit>().changeTo(1); // Go to Search
        } else if (target.identify == "SearchTabTarget") {
          context.read<TabControllerCubit>().changeTo(2); // Go to Studies
        } else if (target.identify == "StudiesTabTarget") {
          context.read<TabControllerCubit>().changeTo(3); // Go to Profile
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
