part of 'bible_version_cubit.dart';

class BibleVersionState extends Equatable {
  final BibleVersions version;

  BibleVersionState({required this.version});

  @override
  List<Object?> get props => [];
}

enum BibleVersions {
  acf(id: 'ACF', name: 'Almeida Corrigida e Fiel'),
  jfaa(id: 'JFAA', name: 'Almeida Atualizada'),
  kja(id: 'KJA', name: 'King James Atualizada'),
  kjf(id: 'KJF', name: 'King James Fiel'),
  // ntlh(id: 'NTLH', name: 'Nova Tradução na Linguagem de Hoje '),
  nvi(id: 'NVI', name: 'Nova Versão Internacional');

  const BibleVersions({required this.id, required this.name});

  final String id;
  final String name;
}

class BibleVersionStateACF extends BibleVersionState {
  BibleVersionStateACF() : super(version: BibleVersions.acf);
}

class BibleVersionStateJFAA extends BibleVersionState {
  BibleVersionStateJFAA() : super(version: BibleVersions.jfaa);
}

class BibleVersionStateKJA extends BibleVersionState {
  BibleVersionStateKJA() : super(version: BibleVersions.kja);
}

class BibleVersionStateKJF extends BibleVersionState {
  BibleVersionStateKJF() : super(version: BibleVersions.kjf);
}

// class BibleVersionStateNTLH extends BibleVersionState {
//   BibleVersionStateNTLH() : super(version: BibleVersions.ntlh);
// }

class BibleVersionStateNVI extends BibleVersionState {
  BibleVersionStateNVI() : super(version: BibleVersions.nvi);
}
