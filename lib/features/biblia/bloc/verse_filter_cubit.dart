import 'package:flutter_bloc/flutter_bloc.dart';

/// Holds the active keyword filter for Bible verse reading.
///
/// The state is a list of lowercase trimmed keywords.
/// An empty list means no filter is active.
class VerseFilterCubit extends Cubit<List<String>> {
  VerseFilterCubit() : super(const []);

  /// Parses [input] into keywords split by comma.
  void updateFilter(String input) {
    final keywords = input
        .split(',')
        .map((e) => e.trim().toLowerCase())
        .where((e) => e.isNotEmpty)
        .toList();
    emit(keywords);
  }

  void clear() => emit(const []);
}
