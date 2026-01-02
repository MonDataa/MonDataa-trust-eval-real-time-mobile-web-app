package com.example.edge_server.service;

import com.example.edge_server.dto.PositionDTO;
import com.example.edge_server.entites.Event;
import com.example.edge_server.entites.Position;
import com.example.edge_server.mappers.PositionMapper;
import com.example.edge_server.repositories.EventRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class PositionService {

    private final EventRepository eventRepository;
    private final PositionMapper positionMapper;

    /**
     * Récupère la position associée à un événement donné.
     * Comme chaque événement a une seule position, on renvoie une liste contenant cette position,
     * ou une liste vide si aucune position n’est associée.
     */
    @Transactional(readOnly = true)
    public List<PositionDTO> getPositionsByEventId(Long eventId) {
        Event event = eventRepository.findById(eventId)
                .orElseThrow(() -> new RuntimeException("Événement non trouvé avec l'id " + eventId));
        Position position = event.getPosition();
        return position != null ? List.of(positionMapper.toDTO(position)) : Collections.emptyList();
    }

    /**
     * Optionnel : Récupère la liste des positions de tous les événements.
     */
    @Transactional(readOnly = true)
    public List<PositionDTO> getAllEventPositions() {
        return eventRepository.findAll().stream()
                .map(Event::getPosition)
                .filter(pos -> pos != null)
                .map(positionMapper::toDTO)
                .collect(Collectors.toList());
    }
}
