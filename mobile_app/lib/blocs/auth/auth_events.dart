import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class AppStarted extends AuthEvent {}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  LoginEvent(this.email, this.password);

  @override
  List<Object> get props => [email, password];
}

class RegisterEvent extends AuthEvent {
  final String username;
  final String email;
  final String password;
  final int locationId;
  final double latitude;
  final double longitude;

  RegisterEvent(
    this.username,
    this.email,
    this.password, {
    required this.locationId,
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object> get props =>
      [username, email, password, locationId, latitude, longitude];
}

class LogoutEvent extends AuthEvent {}
