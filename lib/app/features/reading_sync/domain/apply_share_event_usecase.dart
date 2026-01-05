import 'models/models.dart';

class ApplyShareEventResult {
  ApplyShareEventResult({
    required this.verseRef,
    required this.localPosition,
  });

  final VerseReference verseRef;
  final dynamic localPosition;
}

/// Resolves ShareVerse events to local positions for UI consumption.
class ApplyShareEventUseCase {
  ApplyShareEventUseCase(this._resolver);

  final VerseResolver _resolver;

  Future<ApplyShareEventResult?> call(ShareEvent event) async {
    if (event.type != ShareEventType.shareVerse) return null;
    final isValid = await _resolver.isValid(event.verseRef);
    if (!isValid) return null;
    final position = await _resolver.resolve(event.verseRef);
    return ApplyShareEventResult(
      verseRef: event.verseRef,
      localPosition: position,
    );
  }
}
