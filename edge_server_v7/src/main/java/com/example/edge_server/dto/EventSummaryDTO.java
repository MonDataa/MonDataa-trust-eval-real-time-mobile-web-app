package com.example.edge_server.dto;

import lombok.Data;

import lombok.Data;
import java.util.List;

@Data
public class EventSummaryDTO {
    private Long id;
    private String title;
    private float confidenceScore; // Score de confiance actuel
    private List<Float> confidenceHistory; // ✅ Historique des scores de confiance
    private int participants; // Nombre de confirmations
    private String location; // Nom de la ville (Location)
    private List<String> participantUsernames; // ✅ Liste des participants
    private float latitude; // ✅ Latitude de l'événement
    private float longitude; // ✅ Longitude de l'événement
}

