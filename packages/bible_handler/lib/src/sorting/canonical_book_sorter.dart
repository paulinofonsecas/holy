import 'book_order.dart';
import '../models.dart';
import 'book_sorter.dart';

class CanonicalBookSorter implements BookSorter {
  const CanonicalBookSorter();

  @override
  List<Book> sort(List<Book> books) {
    final sortedBooks = List<Book>.from(books);
    sortedBooks.sort((a, b) {
      final indexA = canonicalBookOrder.indexOf(a.id);
      final indexB = canonicalBookOrder.indexOf(b.id);
      if (indexA == -1) return 1;
      if (indexB == -1) return -1;
      return indexA.compareTo(indexB);
    });
    return sortedBooks;
  }
}
