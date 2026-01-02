import 'package:equatable/equatable.dart';
import 'package:mobile_app/models/UserModel.dart';

abstract class UsersState extends Equatable {
  @override
  List<Object> get props => [];
}

class ClientsInitial extends UsersState {}

class ClientsLoading extends UsersState {}

class ClientsLoaded extends UsersState {
  final List<UserModel> clients;
  final int currentPage;
  final int totalPages;

  ClientsLoaded(this.clients, this.currentPage, this.totalPages);

  @override
  List<Object> get props => [clients, currentPage, totalPages];
}

class ClientsError extends UsersState {
  final String message;
  ClientsError(this.message);

  @override
  List<Object> get props => [message];
}
