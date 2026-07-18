import 'package:flutter_test/flutter_test.dart';
import 'package:resiboplease/data/persistence/run_repository.dart';
import 'package:resiboplease/data/persistence/run_save_data.dart';
import 'package:sembast/sembast_memory.dart';

void main() {
  test(
    'Sembast repository stores and reloads the versioned root document',
    () async {
      final database = await databaseFactoryMemory.openDatabase('runs.db');
      final repository = SembastRunRepository.forDatabase(database);
      final save = GameSaveData(
        activeSlotIndex: null,
        slots: List<RunSaveData?>.filled(5, null),
        updatedAt: DateTime.utc(2026, 7, 18),
      );

      await repository.save(save);
      final restored = await repository.load();

      expect(restored, isNotNull);
      expect(restored!.activeSlotIndex, isNull);
      expect(restored.slots, hasLength(5));
      expect(restored.slots, everyElement(isNull));
      expect(restored.updatedAt, DateTime.utc(2026, 7, 18));
      await repository.close();
    },
  );
}
