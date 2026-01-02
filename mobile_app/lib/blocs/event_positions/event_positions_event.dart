import 'package:equatable/equatable.dart';

abstract class EventPositionsEvent extends Equatable {
  const EventPositionsEvent();

  @override
  List<Object> get props => [];
}

class LoadEventPositions extends EventPositionsEvent {}
