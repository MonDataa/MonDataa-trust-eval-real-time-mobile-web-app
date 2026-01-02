package com.example.edge_server.service;

import com.example.edge_server.dto.LocationDTO;
import com.example.edge_server.mappers.LocationMapper;
import com.example.edge_server.repositories.LocationRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class LocationService {

    private final LocationRepository locationRepository;
    private final LocationMapper locationMapper;
        @Transactional(readOnly = true)
        public List<LocationDTO> getAllLocations() {
            return locationRepository.findAll().stream()
                    .map(locationMapper::toDTO)
                    .collect(Collectors.toList());
        }
}

