// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert' show json;

import '../models.dart' show Book, SearchResult, SearchResults;

class Bible {
  final String name;
  final String abbreviation;
  final String? nameLocal;
  final String? description;
  final String? scope;
  final String? bundleProducer;
  final String? languageName;
  final String? languageIso;
  final String? languageScript;
  final String? languageScriptCode;
  final String? languageScriptDirection;
  final String? copyright;
  final List<Book> books;
  String? directoryPathSaved;


  Bible({
    required this.name,
    required this.abbreviation,
    this.nameLocal,
    this.description,
    this.scope,
    this.bundleProducer,
    this.languageName,
    this.languageIso,
    this.languageScript,
    this.languageScriptCode,
    this.languageScriptDirection,
    this.copyright,
    required this.books,
    this.directoryPathSaved,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'abbreviation': abbreviation,
      'nameLocal': nameLocal,
      'description': description,
      'scope': scope,
      'bundleProducer': bundleProducer,
      'languageName': languageName,
      'languageIso': languageIso,
      'languageScript': languageScript,
      'languageScriptCode': languageScriptCode,
      'languageScriptDirection': languageScriptDirection,
      'copyright': copyright,
      'books': books.map((x) => x.toMap()).toList(),
      'directoryPathSaved': directoryPathSaved,
    };
  }

  factory Bible.fromMap(Map<String, dynamic> map) {
    return Bible(
      name: map['name'] as String,
      abbreviation: map['abbreviation'] as String,
      nameLocal: map['nameLocal'] as String?,
      description: map['description'] as String?,
      scope: map['scope'] as String?,
      bundleProducer: map['bundleProducer'] as String?,
      languageName: map['languageName'] as String?,
      languageIso: map['languageIso'] as String?,
      languageScript: map['languageScript'] as String?,
      languageScriptCode: map['languageScriptCode'] as String?,
      languageScriptDirection: map['languageScriptDirection'] as String?,
      copyright: map['copyright'] as String?,
      books: List<Book>.from(
        (map['books'] as List<dynamic>).map<Book>(
          (x) => Book.fromMap(x as Map<String, dynamic>),
        ),
      ),
      directoryPathSaved: map['directoryPathSaved'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory Bible.fromJson(String source) =>
      Bible.fromMap(json.decode(source) as Map<String, dynamic>);

  SearchResults search(String query) {
    final results = <SearchResult>[];
    final lowerCaseQuery = query.toLowerCase();

    for (final book in books) {
      for (final chapter in book.chapters) {
        for (final verse in chapter.verses) {
          if (verse.text.toLowerCase().contains(lowerCaseQuery)) {
            results.add(SearchResult(book: book, chapter: chapter, verse: verse));
          }
        }
      }
    }
    return SearchResults(query: query, totalResults: results.length, results: results);
  }

  @override
  String toString() {
    return 'Bible(name: $name, abbreviation: $abbreviation, nameLocal: $nameLocal, description: $description, scope: $scope, bundleProducer: $bundleProducer, languageName: $languageName, languageIso: $languageIso, languageScript: $languageScript, languageScriptCode: $languageScriptCode, languageScriptDirection: $languageScriptDirection, copyright: $copyright, books: $books)';
  }
}
