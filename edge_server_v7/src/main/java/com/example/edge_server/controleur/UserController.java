package com.example.edge_server.controleur;

import com.example.edge_server.dto.*;
import com.example.edge_server.service.ParticipationService;
import com.example.edge_server.service.TrustScoreService;
import com.example.edge_server.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {
    private final UserService userService;
    private final ParticipationService participationService;
    private final TrustScoreService trustScoreService;


    @GetMapping("/statistics")
    public ResponseEntity<ClientResponseDTO> getAllClientsWithStatistics() {
        ClientResponseDTO response = userService.getAllClientsWithStatistics();
        return ResponseEntity.ok(response);
    }
    /**
     * 🔥 Exporter les utilisateurs avec statistiques en fichier JSON
     */
    @GetMapping("/export")
    public ResponseEntity<String> exportClientsToJson() {
        userService.saveClientsToJson();
        return ResponseEntity.ok("✅ Fichier JSON mis à jour !");
    }

    @PostMapping("/register")
    public ResponseEntity<UserDTO> registerUser(@RequestBody UserSignupDTO userSignupDTO) {
        return ResponseEntity.ok(userService.registerUser(userSignupDTO));
    }

    @PostMapping("/login")
    public ResponseEntity<UserDTO> loginUser(@RequestBody UserLoginDTO userLoginDTO) {
        Optional<UserDTO> user = userService.loginUser(userLoginDTO);
        return user.map(ResponseEntity::ok).orElseGet(() -> ResponseEntity.status(401).build());
    }

    @PostMapping("/logout")
    public ResponseEntity<String> logout(@RequestParam Long userId) {
        String message = userService.logoutUser(userId);
        return ResponseEntity.ok(message);
    }

    @GetMapping("/{userId}/profile")
    public ResponseEntity<UserProfileDTO> getUserProfile(@PathVariable Long userId) {
        return ResponseEntity.ok(userService.getUserProfile(userId));
    }

    @GetMapping("/{userId}/statistics")
    public ResponseEntity<UserStatisticsDTO> getUserStatistics(@PathVariable Long userId) {
        UserStatisticsDTO stats = userService.getUserStatistics(userId);
        return ResponseEntity.ok(stats);
    }

    @GetMapping("/{userId}/participation-history")
    public ResponseEntity<List<EventParticipationDTO>> getParticipationHistory(@PathVariable Long userId) {
        return ResponseEntity.ok(participationService.getParticipationHistory(userId));
    }

    @GetMapping("/{userId}/trust-score")
    public ResponseEntity<TrustScoreDTO> getTrustScore(@PathVariable Long userId) {
        return ResponseEntity.ok(trustScoreService.getTrustScore(userId));
    }

    @GetMapping("/clients")
    public ResponseEntity<List<UserDTO>> getAllClients() {
        List<UserDTO> clients = userService.getAllClients();
        return ResponseEntity.ok(clients);
    }

    @GetMapping("/clientspages")
    public Page<UserDTO> getAllClientsPages(
            @RequestParam(required = false) String username,
            Pageable pageable) {
        return userService.getAllClientsPages(username, pageable);
    }

    @GetMapping("/clients/with-position-pages")
    public Page<UserDTO> getClientsWithPosition(Pageable pageable) {
        return userService.getAllClientsWithPositionPages(pageable);
    }

    @GetMapping("/clients/with-position")
    public List<UserDTO> getClientsWithPosition() {
        return userService.getAllClientsWithPosition();
    }
}

