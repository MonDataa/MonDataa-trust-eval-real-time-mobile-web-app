package com.example.edge_server.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class UserStatsDTO {
    private Long userId;
    private String username;
    private float confianceScore;
    private int totalEventsCreated;
    private int totalEventsConfirmed;
    private List<EventDTO> pastEvents; // Événements passés
    private List<EventDTO> upcomingEvents; // Événements futurs
}
