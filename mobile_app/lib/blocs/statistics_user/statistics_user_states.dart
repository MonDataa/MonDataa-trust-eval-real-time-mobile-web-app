import 'package:equatable/equatable.dart';
import 'package:mobile_app/models/StatisticsModel.dart';

abstract class StatisticsUserStates extends Equatable {
  @override
  List<Object> get props => [];
}

class StatisticsInitial extends StatisticsUserStates {}

class StatisticsLoading extends StatisticsUserStates {}

class StatisticsLoaded extends StatisticsUserStates {
  final StatisticsModel statistics;
  StatisticsLoaded(this.statistics);

  @override
  List<Object> get props => [statistics];
}

class StatisticsError extends StatisticsUserStates {
  final String message;
  StatisticsError(this.message);

  @override
  List<Object> get props => [message];
}
