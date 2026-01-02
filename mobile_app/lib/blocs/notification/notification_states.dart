import 'package:equatable/equatable.dart';

abstract class NotificationState extends Equatable {
  @override
  List<Object> get props => [];
}

class NotificationInitialState extends NotificationState {}

class NotificationLoadedState extends NotificationState {
  final List<Map<String, dynamic>> notifications;
  final int? confirmationId;

  NotificationLoadedState(this.notifications, {this.confirmationId});

  @override
  List<Object> get props => [notifications, confirmationId ?? 0];
}

class NotificationErrorState extends NotificationState {
  final String message;

  NotificationErrorState(this.message);

  @override
  List<Object> get props => [message];
}
