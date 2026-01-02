import 'package:equatable/equatable.dart';

abstract class ConfirmationEvent extends Equatable {
  @override
  List<Object> get props => [];
}

// ✅ Confirmer un événement
class ConfirmEvent extends ConfirmationEvent {
  final int clientId;
  final int eventId;

  ConfirmEvent({required this.clientId, required this.eventId});

  @override
  List<Object> get props => [clientId, eventId];
}
