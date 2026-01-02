import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/blocs/statistics_user/statistics_user_events.dart';
import 'package:mobile_app/blocs/statistics_user/statistics_user_states.dart';
import 'package:mobile_app/repository/StatisticsRepository.dart';
import 'package:mobile_app/services/mqtt_service.dart';

class StatisticsUserBloc
    extends Bloc<StatisticsUserEvents, StatisticsUserStates> {
  final StatisticsRepository statisticsRepository;
  final int currentUserId;
  late MQTTService mqttService;

  StatisticsUserBloc(
      {required this.statisticsRepository, required this.currentUserId})
      : super(StatisticsInitial()) {
    mqttService = MQTTService(
      topic: "profile_updates",
      onMessageReceived: (message) {
        try {
          final Map<String, dynamic> data = jsonDecode(message);
          if (data["action"] == "profile_updated" &&
              data["userId"] == currentUserId) {
            print(
                "🔄 Mise à jour statistique reçue pour userId: $currentUserId, rechargement...");
            add(LoadStatistics(currentUserId));
          }
        } catch (e) {
          print("❌ Erreur de parsing MQTT dans StatisticsUserBloc: $e");
        }
      },
    );
    mqttService.connect();

    on<LoadStatistics>((event, emit) async {
      emit(StatisticsLoading());
      try {
        final statistics =
            await statisticsRepository.getUserStatistics(event.userId);
        print("✅ Statistiques chargées : $statistics");
        emit(StatisticsLoaded(statistics));
      } catch (e) {
        print("❌ Erreur lors du chargement des statistiques : $e");
        emit(StatisticsError("Erreur : $e"));
      }
    });
  }

  @override
  Future<void> close() {
    mqttService.disconnect();
    return super.close();
  }
}
