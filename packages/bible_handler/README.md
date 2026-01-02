# Bible Handler

`bible_handler` is a Dart library designed for handling and processing Bible data. It provides functionalities to load Bible versions from various sources (local directories, SQLite files, and remote URLs) and offers utilities for searching within the loaded Bible content.

## Features

*   **Flexible Bible Loading**: Load Bible data from:
    *   USX XML files within a local directory.
    *   SQLite database files.
    *   Remote ZIP archives hosted on a URL (e.g., GitHub).
*   **On-Demand Loading (Lazy Loading)**: Efficiently fetch specific books and chapters from the local SQLite cache without loading the entire Bible into memory.
*   **Bible Model**: Provides a structured Dart object model for Bibles, books, chapters, and verses.
*   **Search Functionality**: Efficiently search for text within any loaded Bible version.
*   **Book Sorting**: Supports canonical and no-op book sorting.

## Installation

Add `bible_handler` to your `pubspec.yaml`:

```yaml
dependencies:
  bible_handler: ^latest_version
```

Then, run `dart pub get`.

## Usage

### Loading a Bible from a Local Directory (USX)

```dart
import 'package:bible_handler/bible_handler.dart';

Future<void> main() async {
  try {
    final bible = await loadBibleFromDirectory('path/to/your/usx/bible');
    print('Loaded Bible: ${bible.name} (${bible.abbreviation})');
    print('Number of books: ${bible.books.length}');
  } catch (e) {
    print('Error loading Bible from directory: $e');
  }
}
```

### Loading a Bible from an SQLite File

```dart
import 'package:bible_handler/bible_handler.dart';

Future<void> main() async {
  try {
    final bible = await loadBibleFromSqlite('path/to/your/bible.sqlite');
    print('Loaded Bible: ${bible.name} (${bible.abbreviation})');
    print('Number of books: ${bible.books.length}');
  } catch (e) {
    print('Error loading Bible from SQLite: $e');
  }
}
```

### Loading a Bible from a URL (GitHub ZIP)

This method is particularly useful for fetching Bible versions hosted as ZIP archives, for example, on GitHub.

```dart
import 'package:bible_handler/bible_handler.dart';

Future<void> main() async {
  // Example: Loading the KJA version from a GitHub URL
  // The `version` parameter should correspond to the name of the ZIP file (e.g., "KJA" for KJA.zip)
  try {
    final bible = await loadBibleFromUrl('KJA');
    print('Loaded Bible: ${bible.name} (${bible.abbreviation})');
    print('Number of books: ${bible.books.length}');
  } catch (e) {
    print('Error loading Bible from URL: $e');
  }
}
```

### On-Demand Loading (Lazy Loading)

For better performance and lower memory usage, you can use `BibleCacheProvider` to load only the necessary parts of a Bible version. This is the recommended way to access Bible data in mobile applications to avoid high memory consumption and slow initial load times.

```dart
import 'package:bible_handler/bible_handler.dart';

Future<void> main() async {
  final cacheProvider = BibleCacheProvider(db); // db is a sqflite Database instance

  // Check if a version is cached
  if (await cacheProvider.isVersionCached('KJA')) {
    // Load only book metadata (ID, Name, Abbreviation)
    // This is very fast as it doesn't load any verses.
    final books = await cacheProvider.getBooks('KJA');
    print('Found ${books.length} books in KJA');
    
    // Load a specific chapter on-demand
    // This only fetches the verses for the requested chapter.
    final chapter = await cacheProvider.getChapter('KJA', 'JHN', 3);
    if (chapter != null) {
      print('John 3:16: ${chapter.verses[15].text}');
    }
  }
}
```

### Searching within a Loaded Bible

Once a `Bible` object is loaded, you can use its `search` method to find verses containing a specific query.

```dart
import 'package:bible_handler/bible_handler.dart';

Future<void> main() async {
  try {
    final bible = await loadBibleFromUrl('KJA'); // Or load from directory/sqlite
    
    final searchResults = bible.search('amor');
    print('Search results for "amor": ${searchResults.totalResults} found.');

    for (final result in searchResults.results) {
      print(
        '${result.book.name} ${result.chapter.number}:${result.verse.number} - ${result.verse.text}',
      );
    }
  } catch (e) {
    print('Error during search: $e');
  }
}
```

## Models

The library provides a set of models to represent Bible data:

*   `Bible`: Represents an entire Bible version, containing metadata and a list of books.
*   `Book`: Represents a book of the Bible, containing its ID, name, and a list of chapters.
*   `Chapter`: Represents a chapter, containing its number and a list of verses.
*   `Verse`: Represents a single verse, containing its number and text content.
*   `SearchResult`: Represents a single search match, including the book, chapter, and verse.
*   `SearchResults`: Encapsulates all results for a given search query, including the query string, total results, and a list of `SearchResult` objects.