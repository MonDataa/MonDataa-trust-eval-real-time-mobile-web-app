package com.example.edge_server.mappers;

import com.example.edge_server.dto.LocationDTO;
import com.example.edge_server.entites.Location;
import org.springframework.stereotype.Component;

@Component
public class LocationMapper {
    public LocationDTO toDTO(Location location) {
        if (location == null) {
            return null;
        }
        return new LocationDTO(
                location.getId(),
                location.getNom(),
                location.getZone(),
                location.getLatitude(),
                location.getLongitude()
        );
    }
}
