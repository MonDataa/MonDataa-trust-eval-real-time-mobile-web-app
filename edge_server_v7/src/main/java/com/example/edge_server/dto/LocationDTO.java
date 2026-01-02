package com.example.edge_server.dto;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class LocationDTO {
    private Long id;
    private String nom;
    private String zone;
    private String longitude;
    private String latitude;
}
