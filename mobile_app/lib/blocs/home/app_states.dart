import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:mobile_app/models/EventModel.dart';

@immutable
abstract class EventState extends Equatable {}

class EventLoadingState extends EventState {
  @override
  List<Object?> get props => [];
}

class EventLoadedState extends EventState {
  final List<EventModel> events;
  final int currentPage;
  final int totalPages;

  EventLoadedState(this.events,
      {required this.currentPage, required this.totalPages});

  @override
  List<Object?> get props => [events, currentPage, totalPages];
}

class EventErrorState extends EventState {
  final String errors;

  EventErrorState(this.errors);

  @override
  List<Object?> get props => [errors];
}
