import 'package:eu_sou/shared/cubit/bible_version_cubit.dart';

/// Referência genérica a uma tradução selecionável da Bíblia.
///
/// Unifica as traduções oficiais (enum [BibleVersions]) e as versões da
/// comunidade (catálogo Beblia), que existem apenas em runtime e não fazem
/// parte do enum. A identidade é dada pelo [id] (ignora caixa e espaços).
class BibleVersionRef {
  const BibleVersionRef({
    required this.id,
    required this.name,
    required this.language,
    this.year,
    this.isCommunity = false,
  });

  /// Cria a referência de uma tradução oficial do enum [BibleVersions].
  factory BibleVersionRef.fromOfficial(BibleVersions version) =>
      BibleVersionRef(
        id: version.id,
        name: version.name,
        language: version.language,
        year: version.year,
      );

  /// Cria a referência de uma versão da comunidade (Beblia).
  factory BibleVersionRef.community({
    required String id,
    required String title,
    String? language,
    int? year,
  }) =>
      BibleVersionRef(
        id: id,
        name: title,
        language: language ?? 'Comunidade',
        year: year,
        isCommunity: true,
      );

  /// Busca a tradução oficial pelo [id]; `null` quando não existe no enum.
  static BibleVersionRef? tryFromOfficialId(String id) {
    final normalized = id.trim().toUpperCase();
    for (final version in BibleVersions.values) {
      if (version.id.toUpperCase() == normalized) {
        return BibleVersionRef.fromOfficial(version);
      }
    }
    return null;
  }

  /// Sigla/identificador da tradução (ex.: `ACF` ou `PortugueseNAA`).
  final String id;

  /// Nome de exibição (ex.: `Almeida Corrigida e Fiel`).
  final String name;

  /// Idioma de exibição (ex.: `Português`).
  final String language;

  /// Ano de publicação, quando conhecido.
  final int? year;

  /// `true` quando a versão vem do catálogo da comunidade (Beblia).
  final bool isCommunity;

  /// `true` quando [other] identifica a mesma tradução (case-insensitive).
  bool matchesId(String other) =>
      id.trim().toUpperCase() == other.trim().toUpperCase();

  @override
  bool operator ==(Object other) =>
      other is BibleVersionRef && other.matchesId(id);

  @override
  int get hashCode => id.trim().toUpperCase().hashCode;

  @override
  String toString() => 'BibleVersionRef($id, community: $isCommunity)';
}
