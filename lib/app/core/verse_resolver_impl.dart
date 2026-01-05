import 'package:eu_sou/core/data/repositories/interfaces/i_bible_repository.dart';

import 'verse_resolver.dart';

class VerseResolverImpl implements VerseResolver {
  final IBibleRepository _repository;

  VerseResolverImpl(this._repository);

  @override
  Future<bool> isValid(VerseReference ref) async {
    try {
      // We can check if the book and chapter exist.
      // For simplicity, we'll just try to fetch the chapter.
      final chapter = await _repository.getChapter(
          ref.version ?? 'nvi', ref.book, ref.chapter.toString());

      // Check if verse exists in chapter
      return chapter.verses.any((v) => v.number == ref.verse);
    } catch (_) {
      return false;
    }
  }

  Future<String?> resolveToLocalId(VerseReference ref) async {
    // In this app, we don't really use a single "local ID" for navigation,
    // we use (version, book, chapter, verse).
    // So this might return a formatted string or just null if we don't need it.
    return '${ref.version}:${ref.book}:${ref.chapter}:${ref.verse}';
  }

  @override
  Future resolve(VerseReference reference) async {
    return resolveToLocalId(reference);
  }

  @override
  Future<VerseReference> reverseResolve(localPosition) {
    throw UnimplementedError();
  }
}
