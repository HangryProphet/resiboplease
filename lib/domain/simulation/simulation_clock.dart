import 'dart:async';

import '../models/living_city_simulation.dart';

/// Schedules logical simulation pulses without owning or mutating city truth.
///
/// The city engine remains a deterministic daily simulation. This clock only
/// controls how many already-defined logical days the controller processes per
/// pulse. Rendering frame rate never participates in random selection.
class SimulationClock {
  SimulationClock({required this.onPulse});

  final void Function(int requestedDays) onPulse;

  Timer? _timer;
  SimulationSpeed? _speed;
  bool _paused = true;
  bool _disposed = false;

  void sync({required SimulationSpeed speed, required bool paused}) {
    if (_disposed) return;
    final changed = _speed != speed || _paused != paused;
    _speed = speed;
    _paused = paused;
    if (!changed) return;
    _reschedule();
  }

  void _reschedule() {
    _timer?.cancel();
    _timer = null;
    if (_paused || _speed == null || _disposed) return;
    final speed = _speed!;
    final interval = speed == SimulationSpeed.year
        ? const Duration(milliseconds: 220)
        : const Duration(seconds: 1);
    _timer = Timer.periodic(interval, (_) {
      if (_paused || _disposed) return;
      onPulse(speed.daysPerPulse);
    });
  }

  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _timer = null;
  }
}
