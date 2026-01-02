package com.example.edge_server.dto;

import lombok.*;
import java.time.LocalDateTime;
import java.util.List;

import lombok.Data;
import java.time.LocalDateTime;
import java.util.List;

@Data
public class EventDetailDTO {
    private Long id;
    private String title;
    private String description;
    private LocalDateTime eventTime;
    private LocalDateTime expirationTime;
    private String status;
    private boolean expired;
    private int totalConfirmations;
    private int confirmedCount;
    private double confirmationRate;
    private double confidenceScore;  // ✅ Ajout du score de confiance
    private String locationName;
    private String zone;
    private float latitude;
    private float longitude;
    private List<ConfirmationDTO> confirmations;
}


