import 'dart:async';

/// A broadcast stream that fires whenever a highlight is added or removed.
/// Used to keep [MarkedVersesBloc] in sync with [HighlightBloc] changes.
class HighlightChangedNotifier {
  final _controller = StreamController<void>.broadcast();

  Stream<void> get stream => _controller.stream;

  void notify() => _controller.add(null);

  void dispose() => _controller.close();
}
