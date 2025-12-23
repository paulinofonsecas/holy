import 'dart:convert';

import 'package:bible_handler/bible_handler.dart';
import 'package:dio/dio.dart';
import 'package:eu_sou/core/data/provider/interfaces/i_bible_provider.dart';

class XmlBibleProvider extends IBibleProvider {
  XmlBibleProvider(this.dio);

  final Dio dio;

  @override
  Future<List<Chapter>> getCapitulos(String versionId, String bookId) async {
    try {
      final version = 'ACF';
      final response =
          await dio.get('http://192.168.0.164:8081/versions/$version/$bookId');

      if (response.statusCode == 200) {
        late Map<String, dynamic> data;

        if (response.data is String) {
          data = Map<String, dynamic>.from(
            (response.data as String).isNotEmpty
                ? jsonDecode(response.data)
                : {},
          );
        } else {
          data = response.data;
        }

        final chapters = <Chapter>[];

        data['chapters'].forEach((chapter) {
          final chapterModel = Chapter.fromMap(chapter);
          chapters.add(chapterModel);
        });

        return chapters;
      } else {
        throw Exception('Failed to fetch chapters');
      }
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<InfoBook>> getLivros(String version) async {
    try {
      final response =
          await dio.get('http://192.168.0.164:8081/versions/$version');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final books = <InfoBook>[];

        data['books'].forEach((chapter) {
          final bookModel = InfoBook.fromMap(chapter);
          books.add(bookModel);
        });

        return books;
      } else {
        throw Exception('Failed to fetch books');
      }
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<String>> getVersoes() async {
    try {
      final response = await dio.get('http://192.168.0.164:8081/versions');

      if (response.statusCode == 200) {
        final data = response.data as List<dynamic>;
        final versions = data;

        return versions.map((e) => e.toString()).toList();
      } else {
        throw Exception('Failed to fetch chapters');
      }
    } catch (e) {
      return [];
    }
  }

  @override
  Future<Chapter> getChapter(
      String versionId, String bookId, String chapterId) async {
    try {
      final response = await dio.get(
          'http://192.168.0.164:8081/versions/$versionId/$bookId/$chapterId');

      if (response.statusCode == 200) {
        late Map<String, dynamic> data;

        if (response.data is String) {
          data = Map<String, dynamic>.from(
            (response.data as String).isNotEmpty
                ? jsonDecode(response.data)
                : {},
          );
        } else {
          data = response.data;
        }

        final chapter = Chapter.fromMap(data);
        return chapter;
      } else {
        throw Exception('Failed to fetch chapters');
      }
    } catch (e) {
      rethrow;
    }
  }
}
