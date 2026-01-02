import 'package:equatable/equatable.dart';

abstract class EventDetailEvent extends Equatable {
  const EventDetailEvent();

  @override
  List<Object> get props => [];
}

class LoadEventDetail extends EventDetailEvent {
  final int eventId;
  const LoadEventDetail(this.eventId);

  @override
  List<Object> get props => [eventId];
}
