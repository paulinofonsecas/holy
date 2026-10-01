import 'package:flutter/foundation.dart';

/// Estado global de visibilidade da NavigationBar durante a leitura
/// (hide-on-scroll imersivo). A BibliaView atualiza; o MainScaffold observa.
class BottomBarVisibilityNotifier extends ChangeNotifier {
  bool _visible = true;
  bool get visible => _visible;

  void setVisible(bool visible) {
    if (_visible == visible) return;
    _visible = visible;
    notifyListeners();
  }
}
