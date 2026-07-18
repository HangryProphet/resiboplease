import 'package:sembast_web/sembast_web.dart';

Future<Database> openRunDatabase() =>
    databaseFactoryWeb.openDatabase('resibo_please_runs.db');
