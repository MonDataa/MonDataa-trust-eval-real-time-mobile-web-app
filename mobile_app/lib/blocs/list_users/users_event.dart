import 'package:equatable/equatable.dart';

abstract class UsersEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadClientsEvent extends UsersEvent {
  final int page;
  LoadClientsEvent(this.page);

  @override
  List<Object> get props => [page];
}

class SearchClientsEvent extends UsersEvent {
  final String username;
  SearchClientsEvent(this.username);

  @override
  List<Object> get props => [username];
}
