class EventPosition {
  final int id;
  final double latitude;
  final double longitude;
  final DateTime horodatage;

  EventPosition({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.horodatage,
  });

  factory EventPosition.fromJson(Map<String, dynamic> json) {
    return EventPosition(
      id: json['id'] ?? 0,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      horodatage: DateTime.parse(json['horodatage']),
    );
  }
}
