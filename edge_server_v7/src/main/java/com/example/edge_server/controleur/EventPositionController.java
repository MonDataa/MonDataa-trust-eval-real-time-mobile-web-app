package com.example.edge_server.controleur;

import com.example.edge_server.dto.PositionDTO;
import com.example.edge_server.service.PositionService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/events")
@RequiredArgsConstructor
public class EventPositionController {

    private final PositionService positionService;

    @GetMapping("/{eventId}/positions")
    public ResponseEntity<List<PositionDTO>> getPositionsByEventId(@PathVariable Long eventId) {
        List<PositionDTO> positions = positionService.getPositionsByEventId(eventId);
        return ResponseEntity.ok(positions);
    }

    @GetMapping("/positions")
    public ResponseEntity<List<PositionDTO>> getAllPositions() {
        List<PositionDTO> positions = positionService.getAllEventPositions();
        return ResponseEntity.ok(positions);
    }
}
