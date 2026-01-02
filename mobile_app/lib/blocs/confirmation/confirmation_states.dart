import 'package:equatable/equatable.dart';
import 'package:mobile_app/models/confirmation_model.dart';

abstract class ConfirmationState extends Equatable {
  @override
  List<Object> get props => [];
}

class ConfirmationInitialState extends ConfirmationState {}

class ConfirmationLoadingState extends ConfirmationState {}

class ConfirmationSuccessState extends ConfirmationState {
  final ConfirmationModel confirmation;

  ConfirmationSuccessState(this.confirmation);

  @override
  List<Object> get props => [confirmation];
}

class ConfirmationErrorState extends ConfirmationState {
  final String message;

  ConfirmationErrorState(this.message);

  @override
  List<Object> get props => [message];
}
