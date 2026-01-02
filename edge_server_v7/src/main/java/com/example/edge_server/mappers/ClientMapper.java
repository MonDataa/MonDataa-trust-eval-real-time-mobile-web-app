package com.example.edge_server.mappers;

import com.example.edge_server.dto.ClientDTO;
import com.example.edge_server.dto.EventSummaryDTO;
import com.example.edge_server.entites.Client;
import com.example.edge_server.entites.Confirmation;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.stream.Collectors;

@Component
public class ClientMapper {

    private final EventMapper eventMapper;

    public ClientMapper(EventMapper eventMapper) {
        this.eventMapper = eventMapper;
    }

    public ClientDTO toClientDTO(Client client) {
        if (client == null) {
            return null;
        }

        ClientDTO dto = new ClientDTO();
        dto.setId(client.getId());
        dto.setUsername(client.getUsername());
        dto.setEmail(client.getEmail());
        dto.setLocationName(client.getLocation() != null ? client.getLocation().getNom() : "Inconnue");

        // ✅ Position GPS
        if (client.getPosition() != null) {
            dto.setLatitude(client.getPosition().getLatitude());
            dto.setLongitude(client.getPosition().getLongitude());
        }

        // ✅ Score de confiance
        if (client.getConfiance() != null) {
            dto.setConfidenceScore(client.getConfiance().getScore());
            dto.setConfidenceHistory(client.getConfiance().getHistorique());
        }

        // ✅ Vérifier si le client a bien des confirmations
        System.out.println("🔍 Client " + client.getUsername() + " a " + client.getConfirmations().size() + " confirmations.");

        // ✅ Récupération des participations confirmées
        List<EventSummaryDTO> confirmedEvents = client.getConfirmations().stream()
                .filter(Confirmation::isStatus) // 🎯 Seuls les événements confirmés
                .map(confirmation -> {
                    System.out.println("✅ Participation trouvée pour client " + client.getUsername() + " : " + confirmation.getEvent().getTitle());
                    return eventMapper.toEventSummaryDTO(confirmation.getEvent());
                })
                .collect(Collectors.toList());

        dto.setParticipations(confirmedEvents); // ✅ Maintenant, la liste est remplie

        return dto;
    }


    public List<ClientDTO> toClientDTOList(List<Client> clients) {
        return clients.stream().map(this::toClientDTO).collect(Collectors.toList());
    }
}
