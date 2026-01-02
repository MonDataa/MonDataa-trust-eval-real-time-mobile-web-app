package com.example.edge_server.controleur;


import com.example.edge_server.dto.ConfirmationDTO;
import com.example.edge_server.service.ConfirmationService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/confirmations")
@RequiredArgsConstructor
public class ConfirmationController {
    private final ConfirmationService confirmationService;

    @PostMapping("/confirm")
    public ResponseEntity<ConfirmationDTO> confirmEvent(@RequestBody Map<String, Long> request) {
        Long clientId = request.get("clientId");
        Long eventId = request.get("eventId");

        ConfirmationDTO confirmationDTO = confirmationService.confirmEvent(clientId, eventId);
        return ResponseEntity.ok(confirmationDTO);
    }

    @PostMapping("/reject")
    public ResponseEntity<ConfirmationDTO> rejectEvent(@RequestBody Map<String, Long> request) {
        Long clientId = request.get("clientId");
        Long eventId = request.get("eventId");

        if (clientId == null || eventId == null) {
            return ResponseEntity.badRequest().build();
        }

        ConfirmationDTO confirmationDTO = confirmationService.rejectEvent(clientId, eventId);
        return ResponseEntity.ok(confirmationDTO);
    }

    @GetMapping
    public ResponseEntity<List<ConfirmationDTO>> getAllConfirmations() {
        List<ConfirmationDTO> confirmations = confirmationService.getAllConfirmations();
        return ResponseEntity.ok(confirmations);
    }

    /**
     * Récupérer une confirmation par ID.
     */
    @GetMapping("/{id}")
    public ResponseEntity<ConfirmationDTO> getConfirmationById(@PathVariable Long id) {
        ConfirmationDTO confirmationDTO = confirmationService.getConfirmationById(id);
        return ResponseEntity.ok(confirmationDTO);
    }
}
