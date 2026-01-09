enum JoinOperator { none, and, or }

/// Represents a single part of a complex search query.
class SearchQueryPart {
  final String term;
  final JoinOperator operator;

  const SearchQueryPart({
    required this.term,
    this.operator = JoinOperator.none,
  });

  Map<String, dynamic> toMap() {
    return {'term': term, 'operator': operator.name};
  }

  factory SearchQueryPart.fromMap(Map<String, dynamic> map) {
    return SearchQueryPart(
      term: map['term'] as String,
      operator: JoinOperator.values.byName(map['operator'] as String),
    );
  }

  SearchQueryPart copyWith({String? term, JoinOperator? operator}) {
    return SearchQueryPart(
      term: term ?? this.term,
      operator: operator ?? this.operator,
    );
  }
}
