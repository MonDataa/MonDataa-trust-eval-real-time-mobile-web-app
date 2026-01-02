import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/blocs/event_positions/event_positions_state.dart';
import 'package:mobile_app/repository/event_positions_repository.dart';
import 'package:mobile_app/services/mqtt_service.dart';

import 'event_positions_event.dart';

class EventPositionsBloc
    extends Bloc<EventPositionsEvent, EventPositionsState> {
  final EventPositionsRepository repository;
  late MQTTService mqttService;

  EventPositionsBloc({required this.repository})
      : super(EventPositionsInitial()) {
    // Instanciation de MQTTService avec le topic "event_updated"
    mqttService = MQTTService(
      topic: "event_updated",
      onMessageReceived: (message) {
        try {
          // Ici, vous pouvez filtrer le message si nécessaire.
          print("📩 Message de mise à jour d'événements reçu: $message");
          add(LoadEventPositions());
        } catch (e) {
          print("❌ Erreur de parsing MQTT dans EventPositionsBloc: $e");
        }
      },
    );
    mqttService.connect();

    on<LoadEventPositions>((event, emit) async {
      emit(EventPositionsLoading());
      try {
        final positions = await repository.getEventPositions();
        print("✅ Positions chargées : ${positions.length}");
        emit(EventPositionsLoaded(positions));
      } catch (e) {
        print("❌ Erreur lors du chargement des positions : $e");
        emit(EventPositionsError(e.toString()));
      }
    });
  }

  @override
  Future<void> close() {
    mqttService.disconnect();
    return super.close();
  }
}
