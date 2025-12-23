// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:bible_handler/bible_handler.dart';

class BibleVerse {
  final int number;
  final String text;

  BibleVerse({required this.number, required this.text});

  @override
  String toString() {
    return '$number $text';
  }
}

class BibleBook {
  final String id;
  final String name;
  final List<Chapter> chapters;

  BibleBook({required this.id, required this.name, required this.chapters});

  @override
  String toString() {
    return '$name ($id) - ${chapters.length} chapters';
  }
}

class BiblePassage {
  final String name;
  final List<BibleVerse> verses;

  BiblePassage({required this.name, required this.verses});

  @override
  String toString() {
    return '$name: ${verses.map((e) => e.toString()).join(' ')}';
  }
}

class BibleChapter {
  final String bookId;
  final String? bookName;
  final int number;
  final List<BibleVerse> verses;

  BibleChapter({
    required this.bookId,
    required this.number,
    required this.verses,
    this.bookName,
  });

  factory BibleChapter.fromMap(Map<String, dynamic> map) {
    final verses = <BibleVerse>[];

    map['verses'].forEach((verse) {
      final verseModel = BibleVerse(
        number: verse['number'],
        text: verse['text'],
      );
      verses.add(verseModel);
    });

    return BibleChapter(
      bookId: '',
      bookName: '',
      number: map['number'],
      verses: verses,
    );
  }

  @override
  String toString() {
    return 'Chapter $number: ${verses.map((e) => e.number.toString()).join(', ')}';
  }

  BibleChapter copyWith({
    String? bookId,
    String? bookName,
    int? number,
    List<BibleVerse>? verses,
  }) {
    return BibleChapter(
      bookId: bookId ?? this.bookId,
      number: number ?? this.number,
      verses: verses ?? this.verses,
      bookName: bookName ?? this.bookName,
    );
  }
}

enum BibleBooks {
  genesis(bookId: 'GEN', book: 'Gênesis', chapterCount: 50),
  exodus(bookId: 'EXO', book: 'Êxodo', chapterCount: 40),
  leviticus(bookId: 'LEV', book: 'Levítico', chapterCount: 27),
  numbers(bookId: 'NUM', book: 'Números', chapterCount: 36),
  deuteronomy(bookId: 'DEU', book: 'Deuteronômio', chapterCount: 34),
  joshua(bookId: 'JOS', book: 'Josué', chapterCount: 24),
  judges(bookId: 'JDG', book: 'Juízes', chapterCount: 21),
  ruth(bookId: 'RUT', book: 'Rute', chapterCount: 4),
  samuel1(bookId: '1SA', book: '1 Samuel', chapterCount: 31),
  samuel2(bookId: '2SA', book: '2 Samuel', chapterCount: 24),
  kings1(bookId: '1KI', book: '1 Reis', chapterCount: 22),
  kings2(bookId: '2KI', book: '2 Reis', chapterCount: 25),
  chronicles1(bookId: '1CH', book: '1 Crônicas', chapterCount: 29),
  chronicles2(bookId: '2CH', book: '2 Crônicas', chapterCount: 36),
  ezra(bookId: 'EZR', book: 'Esdras', chapterCount: 10),
  nehemiah(bookId: 'NEH', book: 'Neemias', chapterCount: 13),
  esther(bookId: 'EST', book: 'Ester', chapterCount: 10),
  job(bookId: 'JOB', book: 'Jó', chapterCount: 42),
  psalm(bookId: 'PSA', book: 'Salmos', chapterCount: 150),
  proverbs(bookId: 'PRO', book: 'Provérbios', chapterCount: 31),
  ecclesiastes(bookId: 'ECC', book: 'Eclesiastes', chapterCount: 12),
  songOfSongs(bookId: 'SNG', book: 'Cantares de Salomão', chapterCount: 8),
  isaiah(bookId: 'ISA', book: 'Isaías', chapterCount: 66),
  jeremiah(bookId: 'JER', book: 'Jeremias', chapterCount: 52),
  lamentations(bookId: 'LAM', book: 'Lamentações', chapterCount: 5),
  ezekiel(bookId: 'EZK', book: 'Ezequiel', chapterCount: 48),
  daniel(bookId: 'DAN', book: 'Daniel', chapterCount: 12),
  hosea(bookId: 'HOS', book: 'Oséias', chapterCount: 14),
  joel(bookId: 'JOL', book: 'Joel', chapterCount: 3),
  amos(bookId: 'AMO', book: 'Amós', chapterCount: 9),
  obadiah(bookId: 'OBA', book: 'Obadias', chapterCount: 1),
  jonah(bookId: 'JON', book: 'Jonas', chapterCount: 4),
  micah(bookId: 'MIC', book: 'Miquéias', chapterCount: 7),
  nahum(bookId: 'NAM', book: 'Naum', chapterCount: 3),
  habakkuk(bookId: 'HAB', book: 'Habacuque', chapterCount: 3),
  zephaniah(bookId: 'ZEP', book: 'Sofonias', chapterCount: 3),
  haggai(bookId: 'HAG', book: 'Ageu', chapterCount: 2),
  zechariah(bookId: 'ZEC', book: 'Zacarias', chapterCount: 14),
  malachi(bookId: 'MAL', book: 'Malaquias', chapterCount: 4),

  matthew(bookId: 'MAT', book: 'Mateus', chapterCount: 28),
  mark(bookId: 'MRK', book: 'Marcos', chapterCount: 16),
  luke(bookId: 'LUK', book: 'Lucas', chapterCount: 24),
  john(bookId: 'JHN', book: 'João', chapterCount: 21),
  acts(bookId: 'ACT', book: 'Atos', chapterCount: 28),
  romans(bookId: 'ROM', book: 'Romanos', chapterCount: 16),
  corinthians1(bookId: '1CO', book: '1 Coríntios', chapterCount: 16),
  corinthians2(bookId: '2CO', book: '2 Coríntios', chapterCount: 13),
  galatians(bookId: 'GAL', book: 'Gálatas', chapterCount: 6),
  ephesians(bookId: 'EPH', book: 'Efésios', chapterCount: 6),
  philippians(bookId: 'PHP', book: 'Filipenses', chapterCount: 4),
  colossians(bookId: 'COL', book: 'Colossenses', chapterCount: 4),
  thessalonians1(bookId: '1TH', book: '1 Tessalonicenses', chapterCount: 5),
  thessalonians2(bookId: '2TH', book: '2 Tessalonicenses', chapterCount: 3),
  timothy1(bookId: '1TI', book: '1 Timóteo', chapterCount: 6),
  timothy2(bookId: '2TI', book: '2 Timóteo', chapterCount: 4),
  titus(bookId: 'TIT', book: 'Tito', chapterCount: 3),
  philemon(bookId: 'PHM', book: 'Filemom', chapterCount: 1),
  hebrews(bookId: 'HEB', book: 'Hebreus', chapterCount: 13),
  james(bookId: 'JAS', book: 'Tiago', chapterCount: 5),
  peter1(bookId: '1PE', book: '1 Pedro', chapterCount: 5),
  peter2(bookId: '2PE', book: '2 Pedro', chapterCount: 3),
  john1(bookId: '1JN', book: '1 João', chapterCount: 5),
  john2(bookId: '2JN', book: '2 João', chapterCount: 1),
  john3(bookId: '3JN', book: '3 João', chapterCount: 1),
  jude(bookId: 'JUD', book: 'Judas', chapterCount: 1),
  revelation(bookId: 'APC', book: 'Apocalipse', chapterCount: 22);

  final String bookId;
  final String book;
  final int chapterCount;

  const BibleBooks({
    required this.bookId,
    required this.book,
    required this.chapterCount,
  });
}
