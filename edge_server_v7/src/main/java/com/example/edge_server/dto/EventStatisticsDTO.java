package com.example.edge_server.dto;

import lombok.Data;

@Data
public class EventStatisticsDTO {
    private double averageConfidence; // Moyenne des scores de confiance
    private long totalEvents; // Nombre total d'événements
    private float maxConfidence; // Score de confiance max
}
