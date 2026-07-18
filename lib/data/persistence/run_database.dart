import 'package:sembast/sembast.dart';

import 'run_database_io.dart'
    if (dart.library.js_interop) 'run_database_web.dart'
    as platform;

Future<Database> openRunDatabase() => platform.openRunDatabase();
