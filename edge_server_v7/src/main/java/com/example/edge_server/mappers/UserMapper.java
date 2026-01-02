package com.example.edge_server.mappers;

import com.example.edge_server.dto.*;
import com.example.edge_server.entites.Administrateur;
import com.example.edge_server.entites.Client;
import com.example.edge_server.entites.Useer;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.stream.Collectors;

@Component
public class UserMapper {

    private final EventMapper eventMapper;
    private final ConfirmationMapper confirmationMapper;

    public UserMapper(EventMapper eventMapper, ConfirmationMapper confirmationMapper) {
        this.eventMapper = eventMapper;
        this.confirmationMapper = confirmationMapper;
    }

    public UserDTO toUserDTO(Useer user) {
        if (user == null) {
            return null;
        }

        UserDTO dto = new UserDTO();
        dto.setId(user.getId());
        dto.setUsername(user.getUsername());
        dto.setEmail(user.getEmail());

        if (user instanceof Administrateur) {
            dto.setUserType("ADMINEDGE");
        } else if (user instanceof Client) {
            dto.setUserType("CLIENT");
            Client client = (Client) user;

            if (client.getPosition() != null) {
                dto.setLatitude(client.getPosition().getLatitude());  // ✅ Ajouter latitude
                dto.setLongitude(client.getPosition().getLongitude()); // ✅ Ajouter longitude
            }
        } else {
            dto.setUserType("UNKNOWN");
        }

        return dto;
    }



    public UserProfileDTO toUserProfileDTO(Client client) {
        if (client == null) {
            return null;
        }

        UserProfileDTO dto = new UserProfileDTO();
        dto.setId(client.getId());
        dto.setUsername(client.getUsername());
        dto.setEmail(client.getEmail());
        dto.setUserType("CLIENT");
        dto.setConfianceScore(client.getConfiance() != null ? client.getConfiance().getScore() : 0.0f);

        // Convertir les événements créés
        List<EventDTO> events = client.getCreatedEvents().stream()
                .map(eventMapper::toEventDTO) // Use eventMapper instead of `toEventDTO(event)`
                .collect(Collectors.toList());
        dto.setCreatedEvents(events);

        // Convertir les confirmations
        List<ConfirmationDTO> confirmations = client.getConfirmations().stream()
                .map(confirmationMapper::toConfirmationDTO) // Use confirmationMapper instead of `toConfirmationDTO(confirmation)`
                .collect(Collectors.toList());
        dto.setConfirmations(confirmations);

        return dto;
    }

}
