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
  ara(
    id: 'ARA',
    name: 'Almeida Revista e Atualizada',
    language: 'Português',
    year: 1993,
  ),
  arc(
    id: 'ARC',
    name: 'Almeida Revista e Corrigida',
    language: 'Português',
    year: 1995,
  ),
  as21(
    id: 'AS21',
    name: 'Almeida Século 21',
    language: 'Português',
    year: 2009,
  ),
  jfaa(
    id: 'JFAA',
    name: 'Almeida Atualizada',
    language: 'Português',
  ),
  kja(
    id: 'KJA',
    name: 'King James Atualizada',
    language: 'Português',
    year: 1999,
  ),
  kjf(
    id: 'KJF',
    name: 'King James Fiel',
    language: 'Português',
    year: 1611,
  ),
  naa(
    id: 'NAA',
    name: 'Nova Almeida Atualizada',
    language: 'Português',
    year: 2017,
  ),
  nbv(
    id: 'NBV',
    name: 'Nova Bíblia Viva',
    language: 'Português',
    year: 2007,
  ),
  ntlh(
    id: 'NTLH',
    name: 'Nova Tradução na Linguagem de Hoje',
    language: 'Português',
    year: 1988,
  ),
  nvi(
    id: 'NVI',
    name: 'Nova Versão Internacional',
    language: 'Português',
  ),
  nvt(
    id: 'NVT',
    name: 'Nova Versão Transformadora',
    language: 'Português',
    year: 2016,
  ),
  tb(
    id: 'TB',
    name: 'Tradução Brasileira',
    language: 'Português',
    year: 2010,
  );

  const BibleVersions({
    required this.id,
    required this.name,
    required this.language,
    this.year,
  });

  final String id;
  final String name;

  /// Idioma principal da tradução (ex.: `Português`).
  final String language;

  /// Ano de publicação da tradução (ex.: `1994`). Null quando desconhecido
  /// (ex.: JFAA, NVI).
  final int? year;

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

class BibleVersionStateARA extends BibleVersionState {
  const BibleVersionStateARA() : super(version: BibleVersions.ara);
}

class BibleVersionStateAS21 extends BibleVersionState {
  const BibleVersionStateAS21() : super(version: BibleVersions.as21);
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

class BibleVersionStateNAA extends BibleVersionState {
  const BibleVersionStateNAA() : super(version: BibleVersions.naa);
}

class BibleVersionStateNBV extends BibleVersionState {
  const BibleVersionStateNBV() : super(version: BibleVersions.nbv);
}

class BibleVersionStateNTLH extends BibleVersionState {
  const BibleVersionStateNTLH() : super(version: BibleVersions.ntlh);
}

class BibleVersionStateNVI extends BibleVersionState {
  const BibleVersionStateNVI() : super(version: BibleVersions.nvi);
}

class BibleVersionStateNVT extends BibleVersionState {
  const BibleVersionStateNVT() : super(version: BibleVersions.nvt);
}

class BibleVersionStateTB extends BibleVersionState {
  const BibleVersionStateTB() : super(version: BibleVersions.tb);
}
