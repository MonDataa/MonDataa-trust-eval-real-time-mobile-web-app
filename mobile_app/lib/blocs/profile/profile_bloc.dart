import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/blocs/profile/profile_events.dart';
import 'package:mobile_app/blocs/profile/profile_states.dart';
import 'package:mobile_app/repository/ProfileRepository.dart';
import 'package:mobile_app/services/mqtt_service.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository profileRepository;
  final int currentUserId;
  late MQTTService mqttService;

  ProfileBloc({required this.profileRepository, required this.currentUserId})
      : super(ProfileInitial()) {
    // Créer une instance de MQTTService avec le topic commun "profile_updates"
    mqttService = MQTTService(
      topic: "profile_updates",
      onMessageReceived: (message) {
        try {
          final Map<String, dynamic> data = jsonDecode(message);
          // Si le message indique une mise à jour pour l'utilisateur affiché
          if (data["action"] == "profile_updated" &&
              data["userId"] == currentUserId) {
            print(
                "🔄 Mise à jour reçue pour userId: $currentUserId, rechargement...");
            add(LoadUserStatistics(currentUserId));
          }
        } catch (e) {
          print("❌ Erreur de parsing MQTT dans ProfileBloc: $e");
        }
      },
    );
    mqttService.connect();

    on<LoadUserStatistics>((event, emit) async {
      emit(ProfileLoading());
      try {
        final profile = await profileRepository.getUserStatistics(event.userId);
        print("✅ Données du profil chargées : $profile");
        emit(ProfileLoaded(profile));
      } catch (e) {
        print("❌ Erreur lors du chargement du profil : $e");
        emit(ProfileError("Erreur : $e"));
      }
    });
  }

  @override
  Future<void> close() {
    mqttService.disconnect();
    return super.close();
  }
}
