export 'sqlite_parser_ffi.dart'
    if (dart.library.html) 'sqlite_parser_web.dart'
    if (dart.library.js_interop) 'sqlite_parser_web.dart';
