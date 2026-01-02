import 'ParticipationEvent.dart';

class ProfileModel {
  final List<ParticipationEvent> participationHistory;
  final double trustPositive;
  final double trustNegative;

  ProfileModel({
    required this.participationHistory,
    required this.trustPositive,
    required this.trustNegative,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      participationHistory: (json['participationHistory'] as List<dynamic>)
          .map((e) => ParticipationEvent.fromJson(e))
          .toList(),
      trustPositive: (json['trustScore']['positive'] as num).toDouble(),
      trustNegative: (json['trustScore']['negative'] as num).toDouble(),
    );
  }
}
