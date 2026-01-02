import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadUserStatistics extends ProfileEvent {
  final int userId;
  LoadUserStatistics(this.userId);

  @override
  List<Object> get props => [userId];
}
