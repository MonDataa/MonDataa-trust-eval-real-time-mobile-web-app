package com.example.edge_server.service;

import com.example.edge_server.config.MqttService;
import com.example.edge_server.dto.*;
import com.example.edge_server.entites.*;
import com.example.edge_server.mappers.ClientMapper;
import com.example.edge_server.mappers.UserMapper;
import com.example.edge_server.repositories.ClientRepository;
import com.example.edge_server.repositories.LocationRepository;
import com.example.edge_server.repositories.UserRepository;
import com.google.gson.Gson;
import com.google.gson.JsonObject;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class UserService {
    private final UserRepository userRepository;
    private final ClientRepository clientRepository;
    private final LocationRepository locationRepository;
    private final UserMapper userMapper;
    private final ClientMapper clientMapper;
    private final MqttService mqttService;
    private final ObjectMapper objectMapper = new ObjectMapper();
    // private final PasswordEncoder passwordEncoder; // à ajouter si nécessaire

    // Chemin vers le volume partagé (dans Docker) et nom du fichier JSON
    private static final String SHARED_FOLDER_PATH = "/app/public-data";
    private static final String FILE_NAME = "users.json";

    @Transactional
    public UserDTO registerUser(UserSignupDTO userSignupDTO) {
        // Création et configuration du nouvel utilisateur
        Client user = new Client();
        user.setUsername(userSignupDTO.getUsername());
        user.setEmail(userSignupDTO.getEmail());
        user.setPassword(userSignupDTO.getPassword()); // ⚠️ Hachage à ajouter plus tard

        // 🔹 Associer la localisation si fournie
        if ("CLIENT".equalsIgnoreCase(userSignupDTO.getUserType())) {
            Location location = locationRepository.findById(userSignupDTO.getLocationId())
                    .orElseThrow(() -> new RuntimeException("Location non trouvée avec l'ID " + userSignupDTO.getLocationId()));
            user.setLocation(location);
        }

        // 🔹 Ajouter la position GPS
        Position position = new Position();
        position.setLatitude(userSignupDTO.getLatitude());
        position.setLongitude(userSignupDTO.getLongitude());
        position.setHorodatage(LocalDateTime.now());
        user.setPosition(position);

        // ✅ Ajouter la confiance par défaut
        Confiance confiance = new Confiance();
        confiance.setScore(50.0f);
        confiance.setHistorique(new ArrayList<>(List.of(50.0f)));
        user.setConfiance(confiance);

        // 🔥 Sauvegarder l'utilisateur dans la base de données
        userRepository.save(user);
        System.out.println("✅ Utilisateur sauvegardé avec ID : " + user.getId());

        // 🔄 Mettre à jour le fichier JSON avec les clients actuels
        System.out.println("📝 Mise à jour du fichier JSON après enregistrement...");
        saveClientsToJson();

        // 📡 Publier une mise à jour MQTT pour notifier la création de l'utilisateur
        publishUserToMqtt(user);

        return userMapper.toUserDTO(user);
    }

    /**
     * 📊 Obtenir tous les clients avec statistiques (par exemple, dans ClientResponseDTO)
     */
    public ClientResponseDTO getAllClientsWithStatistics() {
        List<Client> clients = clientRepository.findAll();
        List<ClientDTO> clientDTOs = clients.stream().map(clientMapper::toClientDTO).toList();

        // Méthode de calcul des statistiques à adapter selon votre logique métier
        ClientStatisticsDTO statistics = calculateStatistics(clientDTOs);

        ClientResponseDTO response = new ClientResponseDTO();
        response.setClients(clientDTOs);
        response.setStatistics(statistics);
        return response;
    }

    /**
     * 🔥 Sauvegarde des clients avec statistiques dans le fichier JSON (users.json)
     */
    public void saveClientsToJson() {
        ClientResponseDTO data = getAllClientsWithStatistics();

        try {
            // Vérifier et créer le répertoire si nécessaire
            Path directoryPath = Paths.get(SHARED_FOLDER_PATH);
            if (!Files.exists(directoryPath)) {
                Files.createDirectories(directoryPath);
            }
            // Écriture des données JSON dans le fichier via le volume partagé
            File file = new File(SHARED_FOLDER_PATH, FILE_NAME);
            objectMapper.writeValue(file, data);
            System.out.println("✅ Données clients mises à jour dans " + FILE_NAME);
        } catch (IOException e) {
            System.err.println("❌ Erreur lors de l'écriture du fichier JSON : " + e.getMessage());
        }
    }


    /**
     * 📊 Calcul des statistiques globales des clients
     */
    private ClientStatisticsDTO calculateStatistics(List<ClientDTO> clients) {
        ClientStatisticsDTO stats = new ClientStatisticsDTO();
        stats.setTotalClients(clients.size());

        OptionalDouble average = clients.stream().mapToDouble(ClientDTO::getConfidenceScore).average();
        stats.setAverageConfidence(average.orElse(0.0));

        float maxConfidence = clients.stream()
                .map(ClientDTO::getConfidenceScore)
                .max(Float::compare)
                .orElse(0.0f);

        // ✅ Vérifier si la liste `participations` contient bien des événements
        long totalParticipations = clients.stream()
                .flatMap(client -> client.getParticipations().stream()) // ⚠️ Récupérer tous les événements confirmés
                .count();

        stats.setMaxConfidence(maxConfidence);
        stats.setTotalParticipations(totalParticipations); // ✅ Maintenant correct

        return stats;
    }

    private void publishUserToMqtt(Client user) {
        Gson gson = new Gson();
        JsonObject userJson = new JsonObject();

        userJson.addProperty("id", user.getId());
        userJson.addProperty("username", user.getUsername());
        userJson.addProperty("email", user.getEmail());
        userJson.addProperty("location", user.getLocation().getNom());
        userJson.addProperty("latitude", user.getPosition().getLatitude());
        userJson.addProperty("longitude", user.getPosition().getLongitude());
        userJson.addProperty("confidenceScore", user.getConfiance().getScore());

        // 🔥 Publier sur MQTT
        mqttService.publish("user_updates", userJson.toString());
        System.out.println("📡 MQTT Publication : " + userJson);
    }

    public Optional<UserDTO> loginUser(UserLoginDTO userLoginDTO) {
        Optional<Useer> user = userRepository.findByEmail(userLoginDTO.getEmail());

        if (user.isPresent() && userLoginDTO.getPassword().equals(user.get().getPassword())) {
            return Optional.of(userMapper.toUserDTO(user.get())); // ✅ Retourne la latitude et la longitude
        }

        return Optional.empty();
    }


    // ✅ Afficher le profil d'un utilisateur avec historique et score de confiance
    public UserProfileDTO getUserProfile(Long userId) {
        Client client = userRepository.findById(userId)
                .filter(u -> u instanceof Client)
                .map(u -> (Client) u)
                .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));

        return userMapper.toUserProfileDTO(client);
    }

    // Méthode de déconnexion
    public String logoutUser(Long userId) {
        // Ici, vous pouvez vérifier que l'utilisateur existe
        // et réaliser d'éventuelles opérations d'invalidation de session ou de token.
        userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé avec l'id " + userId));
        // Par exemple, pour une application stateless, vous pouvez simplement retourner un message.
        return "Déconnexion réussie pour l'utilisateur avec l'id " + userId;
    }

    @Transactional
    public UserStatisticsDTO getUserStatistics(Long userId) {
        Useer foundUser = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé avec l'id " + userId));
        System.out.println("Utilisateur trouvé: " + foundUser.getUsername() + " (classe: " + foundUser.getClass().getSimpleName() + ")");

        // Vérifiez si c'est bien un Client
        Client client = (foundUser instanceof Client)
                ? (Client) foundUser
                : null;
        if (client == null) {
            throw new RuntimeException("L'utilisateur avec l'id " + userId + " n'est pas un Client.");
        }

        UserStatisticsDTO stats = new UserStatisticsDTO();
        int totalParticipations = (client.getConfirmations() != null)
                ? client.getConfirmations().size()
                : 0;
        stats.setTotalParticipations(totalParticipations);
        float averageTrustScore = (client.getConfiance() != null)
                ? client.getConfiance().getScore()
                : 0.0f;
        stats.setAverageTrustScore(averageTrustScore);
        List<Float> trustHistory = (client.getConfiance() != null && client.getConfiance().getHistorique() != null)
                ? client.getConfiance().getHistorique()
                : Collections.emptyList();
        stats.setTrustScoreHistory(trustHistory);
        return stats;
    }


    @Transactional
    public List<UserDTO> getAllClients() {
        // Récupérer la liste des clients depuis le repository
        List<Client> clients = clientRepository.findAll();
        // Mapper chaque Client en UserDTO
        return clients.stream()
                .map(userMapper::toUserDTO)
                .collect(Collectors.toList());
    }

    @Transactional
    public Page<UserDTO> getAllClientsPages(String username, Pageable pageable) {
        Page<Client> clientsPage;

        if (username != null && !username.trim().isEmpty()) {
            // Recherche par username si un filtre est fourni
            clientsPage = clientRepository.findByUsernameContainingIgnoreCase(username, pageable);
        } else {
            // Sinon, récupérer tous les clients avec pagination
            clientsPage = clientRepository.findAll(pageable);
        }

        // Mapper chaque Client en UserDTO
        return clientsPage.map(userMapper::toUserDTO);
    }

    @Transactional
    public Page<UserDTO> getAllClientsWithPositionPages(Pageable pageable) {
        Page<Client> clientsPage = clientRepository.findAllWithPosition(pageable);
        return clientsPage.map(userMapper::toUserDTO);
    }

    @Transactional
    public List<UserDTO> getAllClientsWithPosition() {
        List<Client> clients = clientRepository.findAllWithPosition();
        return clients.stream()
                .map(userMapper::toUserDTO)
                .collect(Collectors.toList());
    }

}

