/// Importação condicional - resolve automaticamente qual implementação usar
/// - Web: hive_vector_store_web.dart (stub com localStorage/IndexedDB)
/// - Mobile/Desktop: hive_vector_store_mobile.dart (Hive nativo)
library;

export 'hive_vector_store_mobile.dart'
    if (dart.library.html) 'hive_vector_store_web.dart';
