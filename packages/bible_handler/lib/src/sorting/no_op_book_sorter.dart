import '../models.dart';
import 'book_sorter.dart';

class NoOpBookSorter implements BookSorter {
  const NoOpBookSorter();

  @override
  List<Book> sort(List<Book> books) {
    // Does nothing, returns the original list reference.
    return books;
  }
}
