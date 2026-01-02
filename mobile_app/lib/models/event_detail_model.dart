class EventDetail {
  final int id;
  final String title;
  final String description;
  final DateTime eventTime;
  final DateTime expirationTime;
  final String status;
  final bool expired;
  final int totalConfirmations;
  final int confirmedCount;
  final double confirmationRate;
  final double confidenceScore; // Ajout
  final String locationName;
  final String zone;
  final double latitude;
  final double longitude;
  final List<Confirmation> confirmations;

  EventDetail({
    required this.id,
    required this.title,
    required this.description,
    required this.eventTime,
    required this.expirationTime,
    required this.status,
    required this.expired,
    required this.totalConfirmations,
    required this.confirmedCount,
    required this.confirmationRate,
    required this.confidenceScore, // Ajout
    required this.locationName,
    required this.zone,
    required this.latitude,
    required this.longitude,
    required this.confirmations,
  });

  factory EventDetail.fromJson(Map<String, dynamic> json) {
    var confirmationsJson = json['confirmations'] as List<dynamic>? ?? [];
    List<Confirmation> confirmations = confirmationsJson
        .map((e) => Confirmation.fromJson(e as Map<String, dynamic>))
        .toList();

    return EventDetail(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      eventTime: DateTime.parse(json['eventTime']),
      expirationTime: DateTime.parse(json['expirationTime']),
      status: json['status'] ?? '',
      expired: json['expired'] ?? false,
      totalConfirmations: json['totalConfirmations'] ?? 0,
      confirmedCount: json['confirmedCount'] ?? 0,
      confirmationRate: (json['confirmationRate'] ?? 0.0).toDouble(),
      confidenceScore: (json['confidenceScore'] ?? 0.0).toDouble(), // Ajout
      locationName: json['locationName'] ?? '',
      zone: json['zone'] ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      confirmations: confirmations,
    );
  }
}

class Confirmation {
  final int id;
  final DateTime confirmationTime;
  final bool status;

  Confirmation({
    required this.id,
    required this.confirmationTime,
    required this.status,
  });

  factory Confirmation.fromJson(Map<String, dynamic> json) {
    return Confirmation(
      id: json['id'] ?? 0,
      confirmationTime: DateTime.parse(json['confirmationTime']),
      status: json['status'] ?? false,
    );
  }
}
