package com.example.edge_server.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.socket.config.annotation.EnableWebSocket;
import org.springframework.web.socket.config.annotation.WebSocketConfigurer;
import org.springframework.web.socket.config.annotation.WebSocketHandlerRegistry;
import org.springframework.beans.factory.annotation.Autowired;

@Configuration
@EnableWebSocket
public class WebSocketConfig implements WebSocketConfigurer {

    private final MqttWebSocketHandler mqttWebSocketHandler;

    @Autowired // ✅ Injection du WebSocketHandler
    public WebSocketConfig(MqttWebSocketHandler mqttWebSocketHandler) {
        this.mqttWebSocketHandler = mqttWebSocketHandler;
    }

    @Override
    public void registerWebSocketHandlers(WebSocketHandlerRegistry registry) {
        registry.addHandler(mqttWebSocketHandler, "/mqtt")
                .setAllowedOrigins("*"); // ✅ Correction ici
    }
}

