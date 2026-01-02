package com.example.edge_server.dto;

import lombok.Data;

import java.util.List;

@Data
public class ClientDTO {
    private Long id;
    private String username;
    private String email;
    private String locationName;
    private double latitude;
    private double longitude;
    private float confidenceScore; // ✅ Score de confiance
    private List<Float> confidenceHistory; // 📊 Historique du score
    private List<EventSummaryDTO> participations; // 🏆 Liste des événements confirmés
}

