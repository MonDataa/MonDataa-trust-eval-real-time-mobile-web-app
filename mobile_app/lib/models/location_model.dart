class LocationModel {
  final int id;
  final String nom;
  final String zone;
  final String longitude;
  final String latitude;

  LocationModel({
    required this.id,
    required this.nom,
    required this.zone,
    required this.longitude,
    required this.latitude,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'] ?? 0,
      nom: json['nom'] ?? '',
      zone: json['zone'] ?? '',
      longitude: json['longitude'] ?? '',
      latitude: json['latitude'] ?? '',
    );
  }
}
