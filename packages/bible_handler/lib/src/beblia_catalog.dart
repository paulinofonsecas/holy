import 'dart:convert';

import 'package:http/http.dart' as http;

/// Entrada do catálogo Beblia derivada do nome do arquivo.
///
/// Os XMLs do corpus não trazem metadados de idioma/sigla, então tudo é
/// derivado do nome do arquivo: `{Idioma}{Variante?}{Ano?}Bible.xml`
/// (ex.: `PortugueseNAABible.xml`, `Afrikaans1983Bible.xml`).
class BebliaCatalogEntry {
  const BebliaCatalogEntry({
    required this.fileName,
    required this.id,
    required this.title,
    required this.language,
    required this.downloadUrl,
    this.year,
    this.sizeBytes,
  });

  /// Nome original do arquivo no corpus (ex.: `PortugueseNAABible.xml`).
  final String fileName;

  /// Identificador estável usado como version_id no cache FTS.
  final String id;

  /// Título de exibição (ex.: `Portuguese NAA`).
  final String title;

  /// Nome do idioma de exibição (ex.: `Português`); null quando desconhecido.
  final String? language;

  /// Ano extraído do nome do arquivo, quando presente (ex.: 1983).
  final int? year;

  /// URL de download (raw.githubusercontent.com).
  final String downloadUrl;

  /// Tamanho do arquivo, quando informado pelo catálogo.
  final int? sizeBytes;

  BebliaCatalogEntry copyWith({
    String? title,
    String? language,
    int? sizeBytes,
  }) {
    return BebliaCatalogEntry(
      fileName: fileName,
      id: id,
      title: title ?? this.title,
      language: language ?? this.language,
      year: year,
      downloadUrl: downloadUrl,
      sizeBytes: sizeBytes ?? this.sizeBytes,
    );
  }

  Map<String, dynamic> toMap() => {
        'fileName': fileName,
        'id': id,
        'title': title,
        'language': language,
        'year': year,
        'downloadUrl': downloadUrl,
        'sizeBytes': sizeBytes,
      };

  factory BebliaCatalogEntry.fromMap(Map<String, dynamic> map) =>
      BebliaCatalogEntry(
        fileName: map['fileName'] as String,
        id: map['id'] as String,
        title: map['title'] as String,
        language: map['language'] as String?,
        year: map['year'] as int?,
        downloadUrl: map['downloadUrl'] as String,
        sizeBytes: map['sizeBytes'] as int?,
      );
}

/// Catálogo em runtime das Bíblias do repositório
/// [Beblia/Holy-Bible-XML-Format](https://github.com/Beblia/Holy-Bible-XML-Format)
/// (1000+ versões, 200+ idiomas).
///
/// Busca a listagem via GitHub Contents API (best-effort — falha de rede
/// retorna lista vazia) e deriva os metadados do nome do arquivo, pois os
/// XMLs não trazem idioma/sigla. Nota: a API limita a 1000 entradas por
/// chamada (51 arquivos omitidos no repositório atual).
class BebliaCatalog {
  BebliaCatalog({http.Client? client}) : _client = client ?? http.Client();

  static const String _contentsApiUrl =
      'https://api.github.com/repos/Beblia/Holy-Bible-XML-Format/contents/';
  static const String _rawBaseUrl =
      'https://raw.githubusercontent.com/Beblia/Holy-Bible-XML-Format/master/';

  final http.Client _client;

  Future<List<BebliaCatalogEntry>> fetch() async {
    try {
      final response = await _client.get(
        Uri.parse(_contentsApiUrl),
        headers: {'Accept': 'application/vnd.github+json'},
      );
      if (response.statusCode != 200) return const [];

      final data = json.decode(response.body) as List<dynamic>;
      return data
          .whereType<Map<String, dynamic>>()
          .where((info) => (info['name'] as String? ?? '').endsWith('.xml'))
          .map(_entryFromFileInfo)
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  /// Converte uma entrada da Contents API em [BebliaCatalogEntry].
  BebliaCatalogEntry? entryFromFileInfo(Map<String, dynamic> info) {
    final name = info['name'] as String?;
    if (name == null || !name.endsWith('.xml')) return null;
    return _entryFromFileInfo(info);
  }

  BebliaCatalogEntry _entryFromFileInfo(Map<String, dynamic> info) {
    final fileName = info['name'] as String;
    final stem = fileName.substring(0, fileName.length - '.xml'.length);

    return BebliaCatalogEntry(
      fileName: fileName,
      id: stem,
      title: _titleFor(stem),
      language: _languageFor(stem),
      year: _yearFor(stem),
      downloadUrl: '$_rawBaseUrl$fileName',
      sizeBytes: info['size'] as int?,
    );
  }

  /// Título de exibição: remove o sufixo `Bible` e quebra camelCase
  /// (ex.: `PortugueseNAABible` → `Portuguese NAA`).
  static String _titleFor(String stem) {
    var code = stem;
    if (code.endsWith('Bible')) code = code.substring(0, code.length - 5);
    return code
        .replaceAllMapped(
          RegExp(r'(?<=[a-z0-9])(?=[A-Z])|(?<=[A-Z])(?=[A-Z][a-z])'),
          (m) => ' ',
        )
        .replaceAllMapped(
          // Espaço entre letras e números (ex.: `Afrikaans1983`).
          RegExp(r'(?<=\D)(?=\d)|(?<=\d)(?=\D)'),
          (m) => ' ',
        )
        .trim();
  }

  /// Idioma de exibição: prefixo conhecido do corpus; fallback = próprio
  /// prefixo camelCase separado.
  static String? _languageFor(String stem) {
    final sorted = _knownLanguages.keys.toList()
      ..sort((a, b) => b.length.compareTo(a.length));
    for (final prefix in sorted) {
      if (stem.startsWith(prefix)) {
        return _knownLanguages[prefix];
      }
    }
    return null;
  }

  /// Ano publicado no nome do arquivo (ex.: `Afrikaans1983Bible` → 1983).
  static int? _yearFor(String stem) {
    final matches = RegExp(r'\d{4}').allMatches(stem);
    if (matches.isEmpty) return null;
    return int.tryParse(matches.last.group(0)!);
  }
}

/// Prefixos de idioma observados no corpus Beblia → nome de exibição.
const Map<String, String> _knownLanguages = {
  'Portuguese': 'Português',
  'English': 'Inglês',
  'Spanish': 'Espanhol',
  'French': 'Francês',
  'German': 'Alemão',
  'Italian': 'Italiano',
  'Dutch': 'Holandês',
  'Russian': 'Russo',
  'Ukrainian': 'Ucraniano',
  'Polish': 'Polonês',
  'Romanian': 'Romeno',
  'Hungarian': 'Húngaro',
  'Czech': 'Tcheco',
  'Slovakian': 'Eslovaco',
  'Slovenian': 'Esloveno',
  'Croatian': 'Croata',
  'Serbian': 'Sérvio',
  'Bulgarian': 'Búlgaro',
  'Greek': 'Grego',
  'Hebrew': 'Hebraico',
  'Arabic': 'Árabe',
  'Persian': 'Persa',
  'Turkish': 'Turco',
  'Swahili': 'Suaíli',
  'Chinese': 'Chinês',
  'Japanese': 'Japonês',
  'Korean': 'Coreano',
  'Vietnamese': 'Vietnamita',
  'Thai': 'Tailandês',
  'Indonesian': 'Indonésio',
  'Malayalam': 'Malaiala',
  'Tamil': 'Tâmil',
  'Telugu': 'Télugo',
  'Kannada': 'Kannada',
  'Bengali': 'Bengali',
  'Hindi': 'Hindi',
  'Marathi': 'Marata',
  'Gujarati': 'Guzerate',
  'Punjabi': 'Punjabi',
  'Afrikaans': 'Africânder',
  'Danish': 'Dinamarquês',
  'Swedish': 'Sueco',
  'Norwegian': 'Norueguês',
  'Finnish': 'Finlandês',
  'Icelandic': 'Islandês',
  'Estonian': 'Estoniano',
  'Latvian': 'Letão',
  'Lithuanian': 'Lituano',
  'Basque': 'Basco',
  'Catalan': 'Catalão',
  'Galacian': 'Galego',
  'Latin': 'Latim',
  'Esperanto': 'Esperanto',
  'Albanian': 'Albanês',
  'Armenian': 'Armênio',
  'Georgian': 'Georgiano',
  'Azerbaijan': 'Azerbaijão',
  'Kazakhstan': 'Cazaque',
  'Nepali': 'Nepalês',
  'Burmese': 'Birmanês',
  'Khmer': 'Khmer',
  'Lao': 'Laosiano',
  'Mongolian': 'Mongol',
  'Tagalog': 'Tagalo',
  'Cebuano': 'Cebuano',
  'Maori': 'Maori',
  'Haitian': 'Haitiano',
  'Quechuan': 'Quíchua',
  'Guarani': 'Guarani',
  'Amharic': 'Amárico',
  'Somalian': 'Somali',
  'Hausa': 'Hauçá',
  'Yoruba': 'Iorubá',
  'Igbo': 'Igbo',
  'Twi': 'Twi',
  'Zulu': 'Zulu',
};
