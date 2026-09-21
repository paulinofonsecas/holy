part of 'bible_version_cubit.dart';

class BibleVersionState extends Equatable {
  final BibleVersions version;

  const BibleVersionState({required this.version});

  @override
  List<Object?> get props => [version];
}

enum BibleVersions {
  acf(
    id: 'ACF',
    name: 'Almeida Corrigida e Fiel',
    language: 'Português',
    year: 1994,
  ),
  arc(
    id: 'ARC',
    name: 'Almeida Revista e Corrigida',
    language: 'Português',
    year: 1969,
  ),
  jfaa(
    id: 'JFAA',
    name: 'João Ferreira de Almeida Atualizada',
    language: 'Português',
    year: 1987,
  ),
  kja(
    id: 'KJA',
    name: 'King James Atualizada',
    language: 'Português',
    year: 2012,
  ),
  kjf(
    id: 'KJF',
    name: 'King James Fiel',
    language: 'Português',
    year: 1611,
  ),
  // ntlh(id: 'NTLH', name: 'Nova Tradução na Linguagem de Hoje '),
  nvi(
    id: 'NVI',
    name: 'Nova Versão Internacional',
    language: 'Português',
    year: 2000,
  );

  const BibleVersions({
    required this.id,
    required this.name,
    required this.language,
    required this.year,
  });

  final String id;
  final String name;

  /// Idioma principal da tradução (ex.: `Português`).
  final String language;

  /// Ano de publicação da tradução (ex.: `1994`).
  final int year;

  /// Busca uma versão pelo [id], com fallback para [BibleVersions.jfaa].
  static BibleVersions fromId(String id) {
    return BibleVersions.values.firstWhere(
      (v) => v.id.toUpperCase() == id.trim().toUpperCase(),
      orElse: () => BibleVersions.jfaa,
    );
  }
}

class BibleVersionStateACF extends BibleVersionState {
  const BibleVersionStateACF() : super(version: BibleVersions.acf);
}

class BibleVersionStateARC extends BibleVersionState {
  const BibleVersionStateARC() : super(version: BibleVersions.arc);
}

class BibleVersionStateJFAA extends BibleVersionState {
  const BibleVersionStateJFAA() : super(version: BibleVersions.jfaa);
}

class BibleVersionStateKJA extends BibleVersionState {
  const BibleVersionStateKJA() : super(version: BibleVersions.kja);
}

class BibleVersionStateKJF extends BibleVersionState {
  const BibleVersionStateKJF() : super(version: BibleVersions.kjf);
}

// class BibleVersionStateNTLH extends BibleVersionState {
//   BibleVersionStateNTLH() : super(version: BibleVersions.ntlh);
// }

class BibleVersionStateNVI extends BibleVersionState {
  const BibleVersionStateNVI() : super(version: BibleVersions.nvi);
}
