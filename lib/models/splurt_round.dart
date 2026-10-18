enum SplurtRuleType { startsWith, endsWith, containsLetter, exactLength, minLength }

class SplurtRule {
  final String label;
  final SplurtRuleType type;
  final String? letter;
  final int? length;

  const SplurtRule.startsWith(String letter)
      : label = 'Starts with $letter',
        type = SplurtRuleType.startsWith,
        letter = letter,
        length = null;

  const SplurtRule.endsWith(String letter)
      : label = 'Ends with $letter',
        type = SplurtRuleType.endsWith,
        letter = letter,
        length = null;

  const SplurtRule.containsLetter(String letter)
      : label = 'Contains the letter $letter',
        type = SplurtRuleType.containsLetter,
        letter = letter,
        length = null;

  const SplurtRule.exactLength(int n)
      : label = 'Exactly $n letters',
        type = SplurtRuleType.exactLength,
        letter = null,
        length = n;

  const SplurtRule.minLength(int n)
      : label = 'At least $n letters',
        type = SplurtRuleType.minLength,
        letter = null,
        length = n;

  bool matches(String answer) {
    final cleaned = answer.trim().toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
    if (cleaned.isEmpty) return false;
    switch (type) {
      case SplurtRuleType.startsWith:
        return cleaned.startsWith(letter!.toLowerCase());
      case SplurtRuleType.endsWith:
        return cleaned.endsWith(letter!.toLowerCase());
      case SplurtRuleType.containsLetter:
        return cleaned.contains(letter!.toLowerCase());
      case SplurtRuleType.exactLength:
        return cleaned.length == length;
      case SplurtRuleType.minLength:
        return cleaned.length >= length!;
    }
  }
}

/// A single category+rule pair. Category validation is intentionally mocked
/// (any non-empty answer passes it) — only the letter/length rule is real,
/// since there's no offline dictionary to check "is this actually an animal".
class SplurtRound {
  final String category;
  final SplurtRule rule;

  const SplurtRound({required this.category, required this.rule});

  bool isValidAnswer(String answer) {
    final trimmed = answer.trim();
    if (trimmed.isEmpty) return false;
    return rule.matches(trimmed);
  }
}
