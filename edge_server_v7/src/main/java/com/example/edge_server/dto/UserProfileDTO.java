package com.example.edge_server.dto;

import lombok.*;
import java.util.List;

@Getter @Setter
@NoArgsConstructor @AllArgsConstructor
public class UserProfileDTO {
    private Long id;
    private String username;
    private String email;
    private String userType; // "ADMIN" ou "CLIENT"
    private float confianceScore; // Score de confiance basé sur l'historique
    private List<EventDTO> createdEvents; // Événements créés par l'utilisateur (si c'est un Client)
    private List<ConfirmationDTO> confirmations; // Confirmations effectuées
}
