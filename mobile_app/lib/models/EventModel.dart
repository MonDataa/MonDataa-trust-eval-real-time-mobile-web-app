class EventModel {
  final int id;
  final String title;
  final String description;
  final DateTime eventTime;
  final DateTime expirationTime;
  final bool confirmed;
  final String locationName;
  final String zone; // 🔹 Ajout du champ zone
  final double latitude;
  final double longitude;
  final String imageName;

  EventModel(
      {required this.id,
      required this.title,
      required this.description,
      required this.eventTime,
      required this.expirationTime,
      required this.confirmed,
      required this.locationName,
      required this.zone, // 🔹 Ajout du champ zone
      required this.latitude,
      required this.longitude,
      required this.imageName});

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
        id: json['id'] ?? 0,
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        eventTime: json['eventTime'] != null
            ? DateTime.parse(json['eventTime'])
            : DateTime.now(),
        expirationTime: json['expirationTime'] != null
            ? DateTime.parse(json['expirationTime'])
            : DateTime.now(),
        confirmed: json['confirmed'] ?? false,
        locationName: json['locationName'] ?? '',
        zone: json['zone'] ?? '', // 🔹 Ajout du champ zone
        latitude: (json['latitude'] ?? 0).toDouble(),
        longitude: (json['longitude'] ?? 0).toDouble(),
        imageName: json['imageName'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'eventTime': eventTime.toIso8601String(),
      'expirationTime': expirationTime.toIso8601String(),
      'confirmed': confirmed,
      'locationName': locationName,
      'zone': zone, // 🔹 Ajout du champ zone
      'latitude': latitude,
      'longitude': longitude,
      'imageName': imageName
    };
  }
}
