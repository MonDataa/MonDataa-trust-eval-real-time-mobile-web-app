package com.example.edge_server.dto;


import lombok.Data;

import java.util.List;

@Data
public class UserStatisticsDTO {
    private int totalParticipations;
    private float averageTrustScore;
    private List<Float> trustScoreHistory;
}
