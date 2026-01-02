package com.example.edge_server.service;

import com.example.edge_server.dto.TrustScoreDTO;
import com.example.edge_server.entites.Client;
import com.example.edge_server.mappers.TrustScoreMapper;
import com.example.edge_server.repositories.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class TrustScoreService {
    private final UserRepository userRepository;
    private final TrustScoreMapper trustScoreMapper;

    public TrustScoreDTO getTrustScore(Long userId) {
        Client client = (Client) userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("Utilisateur ID " + userId + " non trouvé"));

        if (client.getConfiance() == null) {
            return new TrustScoreDTO(0, 100); // ✅ Retourne 0% confiance si `null`
        }

        return trustScoreMapper.toDTO(client);
    }
}
