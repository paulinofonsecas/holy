import 'package:equatable/equatable.dart';

class PanelConfig extends Equatable {
  final String id;
  final String colorHex;
  final String versionId;
  final String bookId;
  final int chapter;
  final double scrollOffset;

  /// Layout weight of the panel in the multiversion Flex (default 1.0 →
  /// equal split). Saved with the session so layouts restore as-is.
  final double flex;

  const PanelConfig({
    required this.id,
    required this.colorHex,
    required this.versionId,
    required this.bookId,
    required this.chapter,
    this.scrollOffset = 0.0,
    this.flex = 1.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'colorHex': colorHex,
      'versionId': versionId,
      'bookId': bookId,
      'chapter': chapter,
      'scrollOffset': scrollOffset,
      'flex': flex,
    };
  }

  factory PanelConfig.fromJson(Map<String, dynamic> json) {
    return PanelConfig(
      id: json['id'] as String,
      colorHex: json['colorHex'] as String,
      versionId: json['versionId'] as String,
      bookId: json['bookId'] as String,
      chapter: json['chapter'] as int,
      scrollOffset: (json['scrollOffset'] as num?)?.toDouble() ?? 0.0,
      flex: (json['flex'] as num?)?.toDouble() ?? 1.0,
    );
  }

  PanelConfig copyWith({
    String? id,
    String? colorHex,
    String? versionId,
    String? bookId,
    int? chapter,
    double? scrollOffset,
    double? flex,
  }) {
    return PanelConfig(
      id: id ?? this.id,
      colorHex: colorHex ?? this.colorHex,
      versionId: versionId ?? this.versionId,
      bookId: bookId ?? this.bookId,
      chapter: chapter ?? this.chapter,
      scrollOffset: scrollOffset ?? this.scrollOffset,
      flex: flex ?? this.flex,
    );
  }

  @override
  List<Object?> get props =>
      [id, colorHex, versionId, bookId, chapter, scrollOffset, flex];
}

class MultiversionSession extends Equatable {
  final String id;
  final String name;
  final DateTime createdAt;
  final List<PanelConfig> panels;

  const MultiversionSession({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.panels,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'panels': panels.map((p) => p.toJson()).toList(),
    };
  }

  factory MultiversionSession.fromJson(Map<String, dynamic> json) {
    return MultiversionSession(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      panels: (json['panels'] as List)
          .map((p) => PanelConfig.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [id, name, createdAt, panels];
}
