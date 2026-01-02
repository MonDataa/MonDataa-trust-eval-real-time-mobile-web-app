package com.example.edge_server.config;


import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.*;
import org.springframework.web.socket.handler.TextWebSocketHandler;

import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

@Component
public class MqttWebSocketHandler extends TextWebSocketHandler {

    private final Set<WebSocketSession> sessions = ConcurrentHashMap.newKeySet();

    @Override
    public void afterConnectionEstablished(WebSocketSession session) {
        sessions.add(session);
        System.out.println("✅ WebSocket connecté : " + session.getId());
    }

    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus status) {
        sessions.remove(session);
        System.out.println("🔌 WebSocket déconnecté : " + session.getId());
    }

    @Override
    protected void handleTextMessage(WebSocketSession session, TextMessage message) {
        System.out.println("📩 Message WebSocket reçu : " + message.getPayload());
    }

    @EventListener
    public void handleMqttMessageEvent(MqttMessageEvent event) {
        String message = event.getMessage();
        System.out.println("📡 Diffusion MQTT → WebSocket : " + message);

        if (sessions.isEmpty()) {
            System.out.println("⚠️ Aucun client WebSocket connecté pour recevoir le message.");
        } else {
            sendMessageToClients(message);
        }
    }

    private void sendMessageToClients(String message) {
        for (WebSocketSession session : sessions) {
            try {
                session.sendMessage(new TextMessage(message));
                System.out.println("📤 Message envoyé au client WebSocket : " + session.getId());
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
}
