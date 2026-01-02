package com.example.edge_server.dto;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class UserSignupDTO {
    private String username;
    private String email;
    private String password;
    private String userType; // "ADMIN" ou "CLIENT"
    private Long locationId;
    private float latitude;  // 🔹 Nouvelle donnée
    private float longitude; // 🔹 Nouvelle donnée
}


