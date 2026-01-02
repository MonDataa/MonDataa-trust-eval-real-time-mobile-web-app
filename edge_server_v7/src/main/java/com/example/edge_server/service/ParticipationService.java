package com.example.edge_server.service;

import com.example.edge_server.dto.EventParticipationDTO;
import com.example.edge_server.entites.Confirmation;
import com.example.edge_server.mappers.EventParticipationMapper;
import com.example.edge_server.repositories.ConfirmationRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ParticipationService {
    private final ConfirmationRepository confirmationRepository;
    private final EventParticipationMapper eventParticipationMapper;

    public List<EventParticipationDTO> getParticipationHistory(Long userId) {
        List<Confirmation> confirmations = confirmationRepository.findByClientId(userId);
        if (confirmations.isEmpty()) {
            return Collections.emptyList();
        }
        return confirmations.stream()
                .map(eventParticipationMapper::toDTO)
                .collect(Collectors.toList());
    }
}



