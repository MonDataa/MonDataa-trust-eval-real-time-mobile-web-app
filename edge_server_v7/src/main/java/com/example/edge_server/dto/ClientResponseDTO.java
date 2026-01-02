package com.example.edge_server.dto;

import lombok.Data;

import java.util.List;

@Data
public class ClientResponseDTO {
    private List<ClientDTO> clients; // 📜 Liste des clients
    private ClientStatisticsDTO statistics; // 📊 Statistiques globales
}
