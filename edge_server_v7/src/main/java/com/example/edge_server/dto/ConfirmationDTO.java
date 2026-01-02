package com.example.edge_server.dto;

import lombok.*;

import java.time.LocalDateTime;


@Data
public class ConfirmationDTO {
    private Long id;
    private LocalDateTime confirmationTime;
    private boolean status;
    private Long clientId;
    private Long eventId;
}


