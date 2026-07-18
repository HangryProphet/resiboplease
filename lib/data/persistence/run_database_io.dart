import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';

Future<Database> openRunDatabase() async {
  final directory = await getApplicationSupportDirectory();
  return databaseFactoryIo.openDatabase(
    '${directory.path}/resibo_please_runs.db',
  );
}
