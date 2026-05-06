/// Interface abstrata para o serviço de ObjectBox
abstract class ObjectBoxServiceBase {
  dynamic get store;
}

/// Implementação mobile do ObjectBoxService
/// Usa ObjectBox nativo para persistência de dados
class ObjectBoxService implements ObjectBoxServiceBase {
  @override
  late final dynamic store;

  ObjectBoxService._create(this.store);

  static Future<ObjectBoxService> create() async {
    // TODO: Implementar inicialização do ObjectBox
    // final docsDir = await getApplicationDocumentsDirectory();
    // final storeDir = p.join(docsDir.path, "objectbox");

    // Placeholder até que objectbox.g.dart seja gerado com modelos
    dynamic store;

    return ObjectBoxService._create(store);
  }
}
