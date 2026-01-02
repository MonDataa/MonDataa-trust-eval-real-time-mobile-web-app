package com.example.edge_server.mappers;


import com.example.edge_server.dto.CreatePositionDTO;
import com.example.edge_server.entites.Position;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class PositionMapperManual {

    public static Position toEntity(CreatePositionDTO dto) {
        if (dto == null) {
            return null;
        }
        Position position = new Position();
        position.setLatitude(dto.getLatitude());
        position.setLongitude(dto.getLongitude());
        position.setHorodatage(dto.getHorodatage());
        return position;
    }
}
