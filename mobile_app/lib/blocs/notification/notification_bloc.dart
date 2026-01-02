/*
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_app/blocs/auth/auth_bloc.dart';
import 'package:mobile_app/blocs/auth/auth_states.dart';
import 'package:mobile_app/blocs/notification/notification_states.dart';
import 'package:mobile_app/models/confirmation_model.dart';
import 'package:mobile_app/services/mqtt_service.dart';
import 'notification_events.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  List<Map<String, dynamic>> notifications = [];
  late MQTTService mqttService;
  int? currentUserId; // ✅ Stocker l'ID du client connecté

  NotificationBloc({required AuthBloc authBloc})
      : super(NotificationInitialState()) {
    // ✅ Vérifier si `currentUserId` est déjà disponible
    if (authBloc.state is AuthSuccessState) {
      currentUserId = (authBloc.state as AuthSuccessState).user.id;
      print("🔄 Initialisation : Client connecté ID: $currentUserId");
    }

    // ✅ Écoute les changements d'état d'AuthBloc
    authBloc.stream.listen((authState) {
      if (authState is AuthSuccessState) {
        currentUserId = authState.user.id;
        print("👤 Client connecté : ID $currentUserId");

        // ✅ Recharger les notifications après connexion
        add(LoadNotificationsEvent());
      }
    });

    // ✅ Initialisation MQTT
    mqttService = MQTTService(
      topic: "trustevalevents",
      onMessageReceived: (message) {
        print("🔔 Notification MQTT reçue : $message");
        add(AddNotificationEvent(message));
      },
    );
    mqttService.connect();

    on<LoadNotificationsEvent>((event, emit) {
      _emitFilteredNotifications(emit);
    });

    on<AddNotificationEvent>((event, emit) {
      final Map<String, dynamic> eventData =
          _parseNotification(event.notification);

      // ✅ Vérifier si l'utilisateur est connecté
      if (currentUserId == null) {
        print("⚠️ `currentUserId` est NULL, affichage temporaire.");
      } else if (eventData["creatorId"] == currentUserId) {
        print(
            "🚫 Notification ignorée (événement créé par le client connecté)");
        return;
      }

      notifications.add({
        "message": event.notification,
        "status": null,
        "creatorId": eventData["creatorId"],
        "creatorUsername": eventData["creatorUsername"],
        "creatorUserconfianceScore": eventData["creatorUserconfianceScore"],
        "eventId": eventData["eventId"],
        "title": eventData["title"],
        "confianceScore": eventData["confianceScore"],
        "confirmationId": null,
      });

      _emitFilteredNotifications(emit);
    });

    // ✅ Réintégration de la gestion de confirmation
    on<UpdateNotificationStatusEvent>((event, emit) async {
      if (event.index >= 0 && event.index < notifications.length) {
        final notification = notifications[event.index];

        // ✅ Appelle l'API pour confirmer l'événement
        final ConfirmationModel? confirmation =
            await _confirmEvent(notification);

        if (confirmation != null) {
          print(
              "✅ Confirmation API réussie pour eventId ${notification["eventId"]}");

          // ✅ Supprime la notification après confirmation
          notifications.removeAt(event.index);
          emit(NotificationLoadedState(List.from(notifications)));
        } else {
          print(
              "❌ Échec de confirmation via API pour eventId ${notification["eventId"]}");

          // ❌ Supprime la notification même en cas d'échec API
          notifications.removeAt(event.index);
          emit(NotificationLoadedState(List.from(notifications)));
        }
      }
    });

    on<RejectNotificationEvent>((event, emit) async {
      if (event.index >= 0 && event.index < notifications.length) {
        final notification = notifications[event.index];

        // ✅ Appelle l'API pour confirmer l'événement
        final ConfirmationModel? confirmation =
            await _rejectEvent(notification);

        if (confirmation != null) {
          print(
              "✅ Confirmation API réussie pour eventId ${notification["eventId"]}");

          // ✅ Supprime la notification après confirmation
          notifications.removeAt(event.index);
          emit(NotificationLoadedState(List.from(notifications)));
        } else {
          print(
              "❌ Échec de confirmation via API pour eventId ${notification["eventId"]}");

          // ❌ Supprime la notification même en cas d'échec API
          notifications.removeAt(event.index);
          emit(NotificationLoadedState(List.from(notifications)));
        }
      }
    });

    on<RemoveNotificationEvent>((event, emit) {
      if (event.index >= 0 && event.index < notifications.length) {
        notifications.removeAt(event.index);
        _emitFilteredNotifications(emit);
      }
    });

    on<ClearNotificationsEvent>((event, emit) {
      notifications.clear();
      emit(NotificationLoadedState([]));
    });
  }

  /// 🔥 **Mise à jour des notifications en temps réel**
  void _emitFilteredNotifications(Emitter<NotificationState> emit) {
    if (currentUserId == null) {
      print("⚠️ `currentUserId` est NULL, affichage temporaire.");
      emit(NotificationLoadedState(List.from(notifications)));
      return;
    }

    final filteredNotifications = notifications
        .where((notif) => notif["creatorId"] != currentUserId)
        .toList();
    emit(NotificationLoadedState(filteredNotifications));
  }

  Future<ConfirmationModel?> _confirmEvent(
      Map<String, dynamic> notification) async {
    print(
        "📡 Tentative d'appel API pour confirmer l'événement: ${notification["eventId"]}");

    final Map<String, dynamic> requestBody = {
      "clientId": currentUserId,
      "eventId": notification["eventId"]
    };

    try {
      final response = await http.post(
        Uri.parse("http://10.0.2.2:8085/api/confirmations/confirm"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      print("📡 API Confirmation: ${response.statusCode} - ${response.body}");

      if (response.statusCode == 200) {
        final confirmation =
            ConfirmationModel.fromJson(jsonDecode(response.body));
        print("✅ Confirmation réussie ! ID: ${confirmation.id}");
        return confirmation;
      } else {
        print(
            "❌ Erreur de confirmation: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print("❌ Erreur API: $e");
      return null;
    }
  }

  Future<ConfirmationModel?> _rejectEvent(
      Map<String, dynamic> notification) async {
    print(
        "📡 Tentative d'appel API pour confirmer l'événement: ${notification["eventId"]}");

    final Map<String, dynamic> requestBody = {
      "clientId": currentUserId,
      "eventId": notification["eventId"]
    };

    print("📡 Données envoyées à l'API: ${jsonEncode(requestBody)}");

    try {
      final response = await http.post(
        Uri.parse("http://10.0.2.2:8085/api/confirmations/reject"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      print(
          "📡 API Reject confirmation: ${response.statusCode} - ${response.body}");

      if (response.statusCode == 200) {
        final confirmation =
            ConfirmationModel.fromJson(jsonDecode(response.body));
        print("✅ Reject réussie ! ID: ${confirmation.id}");
        return confirmation;
      } else {
        print("❌ Erreur de Reject: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print("❌ Erreur API: $e");
      return null;
    }
  }

  Map<String, dynamic> _parseNotification(String message) {
    try {
      final Map<String, dynamic> data = jsonDecode(message);
      return {
        "eventId": (data["id"] as num?)?.toInt() ?? 0,
        "creatorId": (data["creatorId"] as num?)?.toInt() ?? 0,
        "creatorUsername": data["creatorUsername"] ?? "Inconnu",
        "creatorUserconfianceScore":
            (data["creatorUserconfianceScore"] as num?)?.toDouble() ?? 0.0,
        "title": data["title"] ?? "Événement inconnu",
        "confianceScore": (data["confianceScore"] as num?)?.toDouble() ?? 0.0,
      };
    } catch (e) {
      print("❌ Erreur lors de l'analyse de la notification: $e");
      return {
        "eventId": 0,
        "creatorId": 0,
        "creatorUsername": "Inconnu",
        "creatorUserconfianceScore": 0.0,
        "title": "Événement inconnu",
        "confianceScore": 0.0,
      };
    }
  }

  @override
  Future<void> close() {
    mqttService.disconnect();
    return super.close();
  }
}
*/
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_app/blocs/auth/auth_bloc.dart';
import 'package:mobile_app/blocs/auth/auth_states.dart';
import 'package:mobile_app/blocs/notification/notification_states.dart';
import 'package:mobile_app/models/confirmation_model.dart';
import 'package:mobile_app/services/mqtt_service.dart';
import 'package:mobile_app/repository/confirmation_repository.dart';
import 'notification_events.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final ConfirmationRepository confirmationRepository;
  List<Map<String, dynamic>> notifications = [];
  late MQTTService mqttService;
  int? currentUserId; // ✅ Stocker l'ID du client connecté

  NotificationBloc(
      {required AuthBloc authBloc, required this.confirmationRepository})
      : super(NotificationInitialState()) {
    if (authBloc.state is AuthSuccessState) {
      currentUserId = (authBloc.state as AuthSuccessState).user.id;
      print("🔄 Initialisation : Client connecté ID: $currentUserId");
    }

    authBloc.stream.listen((authState) {
      if (authState is AuthSuccessState) {
        currentUserId = authState.user.id;
        print("👤 Client connecté : ID $currentUserId");

        // ✅ Charger les notifications après connexion
        add(LoadNotificationsEvent());
      }
    });

    // ✅ Initialisation MQTT
    mqttService = MQTTService(
      topic: "trustevalevents",
      onMessageReceived: (message) {
        print("🔔 Notification MQTT reçue : $message");
        add(AddNotificationEvent(message));
      },
    );
    mqttService.connect();

    on<LoadNotificationsEvent>((event, emit) {
      _emitFilteredNotifications(emit);
    });

    on<AddNotificationEvent>((event, emit) {
      final Map<String, dynamic> eventData =
          _parseNotification(event.notification);

      if (currentUserId == null) {
        print("⚠️ `currentUserId` est NULL, affichage temporaire.");
      } else if (eventData["creatorId"] == currentUserId) {
        print(
            "🚫 Notification ignorée (événement créé par le client connecté)");
        return;
      }

      notifications.add({
        "message": event.notification,
        "status": null,
        "creatorId": eventData["creatorId"],
        "creatorUsername": eventData["creatorUsername"],
        "creatorUserconfianceScore": eventData["creatorUserconfianceScore"],
        "eventId": eventData["eventId"],
        "title": eventData["title"],
        "confianceScore": eventData["confianceScore"],
        "confirmationId": null,
      });

      _emitFilteredNotifications(emit);
    });

    // ✅ Mise à jour du statut en utilisant `ConfirmationRepository`
    on<UpdateNotificationStatusEvent>((event, emit) async {
      if (event.index >= 0 && event.index < notifications.length) {
        final notification = notifications[event.index];

        try {
          final confirmation = await confirmationRepository.confirmEvent(
            currentUserId!,
            notification["eventId"],
          );

          print(
              "✅ Confirmation API réussie pour eventId ${notification["eventId"]}");

          notifications.removeAt(event.index);
          emit(NotificationLoadedState(List.from(notifications)));
        } catch (e) {
          print("❌ Échec de confirmation via API : $e");
          notifications.removeAt(event.index);
          emit(NotificationLoadedState(List.from(notifications)));
        }
      }
    });

    // ✅ Rejet de notification en utilisant `ConfirmationRepository`
    on<RejectNotificationEvent>((event, emit) async {
      if (event.index >= 0 && event.index < notifications.length) {
        final notification = notifications[event.index];

        try {
          final confirmation = await confirmationRepository.rejectEvent(
            currentUserId!,
            notification["eventId"],
          );

          print("✅ Rejet API réussi pour eventId ${notification["eventId"]}");

          notifications.removeAt(event.index);
          emit(NotificationLoadedState(List.from(notifications)));
        } catch (e) {
          print("❌ Échec de rejet via API : $e");
          notifications.removeAt(event.index);
          emit(NotificationLoadedState(List.from(notifications)));
        }
      }
    });

    on<RemoveNotificationEvent>((event, emit) {
      if (event.index >= 0 && event.index < notifications.length) {
        notifications.removeAt(event.index);
        _emitFilteredNotifications(emit);
      }
    });

    on<ClearNotificationsEvent>((event, emit) {
      notifications.clear();
      emit(NotificationLoadedState([]));
    });
  }

  /// 🔥 **Mise à jour des notifications en temps réel**
  void _emitFilteredNotifications(Emitter<NotificationState> emit) {
    if (currentUserId == null) {
      print("⚠️ `currentUserId` est NULL, affichage temporaire.");
      emit(NotificationLoadedState(List.from(notifications)));
      return;
    }

    final filteredNotifications = notifications
        .where((notif) => notif["creatorId"] != currentUserId)
        .toList();
    emit(NotificationLoadedState(filteredNotifications));
  }

  /// 📌 **Parsage d'une notification en JSON**
  Map<String, dynamic> _parseNotification(String message) {
    try {
      final Map<String, dynamic> data = jsonDecode(message);
      return {
        "eventId": (data["id"] as num?)?.toInt() ?? 0,
        "creatorId": (data["creatorId"] as num?)?.toInt() ?? 0,
        "creatorUsername": data["creatorUsername"] ?? "Inconnu",
        "creatorUserconfianceScore":
            (data["creatorUserconfianceScore"] as num?)?.toDouble() ?? 0.0,
        "title": data["title"] ?? "Événement inconnu",
        "confianceScore": (data["confianceScore"] as num?)?.toDouble() ?? 0.0,
      };
    } catch (e) {
      print("❌ Erreur lors de l'analyse de la notification: $e");
      return {
        "eventId": 0,
        "creatorId": 0,
        "creatorUsername": "Inconnu",
        "creatorUserconfianceScore": 0.0,
        "title": "Événement inconnu",
        "confianceScore": 0.0,
      };
    }
  }

  @override
  Future<void> close() {
    mqttService.disconnect();
    return super.close();
  }
}
