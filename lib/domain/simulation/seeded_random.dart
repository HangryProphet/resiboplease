class SeededRandom {
  SeededRandom(int seed) : _state = seed % 2147483647 {
    if (_state <= 0) _state += 2147483646;
  }

  int _state;

  int nextInt(int max) {
    if (max <= 0) throw ArgumentError.value(max, 'max', 'Must be positive');
    _state = (_state * 16807) % 2147483647;
    return (_state - 1) % max;
  }

  double nextDouble() {
    _state = (_state * 16807) % 2147483647;
    return (_state - 1) / 2147483646;
  }

  double between(double min, double max) => min + nextDouble() * (max - min);
}
