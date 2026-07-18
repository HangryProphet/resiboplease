import 'package:sembast/sembast.dart';

import 'run_database.dart';
import 'run_save_data.dart';

abstract interface class RunRepository {
  Future<GameSaveData?> load();
  Future<void> save(GameSaveData value);
  Future<void> close();
}

class MemoryRunRepository implements RunRepository {
  MemoryRunRepository({GameSaveData? initialValue}) : _value = initialValue;

  GameSaveData? _value;
  int saveCount = 0;

  @override
  Future<GameSaveData?> load() async => _value;

  @override
  Future<void> save(GameSaveData value) async {
    _value = GameSaveData.fromJson(value.toJson());
    saveCount++;
  }

  @override
  Future<void> close() async {}
}

class UnavailableRunRepository implements RunRepository {
  UnavailableRunRepository(this.error);

  final Object error;

  @override
  Future<GameSaveData?> load() => Future<GameSaveData?>.error(error);

  @override
  Future<void> save(GameSaveData value) => Future<void>.error(error);

  @override
  Future<void> close() async {}
}

class SembastRunRepository implements RunRepository {
  SembastRunRepository._(this._database);

  SembastRunRepository.forDatabase(this._database);

  static const _recordKey = 'root';
  static final StoreRef<String, Map<String, Object?>> _store =
      stringMapStoreFactory.store('game_state');

  final Database _database;

  static Future<SembastRunRepository> create() async =>
      SembastRunRepository._(await openRunDatabase());

  @override
  Future<GameSaveData?> load() async {
    final value = await _store.record(_recordKey).get(_database);
    return value == null ? null : GameSaveData.fromJson(value);
  }

  @override
  Future<void> save(GameSaveData value) =>
      _store.record(_recordKey).put(_database, value.toJson());

  @override
  Future<void> close() => _database.close();
}
