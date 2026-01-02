import 'package:equatable/equatable.dart';
import 'package:mobile_app/models/event_detail_model.dart';

abstract class EventDetailState extends Equatable {
  const EventDetailState();

  @override
  List<Object> get props => [];
}

class EventDetailInitial extends EventDetailState {}

class EventDetailLoading extends EventDetailState {}

class EventDetailLoaded extends EventDetailState {
  final EventDetail eventDetail;
  const EventDetailLoaded(this.eventDetail);

  @override
  List<Object> get props => [eventDetail, eventDetail.confidenceScore];
}

class EventDetailError extends EventDetailState {
  final String message;
  const EventDetailError(this.message);

  @override
  List<Object> get props => [message];
}
