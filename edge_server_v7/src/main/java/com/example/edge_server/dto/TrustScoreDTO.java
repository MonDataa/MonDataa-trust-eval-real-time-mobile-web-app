package com.example.edge_server.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class TrustScoreDTO {
    private float positive;
    private float negative;
}
