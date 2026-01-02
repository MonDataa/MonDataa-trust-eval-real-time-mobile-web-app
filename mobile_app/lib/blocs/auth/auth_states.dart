import 'package:equatable/equatable.dart';
import 'package:mobile_app/models/UserModel.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object> get props => [];
}

class AuthInitialState extends AuthState {}

class AuthLoadingState extends AuthState {}

class AuthSuccessState extends AuthState {
  final UserModel user;

  AuthSuccessState(this.user);

  @override
  List<Object> get props => [user];
}

class AuthFailureState extends AuthState {
  final String message;

  AuthFailureState(this.message);

  @override
  List<Object> get props => [message];
}
