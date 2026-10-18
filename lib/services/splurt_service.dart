import 'dart:math';

import '../data/splurt_data.dart';
import '../models/splurt_round.dart';

class SplurtDeckService {
  final Random _random = Random();

  List<SplurtRound> buildDeck({int size = 150}) {
    final deck = <SplurtRound>[];
    final seenCombos = <String>{};

    while (deck.length < size) {
      final category = splurtCategories[_random.nextInt(splurtCategories.length)];
      final rule = splurtRules[_random.nextInt(splurtRules.length)];
      final comboKey = '$category|${rule.label}';
      if (seenCombos.contains(comboKey)) continue;
      seenCombos.add(comboKey);
      deck.add(SplurtRound(category: category, rule: rule));
    }

    return deck;
  }
}
