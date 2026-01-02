package com.example.edge_server.mappers;

import com.example.edge_server.dto.EventParticipationDTO;
import com.example.edge_server.entites.Confirmation;
import org.springframework.stereotype.Component;

@Component
public class EventParticipationMapper {
    public EventParticipationDTO toDTO(Confirmation confirmation) {
        if (confirmation == null) {
            return null;
        }
        EventParticipationDTO dto = new EventParticipationDTO();
        dto.setEventId(confirmation.getEvent().getId());
        dto.setTitle(confirmation.getEvent().getTitle());
        dto.setParticipationDate(confirmation.getConfirmationTime());
        dto.setConfirmed(confirmation.isStatus());
        return dto;
    }
}
