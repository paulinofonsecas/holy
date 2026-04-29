class ObjectBoxService {
  final Store store = Store();

  static Future<ObjectBoxService> create() async {
    throw UnsupportedError('ObjectBox not supported on web');
  }
}

class Store {}