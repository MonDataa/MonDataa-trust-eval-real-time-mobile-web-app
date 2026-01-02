import 'dart:convert';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

import '../repository/AppConfig.dart';

class MQTTService {
  final String broker = "${AppConfig.baseIp}"; // Adresse du serveur
  final int port = 1883;
  //final String username = "admin";
  //final String password = "1234";
  final String clientId =
      "flutter_client_${DateTime.now().millisecondsSinceEpoch}";
  final String topic; // Topic configurable
  bool isConnected = false;

  late MqttServerClient client;
  Function(String)? onMessageReceived;

  MQTTService({required this.topic, this.onMessageReceived});

  Future<void> connect() async {
    client = MqttServerClient(broker, clientId);
    client.port = port;
    client.keepAlivePeriod = 20;
    client.autoReconnect = true;

    client.onConnected = onConnected;
    client.onDisconnected = onDisconnected;
    client.onSubscribed = onSubscribed;
    client.logging(on: false);

    final connMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        //.authenticateAs(username, password)
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    client.connectionMessage = connMessage;

    try {
      await client.connect();
      print("✅ Connecté à Mosquitto !");
      subscribeToTopic();
    } catch (e) {
      print("❌ Erreur de connexion MQTT: $e");
    }
  }

  void subscribeToTopic() {
    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      client.subscribe(topic, MqttQos.exactlyOnce);
      print("🟢 Abonné au topic: $topic");

      client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
        final MqttPublishMessage recMessage =
            messages[0].payload as MqttPublishMessage;
        final String message = MqttPublishPayload.bytesToStringAsString(
            recMessage.payload.message);

        print("📩 Message reçu sur $topic: $message");

        if (onMessageReceived != null) {
          onMessageReceived!(message);
        }
      });
    } else {
      print("❌ Échec de l'abonnement, connexion non établie.");
    }
  }

  void disconnect() {
    client.disconnect();
    print("🔴 Déconnecté de MQTT");
  }

  void onConnected() => print("✅ Connecté à Mosquitto !");
  void onDisconnected() => print("🔴 Déconnecté du broker !");
  void onSubscribed(String topic) => print("🟢 Abonné à : $topic");
}
