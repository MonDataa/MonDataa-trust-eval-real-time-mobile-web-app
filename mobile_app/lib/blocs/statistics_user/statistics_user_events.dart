import 'package:equatable/equatable.dart';

abstract class StatisticsUserEvents extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadStatistics extends StatisticsUserEvents {
  final int userId;
  LoadStatistics(this.userId);

  @override
  List<Object> get props => [userId];
}
