/// Importação condicional - resolve automaticamente qual implementação usar
/// - Web: objectbox_service_web.dart (stub com localStorage)
/// - Mobile/Desktop: objectbox_service_mobile.dart (ObjectBox nativo)
library;

export 'objectbox_service_mobile.dart'
    if (dart.library.html) 'objectbox_service_web.dart';
