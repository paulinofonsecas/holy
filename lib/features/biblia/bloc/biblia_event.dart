part of 'biblia_bloc.dart';

@immutable
sealed class BibliaEvent extends Equatable {}

class GetChapter extends BibliaEvent {
  final String version;
  final String book;
  final String chapter;
  final int? verse;

  GetChapter(this.version, this.book, this.chapter, {this.verse});

  @override
  List<Object?> get props => [version, book, chapter, verse];
}
