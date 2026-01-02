import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repository/EventsRepository.dart';
import '../../models/EventModel.dart';
import 'event_events.dart';
import 'event_states.dart';

class PubEventBloc extends Bloc<PubEventEvent, PubEventState> {
  final EventsRepository eventsRepository;

  PubEventBloc(this.eventsRepository) : super(EventInitialState()) {
    on<LoadEventsEvent>((event, emit) async {
      emit(EventLoadingState());
      try {
        final events = await eventsRepository.getEvents();
        emit(EventListSuccessState(events));
      } catch (e) {
        emit(EventErrorState(e.toString()));
      }
    });

    on<CreateEventEvent>((event, emit) async {
      emit(EventLoadingState());
      try {
        print(
            "📤 Envoi de la requête : ${event.title}, Expiration: ${event.expirationTime}, Expiration: ${event.imageName}");

        final newEvent = await eventsRepository.createEvent(
          event.title,
          event.description,
          event.creatorId,
          event.locationId,
          event.categoryId,
          event.latitude,
          event.longitude,
          event.expirationTime,
          event.imageName,
        );

        print("✅ Événement créé avec succès ! ${newEvent.imageName}");
        emit(EventSuccessState(newEvent));
      } catch (e) {
        print("❌ Erreur lors de la création de l'événement : $e");
        emit(EventErrorState("Erreur : ${e.toString()}"));
      }
    });
  }
}
