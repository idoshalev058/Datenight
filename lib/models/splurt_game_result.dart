class SplurtGameResult {
  final DateTime playedAt;
  final int idoScore;
  final int shiraScore;

  const SplurtGameResult({
    required this.playedAt,
    required this.idoScore,
    required this.shiraScore,
  });

  Map<String, dynamic> toJson() => {
        'playedAt': playedAt.toIso8601String(),
        'idoScore': idoScore,
        'shiraScore': shiraScore,
      };

  factory SplurtGameResult.fromJson(Map<String, dynamic> json) {
    return SplurtGameResult(
      playedAt: DateTime.parse(json['playedAt'] as String),
      idoScore: json['idoScore'] as int,
      shiraScore: json['shiraScore'] as int,
    );
  }
}
