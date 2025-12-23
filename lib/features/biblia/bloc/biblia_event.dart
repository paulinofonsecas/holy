part of 'biblia_bloc.dart';

@immutable
sealed class BibliaEvent extends Equatable {}

class GetChapter extends BibliaEvent {
  late final String version;
  late final String book;
  late final String chapter;

  GetChapter(this.version, this.book, this.chapter);

  @override
  List<Object> get props => [version, book, chapter];
}
