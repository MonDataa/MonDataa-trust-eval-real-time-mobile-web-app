package com.example.edge_server.service;

import com.example.edge_server.config.MqttService;
import com.example.edge_server.dto.*;
import com.example.edge_server.entites.*;
import com.example.edge_server.mappers.EventMapper;
import com.example.edge_server.repositories.*;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.gson.Gson;
import com.google.gson.JsonObject;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.OptionalDouble;
import java.util.stream.Collectors;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;

@Service
@RequiredArgsConstructor
public class EventService {

    private final EventRepository eventRepository;
    private final EventMapper eventMapper;
    private final UserRepository userRepository;
    private final CategoryRepository categoryRepository;
    private final ClientRepository clientRepository;
    private final LocationRepository locationRepository;
    private final PositionRepository positionRepository;
    private final ConfianceEventRepository confianceEventRepository;
    private final  ConfirmationRepository confirmationRepository;
    private final MqttService mqttService;
    private final ObjectMapper objectMapper = new ObjectMapper();
    private static final String SHARED_FOLDER_PATH = "/app/public-data"; // Chemin dans Docker
    private static final String FILE_NAME = "events.json"; // Fichier JSON

    /**
     * Filtre et retourne la liste des événements correspondant aux critères fournis dans EventFilterDTO.
     */
    @Transactional
    public List<EventFilterDTO> getEventsFiltered(EventFilterDTO filterDTO) {
        List<Event> events = eventRepository.findByEventTimeBetweenAndLocation_Zone(
                filterDTO.getStartDate(),
                filterDTO.getEndDate(),
                filterDTO.getZone()
        );
        return events.stream()
                .map(eventMapper::toEventDTOFilter)
                .collect(Collectors.toList());
    }

    /**
     * Retourne les détails d'un événement, y compris ses statistiques.
     */
    public EventDetailDTO getEventDetails(Long eventId) {
        Event event = eventRepository.findById(eventId)
                .orElseThrow(() -> new RuntimeException("Événement non trouvé avec l'id " + eventId));

        return eventMapper.toEventDetailDTO(event);
    }

    public List<EventDTO> getAllEvents() {
        return eventRepository.findByExpirationTimeAfterAndStatus(LocalDateTime.now(), EventStatus.PENDING) // ✅ Filtrer les événements non expirés et en attente
                .stream()
                .map(eventMapper::toEventDTO)
                .collect(Collectors.toList());
    }

    public Page<EventDTO> getAllEventsPaginated(int page, int size) {
        PageRequest pageRequest = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "expirationTime"));

        return eventRepository.findByExpirationTimeAfterAndStatus(LocalDateTime.now(), EventStatus.PENDING, pageRequest) // ✅ Seulement les événements PENDING
                .map(eventMapper::toEventDTO);
    }

    // ✅ Récupérer les événements filtrés par titre + pagination
    public Page<EventDTO> getEventsByTitle(String title, int page, int size) {
        PageRequest pageRequest = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "expirationTime"));
        return eventRepository.findByTitleContainingIgnoreCase(title, pageRequest).map(eventMapper::toEventDTO);
    }



    @Transactional
    public EventSummaryDTO registerEvent(EventCreateDTO eventCreateDTO) {
        // 1️⃣ Mapper le DTO en entité
        Event event = eventMapper.toEntity(eventCreateDTO);

        // 2️⃣ Associer le créateur de l'événement
        Client creator = clientRepository.findById(eventCreateDTO.getCreatorId())
                .orElseThrow(() -> new RuntimeException("Client non trouvé avec l'ID : " + eventCreateDTO.getCreatorId()));
        event.setCreator(creator);

        // 3️⃣ Associer la catégorie
        Category category = categoryRepository.findById(eventCreateDTO.getCategoryId())
                .orElseThrow(() -> new RuntimeException("Catégorie non trouvée avec l'ID : " + eventCreateDTO.getCategoryId()));
        event.setCategory(category);

        // Si l'image de l'événement est nulle, attribuer celle de la catégorie
        if (event.getImageName() == null || event.getImageName().isEmpty()) {
            event.setImageName(category.getImageName());
        }

        // 4️⃣ Associer la localisation
        Location location = locationRepository.findById(eventCreateDTO.getLocationId())
                .orElseThrow(() -> new RuntimeException("Localisation non trouvée avec l'ID : " + eventCreateDTO.getLocationId()));
        event.setLocation(location);

        // 5️⃣ Statut par défaut : PENDING
        event.setStatus(EventStatus.PENDING);

        // 6️⃣ Sauvegarde de la position si disponible
        if (event.getPosition() != null) {
            positionRepository.save(event.getPosition());
        }

        // 7️⃣ Création et sauvegarde de ConfianceEvent
        ConfianceEvent confianceEvent = new ConfianceEvent();
        confianceEvent.setScore(50.0f); // Score initial
        confianceEvent.setHistorique(new ArrayList<>(List.of(50.0f))); // Historique initialisé
        confianceEventRepository.save(confianceEvent);
        event.setConfiance_event(confianceEvent);

        // 8️⃣ Sauvegarde de l'événement
        Event savedEvent = eventRepository.save(event);

        // 🔄 9️⃣ Mettre à jour le fichier JSON
        writeToFile();

        // 📡 10️⃣ Publier sur MQTT/WebSocket
        publishEventToMqtt(savedEvent, creator, category);

        // 11️⃣ Retourner le résumé de l'événement
        return eventMapper.toEventSummaryDTO(savedEvent);
    }

    /**
     * 🔥 Publier un événement sur MQTT
     */
    private void publishEventToMqtt(Event event, Client creator, Category category) {
        Gson gson = new Gson();
        JsonObject eventJson = new JsonObject();

        eventJson.addProperty("id", event.getId());
        eventJson.addProperty("creatorId", creator.getId());
        eventJson.addProperty("creatorUsername", creator.getUsername());
        eventJson.addProperty("creatorUserconfianceScore", creator.getConfiance().getScore());
        eventJson.addProperty("title", event.getTitle());
        eventJson.addProperty("description", event.getDescription());
        eventJson.addProperty("location", event.getLocation().getNom());
        eventJson.addProperty("latitude", event.getPosition().getLatitude());
        eventJson.addProperty("longitude", event.getPosition().getLongitude());
        eventJson.addProperty("eventTime", event.getEventTime().toString());
        eventJson.addProperty("expirationTime", event.getExpirationTime().toString());
        eventJson.addProperty("categoryName", category.getName());
        //eventJson.addProperty("statut", event.getStatus());
        eventJson.addProperty("confianceScore", event.getConfiance_event().getScore());
        eventJson.add("participantUsernames", gson.toJsonTree(Collections.emptyList()));

        // 🔥 Publier sur MQTT
        mqttService.publish("trustevalevents", eventJson.toString());

        // 🔥 Envoyer mise à jour du profil
        JsonObject profileUpdateJson = new JsonObject();
        profileUpdateJson.addProperty("userId", creator.getId());
        profileUpdateJson.addProperty("action", "profile_updated");
        mqttService.publish("profile_updates", profileUpdateJson.toString());

        JsonObject eventUpdateJson = new JsonObject();
        eventUpdateJson.addProperty("id", event.getId());
        eventUpdateJson.addProperty("title", event.getTitle());
        eventUpdateJson.addProperty("location", event.getId());
        eventUpdateJson.addProperty("id", event.getId());
        eventUpdateJson.add("participantUsernames", gson.toJsonTree(Collections.emptyList()));
        eventUpdateJson.addProperty("confianceScore", event.getConfiance_event().getScore());
        eventUpdateJson.addProperty("location", event.getLocation().getNom());
        eventUpdateJson.addProperty("expirationTime", event.getExpirationTime().toString());
        eventUpdateJson.addProperty("action", "event_updated");
        mqttService.publish("event_updated", eventUpdateJson.toString());
    }

    /**
     * 📊 Obtenir tous les événements avec les statistiques
     */
    public EventResponseDTO getAllEventsWithStatistics() {
        List<Event> events = eventRepository.findAll();
        List<EventSummaryDTO> eventDTOs = eventMapper.toEventSummaryDTOList(events);
        EventStatisticsDTO statistics = calculateStatistics(eventDTOs);

        EventResponseDTO response = new EventResponseDTO();
        response.setEvents(eventDTOs);
        response.setStatistics(statistics);
        return response;
    }

    /**
     * 🔥 Enregistrer les événements dans un fichier JSON
     */
    public String writeToFile() {
        EventResponseDTO data = getAllEventsWithStatistics();
        try {
            // Vérifier et créer le répertoire si nécessaire
            Path directoryPath = Paths.get(SHARED_FOLDER_PATH);
            if (!Files.exists(directoryPath)) {
                Files.createDirectories(directoryPath);
            }

            // Écriture des données JSON dans le fichier
            File file = new File(SHARED_FOLDER_PATH, FILE_NAME);
            objectMapper.writeValue(file, data);

            return "✅ Successfully written to " + FILE_NAME;
        } catch (IOException e) {
            return "❌ Error writing to file: " + e.getMessage();
        }
    }

    /*public void saveEventsToJson() {
        saveEventsToJson(FILE_PATH);
    }

    public void saveEventsToJson(String filePath) {
        EventResponseDTO data = getAllEventsWithStatistics();
        try {
            objectMapper.writeValue(new File(filePath), data);
            System.out.println("✅ Données mises à jour dans " + filePath);
        } catch (IOException e) {
            System.err.println("❌ Erreur lors de l'écriture du fichier JSON : " + e.getMessage());
        }
    }*/

    /**
     * 📊 Calcul des statistiques des événements
     */
    private EventStatisticsDTO calculateStatistics(List<EventSummaryDTO> eventDTOs) {
        EventStatisticsDTO stats = new EventStatisticsDTO();
        stats.setTotalEvents(eventDTOs.size());

        OptionalDouble average = eventDTOs.stream()
                .mapToDouble(EventSummaryDTO::getConfidenceScore)
                .average();
        stats.setAverageConfidence(average.orElse(0.0));

        float maxConfidence = eventDTOs.stream()
                .map(EventSummaryDTO::getConfidenceScore)
                .max(Float::compare)
                .orElse(0.0f);
        stats.setMaxConfidence(maxConfidence);

        return stats;
    }

}
