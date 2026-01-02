package com.example.edge_server.mappers;

import com.example.edge_server.dto.ConfirmationDTO;
import com.example.edge_server.entites.Confirmation;
import org.springframework.stereotype.Component;

@Component
public class ConfirmationMapper {
    public ConfirmationDTO toConfirmationDTO(Confirmation confirmation) {
        if (confirmation == null) {
            return null;
        }
        ConfirmationDTO dto = new ConfirmationDTO();
        dto.setId(confirmation.getId());
        dto.setConfirmationTime(confirmation.getConfirmationTime());
        dto.setStatus(confirmation.isStatus());
        dto.setClientId(confirmation.getClient().getId()); // ✅ Ajouter clientId
        dto.setEventId(confirmation.getEvent().getId());   // ✅ Ajouter eventId
        return dto;
    }
}



