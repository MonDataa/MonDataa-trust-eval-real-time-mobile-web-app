package com.example.edge_server.dto;

import lombok.*;
import java.time.LocalDateTime;

@Data
public class EventDTO {
    private Long id;
    private String title;
    private String description;
    private LocalDateTime eventTime;
    private LocalDateTime expirationTime;
    private boolean confirmed;
    private String locationName;
    private String zone;        // ✅ Ajout de la zone géographique
    private float latitude;
    private float longitude;
    private String imageName;
}



