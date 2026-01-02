import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/blocs/home/app_events.dart';
import 'package:mobile_app/blocs/home/app_states.dart';
import 'package:mobile_app/repository/EventsRepository.dart';
import 'package:mobile_app/services/mqtt_service.dart';
import '../../models/EventModel.dart';

class EventBloc extends Bloc<EventEvent, EventState> {
  final EventsRepository _eventRepository;
  late MQTTService mqttService;
  int currentPage = 0;
  int totalPages = 1;
  List<EventModel> events = [];
  List<EventModel> allEvents = [];

  EventBloc(this._eventRepository) : super(EventLoadingState()) {
    mqttService = MQTTService(
      topic: "event_updated",
      onMessageReceived: (message) {
        print("📩 Mise à jour des événements reçue: $message");
        add(LoadEventEvent(usePagination: false));
        add(LoadEventEvent(page: currentPage, size: 8, usePagination: true));
      },
    );

    // ✅ Vérifie si MQTT est déjà connecté avant de se reconnecter
    if (!mqttService.isConnected) {
      mqttService.connect();
    }

    on<LoadEventEvent>((event, emit) async {
      emit(EventLoadingState());
      try {
        if (event.usePagination) {
          final result = await _eventRepository.getEventsL(
              page: event.page, size: event.size);

          if (result.containsKey("events")) {
            events = result["events"];
            totalPages = result["totalPages"];
            currentPage = event.page;
          } else {
            throw Exception("Données API invalides !");
          }

          print("✅ Liste paginée : Page $currentPage / $totalPages");
          emit(EventLoadedState(events,
              currentPage: currentPage, totalPages: totalPages));
        } else {
          allEvents = await _eventRepository.getEvents();
          print("✅ Événements chargés pour la carte: ${allEvents.length}");
          emit(EventLoadedState([...events],
              currentPage: currentPage, totalPages: totalPages));
        }
      } catch (e) {
        print("❌ Erreur: $e");
        emit(EventErrorState(e.toString()));
      }
    });
  }

  @override
  Future<void> close() {
    mqttService.disconnect(); // ✅ Déconnexion MQTT propre
    return super.close();
  }
}
