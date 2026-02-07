import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

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
            align: ContentAlign.bottom,
            child: const Column(
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
                  padding: EdgeInsets.only(top: 10.0),
                  child: Text(
                    "Aqui você pode ler e explorar todos os livros da Bíblia. Toque para começar sua leitura diária.",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    _targets.add(
      TargetFocus(
        identify: "SearchTarget",
        keyTarget: keySearchTab,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Pesquisa Avançada",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 20.0,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Text(
                    "Encontre rapidamente versículos, temas ou palavras-chave em toda a Bíblia.",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
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
                  padding: EdgeInsets.only(top: 10.0),
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
      colorShadow: Colors.black.withValues(alpha: 0.8),
      onClickTarget: (target) {
        debugPrint(target.toString());
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
