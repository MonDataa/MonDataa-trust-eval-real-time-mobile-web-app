import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/blocs/confirmation/confirmation_events.dart';
import 'package:mobile_app/blocs/confirmation/confirmation_states.dart';
import 'package:mobile_app/repository/confirmation_repository.dart';

class ConfirmationBloc extends Bloc<ConfirmationEvent, ConfirmationState> {
  final ConfirmationRepository repository;

  ConfirmationBloc({required this.repository})
      : super(ConfirmationInitialState()) {
    on<ConfirmEvent>((event, emit) async {
      emit(ConfirmationLoadingState()); // 🔄 État de chargement

      try {
        print(
            "🔵 Tentative de confirmation pour clientId: ${event.clientId}, eventId: ${event.eventId}");

        final confirmation =
            await repository.confirmEvent(event.clientId, event.eventId);

        print(
            "✅ Confirmation réussie: ID ${confirmation.id}, Status: ${confirmation.status}");

        emit(ConfirmationSuccessState(confirmation));
      } catch (e) {
        print("❌ Erreur lors de la confirmation: $e");
        emit(ConfirmationErrorState(
            "Échec de la confirmation: ${e.toString()}"));
      }
    });
  }
}
