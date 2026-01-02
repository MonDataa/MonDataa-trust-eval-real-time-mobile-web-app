package com.example.edge_server.dto;

import lombok.Data;

@Data
public class AuthenticationResponseDTO {
    private UserDTO user;
    private String token;
}
