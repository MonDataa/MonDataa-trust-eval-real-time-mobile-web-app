package com.example.edge_server.dto;

import lombok.*;

@Getter @Setter
@NoArgsConstructor @AllArgsConstructor
public class UserLoginDTO {
    private String email;
    private String password;
}

