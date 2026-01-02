package com.example.edge_server.dto;

import lombok.*;
import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class EventFilterDTO {
    private LocalDateTime startDate;
    private LocalDateTime endDate;
    private String zone; // zone géographique (exemple : "Zone 1")
}


