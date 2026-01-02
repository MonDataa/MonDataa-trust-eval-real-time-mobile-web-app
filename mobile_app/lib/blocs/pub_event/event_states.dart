import 'package:equatable/equatable.dart';
import '../../models/EventModel.dart';

abstract class PubEventState extends Equatable {
  @override
  List<Object> get props => [];
}

class EventInitialState extends PubEventState {}

class EventLoadingState extends PubEventState {}

class EventSuccessState extends PubEventState {
  final EventModel event;
  EventSuccessState(this.event);

  @override
  List<Object> get props => [event];
}

// ✅ Correction : Ajout de EventListSuccessState pour éviter l'erreur
class EventListSuccessState extends PubEventState {
  final List<EventModel> events;
  EventListSuccessState(this.events);

  @override
  List<Object> get props => [events];
}

class EventErrorState extends PubEventState {
  final String message;
  EventErrorState(this.message);

  @override
  List<Object> get props => [message];
}
