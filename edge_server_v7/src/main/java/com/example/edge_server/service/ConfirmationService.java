package com.example.edge_server.service;


import com.example.edge_server.config.MqttService;
import com.example.edge_server.dto.ConfirmationDTO;
import com.example.edge_server.entites.*;
import com.example.edge_server.mappers.ConfirmationMapper;
import com.example.edge_server.repositories.ClientRepository;
import com.example.edge_server.repositories.ConfianceEventRepository;
import com.example.edge_server.repositories.ConfirmationRepository;
import com.example.edge_server.repositories.EventRepository;
import com.google.gson.JsonObject;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ConfirmationService {
    private final ConfirmationRepository confirmationRepository;
    private final EventRepository eventRepository;
    private final ClientRepository clientRepository;
    private final ConfirmationMapper confirmationMapper;
    private final ConfianceEventRepository confianceEventRepository;
    private final MqttService mqttService;

    @Transactional
    public ConfirmationDTO confirmEvent(Long clientId, Long eventId) {
        // Vérifier si le client et l'événement existent
        Client client = clientRepository.findById(clientId)
                .orElseThrow(() -> new RuntimeException("Client non trouvé"));

        Event event = eventRepository.findById(eventId)
                .orElseThrow(() -> new RuntimeException("Événement non trouvé"));

        // Vérifier si une confirmation existe déjà
        Optional<Confirmation> existingConfirmation = confirmationRepository.findByClientIdAndEventId(clientId, eventId);

        if (existingConfirmation.isPresent()) {
            Confirmation confirmation = existingConfirmation.get();

            // 🔥 Vérifier si elle est déjà confirmée
            if (confirmation.isStatus()) {
                throw new RuntimeException("L'événement est déjà confirmé !");
            }

            // ✅ Mettre à jour l'état de la confirmation
            confirmation.setStatus(true);
            confirmation.setConfirmationTime(LocalDateTime.now());

            confirmationRepository.save(confirmation);

            // 🔥 Mettre à jour la confiance de l'utilisateur en fonction de la confirmation
            updateUserTrust(client, confirmation.isStatus());

            // ✅ Vérifier si l'événement doit être marqué comme `CONFIRMED` ou `REJECTED`
            updateEventStatus(event);

            // 📡 Publier une mise à jour du profil sur MQTT
            JsonObject profileUpdateJson = new JsonObject();
            profileUpdateJson.addProperty("userId", client.getId());
            profileUpdateJson.addProperty("action", "profile_updated");
            mqttService.publish("profile_updates", profileUpdateJson.toString());

            return confirmationMapper.toConfirmationDTO(confirmation);
        } else {
            // Si aucune confirmation n'existe, en créer une nouvelle
            Confirmation newConfirmation = new Confirmation();
            newConfirmation.setClient(client);
            newConfirmation.setEvent(event);
            newConfirmation.setStatus(true);
            newConfirmation.setConfirmationTime(LocalDateTime.now());

            confirmationRepository.save(newConfirmation);

            // 🔥 Mettre à jour la confiance du client
            updateUserTrust(client, true);

            updateEventTrust(event);

            // ✅ Vérifier si l'événement doit être confirmé ou rejeté
            updateEventStatus(event);


            return confirmationMapper.toConfirmationDTO(newConfirmation);
        }
    }

    @Transactional
    public ConfirmationDTO rejectEvent(Long clientId, Long eventId) {
        // Vérifier si le client et l'événement existent
        Client client = clientRepository.findById(clientId)
                .orElseThrow(() -> new RuntimeException("Client non trouvé"));

        Event event = eventRepository.findById(eventId)
                .orElseThrow(() -> new RuntimeException("Événement non trouvé"));

        // Vérifier si une confirmation existe déjà
        Optional<Confirmation> existingConfirmation = confirmationRepository.findByClientIdAndEventId(clientId, eventId);

        if (existingConfirmation.isPresent()) {
            Confirmation confirmation = existingConfirmation.get();

            // 🔥 Vérifier si elle est déjà rejetée
            if (!confirmation.isStatus()) {
                throw new RuntimeException("Vous avez déjà rejeté cet événement !");
            }

            // ❌ Mettre à jour l'état de la confirmation en rejet
            confirmation.setStatus(false);
            confirmation.setConfirmationTime(LocalDateTime.now());

            confirmationRepository.save(confirmation);

            // 🔥 Mettre à jour la confiance de l'utilisateur en fonction du rejet
            updateUserTrust(client, confirmation.isStatus());

            // ✅ Vérifier si l'événement doit être marqué comme `REJECTED`
            updateEventStatus(event);

            // 📡 Publier une mise à jour du profil sur MQTT
            JsonObject profileUpdateJson = new JsonObject();
            profileUpdateJson.addProperty("userId", client.getId());
            profileUpdateJson.addProperty("action", "profile_updated");
            mqttService.publish("profile_updates", profileUpdateJson.toString());

            return confirmationMapper.toConfirmationDTO(confirmation);
        } else {
            // ❌ Si aucune confirmation n'existe, créer une nouvelle avec `false`
            Confirmation newRejection = new Confirmation();
            newRejection.setClient(client);
            newRejection.setEvent(event);
            newRejection.setStatus(false); // 🔴 Rejet
            newRejection.setConfirmationTime(LocalDateTime.now());

            confirmationRepository.save(newRejection);

            // 🔥 Mettre à jour la confiance du client
            updateUserTrust(client, false);

            updateEventTrust(event);

            // ✅ Vérifier si l'événement doit être rejeté
            updateEventStatus(event);

            return confirmationMapper.toConfirmationDTO(newRejection);
        }
    }

    /**
     * 🔥 Mise à jour du score de confiance du client après confirmation ou rejet
     */
    private void updateUserTrust(Client client, boolean confirmed) {
        if (client.getConfiance() != null) {
            Confiance clientConfiance = client.getConfiance();
            List<Float> history = clientConfiance.getHistorique();
            if (history == null) {
                history = new ArrayList<>();
            }

            if (confirmed) {
                // ✅ Ajout à l'historique et augmentation du score
                history.add(clientConfiance.getScore());
                clientConfiance.setHistorique(history);
                clientConfiance.setScore(clientConfiance.getScore() + 1);
            } else {
                // ❌ Si rejet, baisse du score
                history.add(clientConfiance.getScore());
                clientConfiance.setHistorique(history);
                clientConfiance.setScore(clientConfiance.getScore() - 2);
            }

            // ✅ Sauvegarder la mise à jour du score
            clientRepository.save(client);
        }
    }

    /**
     * 🔥 Mise à jour du score de confiance de l'événement après confirmation ou rejet
     */
    private void updateEventTrust(Event event) {
        if (event.getConfiance_event() != null) {
            ConfianceEvent eventConfiance = event.getConfiance_event();
            List<Float> history = eventConfiance.getHistorique();
            if (history == null) {
                history = new ArrayList<>();
            }

            long totalConfirmations = event.getConfirmations().size();
            long confirmedCount = event.getConfirmations().stream().filter(Confirmation::isStatus).count();
            long rejectedCount = totalConfirmations - confirmedCount;

            float trustChange;

            if (confirmedCount > rejectedCount) {
                // ✅ L'événement est principalement confirmé → augmentation de confiance
                trustChange = 2.0f;
            } else if (rejectedCount > confirmedCount) {
                // ❌ L'événement est principalement rejeté → baisse de confiance
                trustChange = -3.0f;
            } else {
                // ⚖️ Égalité entre confirmations et rejets → pas de changement significatif
                trustChange = -1.0f;
            }

            // 🔥 Appliquer la mise à jour
            history.add(eventConfiance.getScore());
            eventConfiance.setHistorique(history);
            eventConfiance.setScore(Math.max(0, eventConfiance.getScore() + trustChange)); // 🔥 Eviter un score négatif

            // ✅ Sauvegarder la mise à jour du score
            confianceEventRepository.save(eventConfiance);
        }
    }


    /**
     * 📌 Vérifier si un événement doit être marqué comme CONFIRMED ou REJECTED
     */
    private void updateEventStatus(Event event) {
        long totalConfirmations = event.getConfirmations().size();
        long confirmedCount = event.getConfirmations().stream().filter(Confirmation::isStatus).count();
        long rejectedCount = totalConfirmations - confirmedCount;

        if (LocalDateTime.now().isAfter(event.getExpirationTime())) {
            if(confirmedCount >= rejectedCount) {
                event.setStatus(EventStatus.CONFIRMED);
                System.out.println("✅ L'événement ID: " + event.getId() + " est maintenant CONFIRMED !");
            }else {
                // ❌ Si aucune confirmation et l'événement est expiré, on le rejette
                event.setStatus(EventStatus.REJECTED);
                System.out.println("❌ L'événement ID: " + event.getId() + " est maintenant REJECTED !");
            }
        }
        eventRepository.save(event);

        // 📡 Publier une mise à jour de l'événement sur MQTT
        JsonObject eventUpdateJson = new JsonObject();
        eventUpdateJson.addProperty("eventId", event.getId());
        eventUpdateJson.addProperty("status", event.getStatus().toString());
        eventUpdateJson.addProperty("action", "event_status_updated");
        mqttService.publish("event_updated", eventUpdateJson.toString());
    }

    public List<ConfirmationDTO> getAllConfirmations() {
        return confirmationRepository.findAll()
                .stream()
                .map(confirmationMapper::toConfirmationDTO)
                .collect(Collectors.toList());
    }

    /**
     * Récupère une confirmation par ID.
     */
    public ConfirmationDTO getConfirmationById(Long id) {
        Confirmation confirmation = confirmationRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Confirmation non trouvée"));
        return confirmationMapper.toConfirmationDTO(confirmation);
    }

}
