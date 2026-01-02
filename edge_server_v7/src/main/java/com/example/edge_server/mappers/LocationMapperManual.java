package com.example.edge_server.mappers;


import com.example.edge_server.dto.CreateLocationDTO;
import com.example.edge_server.entites.Location;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class LocationMapperManual {

    public static Location toEntity(CreateLocationDTO dto) {
        if (dto == null) {
            return null;
        }
        Location location = new Location();
        location.setNom(dto.getNom());
        location.setZone(dto.getCoordonnees());
        return location;
    }
}