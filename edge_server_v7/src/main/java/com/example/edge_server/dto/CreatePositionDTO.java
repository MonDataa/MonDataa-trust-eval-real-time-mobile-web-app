package com.example.edge_server.dto;

import java.time.LocalDateTime;
import lombok.Data;

@Data
public class CreatePositionDTO {
    private float latitude;
    private float longitude;
    private LocalDateTime horodatage;
}
