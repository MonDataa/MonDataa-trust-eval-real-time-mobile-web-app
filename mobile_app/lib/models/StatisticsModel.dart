class StatisticsModel {
  final int totalParticipations;
  final double averageTrustScore;
  final List<double> trustScoreHistory;

  StatisticsModel({
    required this.totalParticipations,
    required this.averageTrustScore,
    required this.trustScoreHistory,
  });

  factory StatisticsModel.fromJson(Map<String, dynamic> json) {
    return StatisticsModel(
      totalParticipations: json['totalParticipations'] ?? 0,
      averageTrustScore: (json['averageTrustScore'] ?? 0.0).toDouble(),
      trustScoreHistory: (json['trustScoreHistory'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [],
    );
  }
}
