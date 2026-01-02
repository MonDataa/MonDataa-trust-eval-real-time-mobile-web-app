package com.example.edge_server.mappers;

import com.example.edge_server.dto.*;
import com.example.edge_server.entites.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

@Component
@RequiredArgsConstructor
public class EventMapper {

    private final ConfirmationMapper confirmationMapper;
    private final CustomCategoryMapper customCategoryMapper;

    /**
     * Convertit un DTO de création en entité Event.
     */
    public Event toEntity(EventCreateDTO dto) {
        if (dto == null) {
            return null;
        }

        Event event = new Event();

        event.setTitle(dto.getTitle());
        event.setDescription(dto.getDescription());
        event.setEventTime(dto.getEventTime());
        event.setExpirationTime(dto.getExpirationTime());
        event.setStatus(dto.getStatus());
        event.setImageName(dto.getImageName());

        // 🔹 Création manuelle de la position
        Position position = new Position();
        position.setLatitude(dto.getLatitude());
        position.setLongitude(dto.getLongitude());
        position.setHorodatage(LocalDateTime.now()); // Timestamp de la position

        event.setPosition(position);


        // 🔹 La relation avec Location est définie plus tard dans le service.
        //event.setLocation(null);

        // 🔹 Création et initialisation de ConfianceEvent avec un score par défaut
        ConfianceEvent confianceEvent = new ConfianceEvent();
        confianceEvent.setScore(50.0f); // 🔥 Valeur initiale par défaut
        confianceEvent.setHistorique(new ArrayList<>(List.of(50.0f))); // 🔥 Ajout à l'historique

        event.setConfiance_event(confianceEvent);

        return event;
    }


    /**
     * Convertit une entité Event en DTO détaillé.
     */

    private double calculateConfidenceScore(Event event) {
        List<Confirmation> confirmations = event.getConfirmations();

        if (confirmations == null || confirmations.isEmpty()) {
            return 0.0;  // Aucun score si pas de confirmations
        }

        double totalScore = 0.0;
        double totalWeight = 0.0;

        for (Confirmation confirmation : confirmations) {
            Client client = confirmation.getClient();  // Qui a confirmé ?
            double clientTrustScore = (client.getConfiance() != null) ? client.getConfiance().getScore() : 50.0; // Score par défaut à 50
            double confirmationWeight = confirmation.isStatus() ? 1.0 : 0.5;  // ✅ Si "validé" → 100% de poids, sinon 50%

            totalScore += clientTrustScore * confirmationWeight;
            totalWeight += confirmationWeight;
        }

        return (totalWeight > 0) ? totalScore / totalWeight : 0.0;  // Moyenne pondérée
    }

    public EventDetailDTO toEventDetailDTO(Event event) {
        if (event == null) {
            return null;
        }

        EventDetailDTO dto = new EventDetailDTO();
        dto.setId(event.getId());
        dto.setTitle(event.getTitle());
        dto.setDescription(event.getDescription());
        dto.setEventTime(event.getEventTime());
        dto.setExpirationTime(event.getExpirationTime());
        dto.setStatus(event.getStatus().toString());
        dto.setExpired(event.getExpirationTime().isBefore(LocalDateTime.now()));

        int total = event.getConfirmations() != null ? event.getConfirmations().size() : 0;
        dto.setTotalConfirmations(total);
        int confirmedCount = (int) event.getConfirmations().stream()
                .filter(Confirmation::isStatus)
                .count();
        dto.setConfirmedCount(confirmedCount);
        dto.setConfirmationRate(total > 0 ? (confirmedCount * 100.0) / total : 0.0);

        // ✅ Calcul du score de confiance
        double confidenceScore = calculateConfidenceScore(event);
        dto.setConfidenceScore(confidenceScore);

        if (event.getLocation() != null) {
            dto.setLocationName(event.getLocation().getNom());
            dto.setZone(event.getLocation().getZone());
        } else {
            dto.setLocationName("Inconnue");
            dto.setZone("Inconnue");
        }

        if (event.getPosition() != null) {
            dto.setLatitude(event.getPosition().getLatitude());
            dto.setLongitude(event.getPosition().getLongitude());
        }

        List<ConfirmationDTO> confirmationDTOs = event.getConfirmations().stream()
                .map(confirmationMapper::toConfirmationDTO)
                .collect(Collectors.toList());
        dto.setConfirmations(confirmationDTOs);

        return dto;
    }


    /**
     * Convertit une entité Event en DTO allégé.
     */
    public EventDTO toEventDTO(Event event) {
        if (event == null) {
            return null;
        }

        EventDTO dto = new EventDTO();
        dto.setId(event.getId());
        dto.setTitle(event.getTitle());
        dto.setDescription(event.getDescription());
        dto.setEventTime(event.getEventTime());
        dto.setExpirationTime(event.getExpirationTime());
        dto.setImageName(event.getImageName());

        // ✅ Considérer l'événement comme confirmé s'il y a au moins une confirmation avec status true
        boolean confirmed = event.getConfirmations() != null &&
                event.getConfirmations().stream().anyMatch(Confirmation::isStatus);
        dto.setConfirmed(confirmed);

        // ✅ Récupération du nom de l'emplacement
        dto.setLocationName(event.getLocation() != null ? event.getLocation().getNom() : "Inconnu");

        // ✅ Ajout de la zone depuis `Location`
        dto.setZone(event.getLocation() != null ? event.getLocation().getZone() : "Inconnu");

        // ✅ Récupération de la latitude et longitude depuis `Position`
        dto.setLatitude(event.getPosition() != null ? event.getPosition().getLatitude() : 0.0f);
        dto.setLongitude(event.getPosition() != null ? event.getPosition().getLongitude() : 0.0f);

        return dto;
    }


    public EventFilterDTO toEventDTOFilter(Event event) {
        if (event == null) {
            return null;
        }
        EventFilterDTO dto = new EventFilterDTO();
        dto.setStartDate(event.getEventTime());
        dto.setEndDate(event.getExpirationTime());
        // Récupérer la zone (si disponible)
        dto.setZone(event.getLocation() != null ? event.getLocation().getZone() : "Inconnue");
        return dto;
    }


    public EventSummaryDTO toEventSummaryDTO(Event event) {
        if (event == null) {
            return null;
        }

        EventSummaryDTO dto = new EventSummaryDTO();
        dto.setId(event.getId());
        dto.setTitle(event.getTitle());

        // ✅ Récupération du score de confiance actuel
        dto.setConfidenceScore(event.getConfiance_event() != null ? event.getConfiance_event().getScore() : 0.0f);

        // ✅ Récupération de l'historique de confiance
        dto.setConfidenceHistory(event.getConfiance_event() != null ? event.getConfiance_event().getHistorique() : List.of());

        // ✅ Nombre total de participants
        dto.setParticipants(event.getConfirmations() != null ? event.getConfirmations().size() : 0);

        // ✅ Nom de la localisation
        dto.setLocation(event.getLocation() != null ? event.getLocation().getNom() : "Inconnu");

        // ✅ Récupération des noms des participants
        List<String> participantUsernames = event.getConfirmations().stream()
                .map(confirmation -> confirmation.getClient().getUsername())
                .collect(Collectors.toList());
        dto.setParticipantUsernames(participantUsernames);

        // ✅ Récupération des coordonnées GPS
        dto.setLatitude(event.getPosition() != null ? event.getPosition().getLatitude() : 0.0f);
        dto.setLongitude(event.getPosition() != null ? event.getPosition().getLongitude() : 0.0f);

        return dto;
    }

    public List<EventSummaryDTO> toEventSummaryDTOList(List<Event> events) {
        return events.stream().map(this::toEventSummaryDTO).collect(Collectors.toList());
    }


}
