package com.example.edge_server.dto;

import lombok.Data;

import java.util.List;

@Data
public class EventResponseDTO {
    private List<EventSummaryDTO> events; // Liste des événements simplifiés
    private EventStatisticsDTO statistics; // Statistiques globales
}
