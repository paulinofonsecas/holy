import 'package:eu_sou/objectbox.g.dart'; // This will be generated
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ObjectBoxService {
  late final Store store;

  ObjectBoxService._create(this.store);

  static Future<ObjectBoxService> create() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final store = await openStore(directory: p.join(docsDir.path, "objectbox"));
    return ObjectBoxService._create(store);
  }
}
