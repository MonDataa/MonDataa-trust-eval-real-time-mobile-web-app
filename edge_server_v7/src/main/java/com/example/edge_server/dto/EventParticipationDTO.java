package com.example.edge_server.dto;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class EventParticipationDTO {
    private Long eventId;
    private String title;
    private LocalDateTime participationDate;
    private boolean confirmed;
}
