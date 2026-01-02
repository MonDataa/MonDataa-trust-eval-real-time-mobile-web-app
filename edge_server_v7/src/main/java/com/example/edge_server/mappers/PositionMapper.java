package com.example.edge_server.mappers;

import com.example.edge_server.dto.PositionDTO;
import com.example.edge_server.entites.Position;
import org.springframework.stereotype.Component;

@Component
public class PositionMapper {

    public PositionDTO toDTO(Position position) {
        if (position == null) {
            return null;
        }
        PositionDTO dto = new PositionDTO();
        dto.setId(position.getId());
        dto.setLatitude(position.getLatitude());
        dto.setLongitude(position.getLongitude());
        dto.setHorodatage(position.getHorodatage());
        return dto;
    }
}
