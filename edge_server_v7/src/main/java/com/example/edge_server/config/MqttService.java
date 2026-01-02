package com.example.edge_server.config;

import org.eclipse.paho.client.mqttv3.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Service;

import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

@Service
public class MqttService {

    //@Value("${mqtt.broker}")
    private static final String MQTT_BROKER = "tcp://mqtt-broker:1883";
    //@Value("${mqtt.username}")
    private static final String MQTT_USERNAME = "admin";
    //@Value("${mqtt.password}")
    private static final String MQTT_PASSWORD = "1234";
    private static final String MQTT_TOPIC_EVENTS = "trustevalevents";
    private static final String MQTT_TOPIC_PROFILS_UPDATES = "profile_updates";
    private static final String MQTT_TOPIC_EVENTS_UPDATES = "event_update";
    private static final String MQTT_TOPIC_USERS_UPDATES = "user_updates";

    private MqttClient mqttClient;
    private final ScheduledExecutorService scheduler = Executors.newScheduledThreadPool(1);
    private final ApplicationEventPublisher eventPublisher;

    private void scheduleReconnect(int attempt) {
        int delay = Math.min(30, (int) Math.pow(2, attempt)); // Exponentiel : 2s, 4s, 8s... max 30s

        scheduler.schedule(() -> {
            try {
                System.out.println("🔄 Tentative de reconnexion MQTT (Tentative " + attempt + ")...");
                connectToBroker();
            } catch (Exception e) {
                System.err.println("❌ Échec de reconnexion MQTT, nouvelle tentative dans " + delay + "s...");
                scheduleReconnect(attempt + 1);
            }
        }, delay, TimeUnit.SECONDS);
    }


    @Autowired
    public MqttService(ApplicationEventPublisher eventPublisher) {
        this.eventPublisher = eventPublisher;
        try {
            connectToBroker();
        } catch (Exception e) {
            System.err.println("❌ Échec de connexion initiale à MQTT !");
            scheduleReconnect(1);
        }
    }

    private void connectToBroker() throws MqttException {
        MqttConnectOptions options = new MqttConnectOptions();
        //options.setUserName(MQTT_USERNAME);
        //options.setPassword(MQTT_PASSWORD.toCharArray());
        options.setCleanSession(true);
        options.setAutomaticReconnect(true); // ✅ Active la reconnexion automatique

        mqttClient = new MqttClient(MQTT_BROKER, MqttClient.generateClientId());
        mqttClient.setCallback(new MqttCallbackExtended() {
            @Override
            public void connectComplete(boolean reconnect, String serverURI) {
                System.out.println("✅ Connecté à MQTT " + (reconnect ? "(Reconnexion)" : "(Initial)"));
                subscribeToTopics();
            }

            @Override
            public void connectionLost(Throwable cause) {
                System.err.println("🚨 Connexion MQTT perdue : " + cause.getMessage());
                scheduleReconnect(1);
            }

            @Override
            public void messageArrived(String topic, MqttMessage message) {
                handleMessage(topic, message);
            }

            @Override
            public void deliveryComplete(IMqttDeliveryToken token) {
                System.out.println("📨 Message MQTT livré !");
            }
        });

        mqttClient.connect(options);
    }

    private void scheduleReconnect() {
        scheduler.schedule(() -> {
            try {
                System.out.println("🔄 Tentative de reconnexion MQTT...");
                connectToBroker();
            } catch (Exception e) {
                System.err.println("❌ Échec de reconnexion MQTT, nouvelle tentative dans 5s...");
                scheduleReconnect();
            }
        }, 5, TimeUnit.SECONDS);
    }

    private void subscribeToTopics() {
        try {
            mqttClient.subscribe(MQTT_TOPIC_EVENTS, this::handleMessage);
            mqttClient.subscribe(MQTT_TOPIC_PROFILS_UPDATES, this::handleMessage);
            mqttClient.subscribe(MQTT_TOPIC_EVENTS_UPDATES, this::handleMessage);
            mqttClient.subscribe(MQTT_TOPIC_USERS_UPDATES, this::handleMessage);
            System.out.println("📡 Abonné aux topics MQTT !");
        } catch (MqttException e) {
            System.err.println("❌ Erreur lors de l'abonnement aux topics MQTT : " + e.getMessage());
        }
    }

    private void handleMessage(String topic, MqttMessage message) {
        String payload = new String(message.getPayload());
        System.out.println("📡 MQTT Message reçu sur " + topic + " : " + payload);
        eventPublisher.publishEvent(new MqttMessageEvent(this, payload));
    }

    public void publish(String topic, String message) {
        try {
            MqttMessage mqttMessage = new MqttMessage(message.getBytes());
            mqttMessage.setQos(1);
            mqttClient.publish(topic, mqttMessage);
            System.out.println("📤 Message envoyé sur MQTT (" + topic + ") : " + message);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
