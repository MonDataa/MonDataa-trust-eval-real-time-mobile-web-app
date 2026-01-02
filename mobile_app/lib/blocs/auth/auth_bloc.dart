import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/blocs/auth/auth_states.dart';
import 'package:mobile_app/models/UserModel.dart';
import 'package:mobile_app/repository/AuthRepository.dart';
import 'package:mobile_app/services/mqtt_service.dart';
import 'auth_events.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  late MQTTService mqttService; // ✅ Ajout de MQTT ici

  AuthBloc(this.authRepository) : super(AuthInitialState()) {
    mqttService = MQTTService(topic: "event_updated"); // ✅ Initialisation

    on<AppStarted>((event, emit) async {
      bool loggedIn = await authRepository.isLoggedIn();
      if (loggedIn) {
        emit(AuthSuccessState(UserModel(
            id: 1,
            username: "Utilisateur",
            email: "test@mail.com",
            userType: "CLIENT",
            latitude: 0.0,
            longitude: 0.0)));
        mqttService
            .connect(); // ✅ Connexion MQTT automatique au démarrage si déjà connecté
      } else {
        emit(AuthInitialState());
      }
    });

    on<LoginEvent>((event, emit) async {
      emit(AuthLoadingState());
      try {
        UserModel? user = await authRepository
            .loginUser(event.email, event.password)
            .timeout(const Duration(seconds: 5), onTimeout: () {
          throw Exception("Délai de connexion dépassé"); // ✅ Timeout
        });

        if (user != null) {
          emit(AuthSuccessState(user));
          mqttService.connect(); // ✅ Connexion MQTT automatique après login
        } else {
          emit(AuthFailureState("Identifiants incorrects"));
        }
      } catch (e) {
        emit(AuthFailureState("Erreur de connexion : $e"));
      }
    });

    on<RegisterEvent>((event, emit) async {
      emit(AuthLoadingState());
      try {
        UserModel? user = await authRepository
            .registerUser(
          event.username,
          event.email,
          event.password,
          event.locationId,
          event.latitude,
          event.longitude,
        )
            .timeout(const Duration(seconds: 5), onTimeout: () {
          throw Exception("Délai de connexion dépassé"); // ✅ Timeout
        });

        if (user != null) {
          emit(AuthSuccessState(user));
          mqttService
              .connect(); // ✅ Connexion MQTT automatique après inscription
        } else {
          emit(AuthFailureState("Erreur lors de l'inscription"));
        }
      } catch (e) {
        emit(AuthFailureState("Erreur d'inscription : $e"));
      }
    });

    on<LogoutEvent>((event, emit) async {
      if (state is AuthSuccessState) {
        UserModel user = (state as AuthSuccessState).user;
        bool success = await authRepository.logoutUser(user.id);
        if (success) {
          emit(AuthInitialState());
          mqttService.disconnect(); // ✅ Déconnexion MQTT immédiate après logout
        } else {
          emit(AuthFailureState("Erreur lors de la déconnexion"));
        }
      }
    });
  }
}
