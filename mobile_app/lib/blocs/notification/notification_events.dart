import 'package:equatable/equatable.dart';

abstract class NotificationEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadNotificationsEvent extends NotificationEvent {}

class AddNotificationEvent extends NotificationEvent {
  final String notification;

  AddNotificationEvent(this.notification);

  @override
  List<Object> get props => [notification];
}

class ClearNotificationsEvent extends NotificationEvent {}

class UpdateNotificationStatusEvent extends NotificationEvent {
  final int index;
  final bool status;

  UpdateNotificationStatusEvent(this.index, this.status);

  @override
  List<Object> get props => [index, status];
}

class RemoveNotificationEvent extends NotificationEvent {
  final int index;

  RemoveNotificationEvent(this.index);

  @override
  List<Object> get props => [index];
}

class RejectNotificationEvent extends NotificationEvent {
  final int index;
  final bool status;

  RejectNotificationEvent(this.index, this.status);

  @override
  List<Object> get props => [index, status];
}

class CancelConfirmationEvent extends NotificationEvent {
  final int index;

  CancelConfirmationEvent(this.index);

  @override
  List<Object> get props => [index];
}
