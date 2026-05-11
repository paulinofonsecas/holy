import 'package:flutter/widgets.dart';

// Conditional import: use native implementation on IO platforms, stub on web
import 'clarity_stub.dart'
    if (dart.library.io) 'clarity_mobile.dart' as impl;

Widget wrapWithClarity(Widget app) => impl.wrapWithClarity(app);
