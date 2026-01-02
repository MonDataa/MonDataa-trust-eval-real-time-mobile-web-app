package com.example.edge_server.dto;

import com.example.edge_server.entites.EventStatus;
import lombok.*;
import java.time.LocalDateTime;

@Data
public class EventCreateDTO {
    private String title;
    private String description;
    private LocalDateTime eventTime;
    private LocalDateTime expirationTime;
    private EventStatus status; // ou éventuellement, vous pouvez le fixer en interne

    // Pour lier le créateur et la catégorie existants
    private Long creatorId;
    private Long categoryId;

    private String imageName;

    // DTO imbriqués pour Location et Position
    private Long locationId;
    private float latitude;  // 🔹 Nouvelle donnée
    private float longitude; // 🔹 Nouvelle donnée
}