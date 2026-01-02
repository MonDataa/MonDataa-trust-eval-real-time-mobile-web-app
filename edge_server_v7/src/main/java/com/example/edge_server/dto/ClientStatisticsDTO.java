package com.example.edge_server.dto;

import lombok.Data;

@Data
public class ClientStatisticsDTO {
    private long totalClients; // Nombre total de clients
    private double averageConfidence; // Score de confiance moyen
    private float maxConfidence; // Meilleur score de confiance
    private long totalParticipations; // ✅ Total des participations des clients
}

