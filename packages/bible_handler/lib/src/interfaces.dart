import 'models.dart';

/// Interface for Bible search functionality.
abstract class BibleSearchProvider {
  /// Searches for verses containing the given [query].
  ///
  /// If [versionId] is provided, searches only in that version.
  /// Otherwise, searches in the active version.
  Future<SearchResults> search({
    required String query,
    String? versionId,
    bool prioritizeHighlights = false,
  });

  /// Searches for verses containing the given [query] across all available versions.
  Future<SearchResults> searchAllVersions({required String query});

  /// Performs a search combining multiple queries with join logic.
  Future<SearchResults> advancedSearch({
    required List<SearchQueryPart> queries,
    String? versionId,
    bool prioritizeHighlights = false,
  });

  /// Searches for books whose name, long name, or abbreviation matches the [query].
  Future<List<Book>> matchBooks({required String query, String? versionId});

  /// Retrieves a random verse from the database based on criteria.
  Future<SearchResult?> getRandomVerse({
    String? versionId,
    List<String>? bookIds,
  });
}

/// Interface for verse interaction functionality (marking, sharing, categories).
abstract class VerseInteractionProvider {
  /// Marks a verse with a specific color or style.
  Future<void> markVerse({
    required String versionId,
    required String bookId,
    required int chapterNumber,
    required int verseNumber,
    String? color,
    String? categoryId,
  });

  /// Unmarks a verse.
  Future<void> unmarkVerse({
    required String versionId,
    required String bookId,
    required int chapterNumber,
    required int verseNumber,
  });

  /// Gets all marked verses.
  Future<List<SearchResult>> getMarkedVerses({String? categoryId});

  /// Creates a new category for grouping verses.
  Future<String> createCategory({required String name, String? color});

  /// Deletes a category.
  Future<void> deleteCategory(String categoryId);

  /// Gets all categories.
  Future<List<VerseCategory>> getCategories();
}

/// Model for a verse category.
class VerseCategory {
  final String id;
  final String name;
  final String? color;

  VerseCategory({required this.id, required this.name, this.color});

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'color': color};
  }

  factory VerseCategory.fromMap(Map<String, dynamic> map) {
    return VerseCategory(
      id: map['id'] as String,
      name: map['name'] as String,
      color: map['color'] as String?,
    );
  }
}
