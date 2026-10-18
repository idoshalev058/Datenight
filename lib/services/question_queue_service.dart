import 'dart:math';

/// Shuffles a fixed item list and hands items out one at a time without
/// repeats until the shuffled queue is exhausted, then reshuffles and
/// continues. Used by both Would You Rather and Icebreaker screens.
class QuestionQueueService<T> {
  final List<T> _all;
  final Random _random = Random();
  List<T> _queue = [];

  QuestionQueueService(List<T> items) : _all = List.of(items) {
    _reshuffle();
  }

  void _reshuffle() {
    _queue = List.of(_all)..shuffle(_random);
  }

  T next() {
    if (_queue.isEmpty) {
      _reshuffle();
    }
    return _queue.removeLast();
  }
}
