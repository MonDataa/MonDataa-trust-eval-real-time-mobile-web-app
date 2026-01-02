package com.example.edge_server.dto;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class UserDTO {
    private Long id;
    private String username;
    private String email;
    private String userType; // "ADMIN" ou "CLIENT"
    private Float latitude;  // ✅ Ajout de la latitude
    private Float longitude; // ✅ Ajout de la longitude
}

