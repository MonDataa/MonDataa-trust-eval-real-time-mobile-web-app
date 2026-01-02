class UserModel {
  final int id;
  final String username;
  final String email;
  final String userType;
  final double latitude;
  final double longitude;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.userType,
    required this.latitude,
    required this.longitude,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      userType: json['userType'] ?? 'CLIENT',
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
    );
  }
}
