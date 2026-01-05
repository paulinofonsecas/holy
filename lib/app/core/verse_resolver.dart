import 'package:freezed_annotation/freezed_annotation.dart';

part 'verse_resolver.freezed.dart';
part 'verse_resolver.g.dart';

@freezed
class VerseReference with _$VerseReference {
  const factory VerseReference({
    required String book,
    required int chapter,
    required int verse,
    String? version,
  }) = _VerseReference;

  factory VerseReference.fromJson(Map<String, dynamic> json) =>
      _$VerseReferenceFromJson(json);
}

abstract class VerseResolver {
  /// Validates if a [VerseReference] is valid in the local database.
  Future<bool> isValid(VerseReference ref);

  /// Resolves a [VerseReference] to a local position or ID.
  Future<dynamic> resolve(VerseReference reference);

  /// Maps a local position back to a [VerseReference].
  Future<VerseReference> reverseResolve(dynamic localPosition);
}
