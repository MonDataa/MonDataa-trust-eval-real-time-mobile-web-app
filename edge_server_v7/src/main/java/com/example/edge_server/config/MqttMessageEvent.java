package com.example.edge_server.config;

import org.springframework.context.ApplicationEvent;

public class MqttMessageEvent extends ApplicationEvent {
    private final String message;

    public MqttMessageEvent(Object source, String message) {
        super(source);
        this.message = message;
    }

    public String getMessage() {
        return message;
    }
}
