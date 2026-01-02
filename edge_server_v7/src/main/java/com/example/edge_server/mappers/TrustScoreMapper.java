package com.example.edge_server.mappers;

import com.example.edge_server.dto.TrustScoreDTO;
import com.example.edge_server.entites.Client;
import org.springframework.stereotype.Component;

@Component
public class TrustScoreMapper {
    public TrustScoreDTO toDTO(Client client) {
        if (client == null || client.getConfiance() == null) {
            return new TrustScoreDTO(0, 0);
        }
        float total = client.getConfiance().getScore();
        return new TrustScoreDTO(total, 100 - total);
    }
}
