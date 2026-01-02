import 'package:equatable/equatable.dart';
import 'package:mobile_app/models/event_position_model.dart';

abstract class EventPositionsState extends Equatable {
  const EventPositionsState();

  @override
  List<Object> get props => [];
}

class EventPositionsInitial extends EventPositionsState {}

class EventPositionsLoading extends EventPositionsState {}

class EventPositionsLoaded extends EventPositionsState {
  final List<EventPosition> positions;
  const EventPositionsLoaded(this.positions);

  @override
  List<Object> get props => [positions];
}

class EventPositionsError extends EventPositionsState {
  final String message;
  const EventPositionsError(this.message);

  @override
  List<Object> get props => [message];
}
