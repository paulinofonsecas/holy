/// Implementação Web do ObjectBox Service
/// ObjectBox não é suportado em Web, esta é uma implementação stub
library;

/// Classe stub para Store em Web
class Store {
  // Store stub para web - ObjectBox não é suportado aqui
}

/// Interface abstrata para o serviço de ObjectBox
abstract class ObjectBoxServiceBase {
  dynamic get store;
}

/// Implementação web do ObjectBoxService
/// Lança UnsupportedError pois ObjectBox não é compatível com Web
class ObjectBoxService implements ObjectBoxServiceBase {
  @override
  final Store store = Store();

  static Future<ObjectBoxService> create() async {
    throw UnsupportedError(
        'ObjectBox is not supported on web. Use localStorage or Firebase instead.');
  }

  ObjectBoxService._create();
}
