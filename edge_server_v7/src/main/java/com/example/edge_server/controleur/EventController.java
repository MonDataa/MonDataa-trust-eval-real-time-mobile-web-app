package com.example.edge_server.controleur;

import com.example.edge_server.dto.*;
import com.example.edge_server.entites.Event;
import com.example.edge_server.service.EventService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequestMapping("/api/events")
@RequiredArgsConstructor
public class EventController {
    private final EventService eventService;

    @GetMapping("/{eventId}/details")
    public ResponseEntity<EventDetailDTO> getEventDetails(@PathVariable Long eventId) {
        EventDetailDTO eventDetail = eventService.getEventDetails(eventId);
        return ResponseEntity.ok(eventDetail);
    }


    @GetMapping
    public ResponseEntity<List<EventDTO>> getAllEvents() {
        List<EventDTO> events = eventService.getAllEvents();
        return new ResponseEntity<>(events, HttpStatus.OK);
    }

    @GetMapping("/pages")
    public Page<EventDTO> getAllEvents(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "8") int size,
            @RequestParam(required = false) String title // 🔍 Paramètre facultatif
    ) {
        if (title != null && !title.isEmpty()) {
            return eventService.getEventsByTitle(title, page, size);
        }
        return eventService.getAllEventsPaginated(page, size);
    }

    @GetMapping("/filtered")
    public ResponseEntity<List<EventFilterDTO>> getEventsFiltered(
            @RequestParam("startDate") String startDate,
            @RequestParam("endDate") String endDate,
            @RequestParam("zone") String zone) {

        EventFilterDTO filterDTO = new EventFilterDTO(
                LocalDateTime.parse(startDate),
                LocalDateTime.parse(endDate),
                zone
        );
        List<EventFilterDTO> filteredEvents = eventService.getEventsFiltered(filterDTO);
        return ResponseEntity.ok(filteredEvents);
    }

    @PostMapping
    public ResponseEntity<EventSummaryDTO> createEventest(@RequestBody EventCreateDTO eventCreateDTO) {
        EventSummaryDTO savedEvent = eventService.registerEvent(eventCreateDTO);
        return ResponseEntity.ok(savedEvent);
    }


    @GetMapping("/summary")
    public ResponseEntity<EventResponseDTO> getEventSummary() {
        return ResponseEntity.ok(eventService.getAllEventsWithStatistics());
    }

    @PostMapping("/save-json")
    public ResponseEntity<String> saveEventsToJson() {
        eventService.writeToFile();
        return ResponseEntity.ok("✅ Fichier JSON mis à jour !");
    }
}

