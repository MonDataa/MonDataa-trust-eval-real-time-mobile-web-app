package com.example.edge_server.entites;

public enum EventStatus {
    PENDING,    // En attente de confirmation
    CONFIRMED,  // Confirmé
    REJECTED,   // Rejeté
    EXPIRED     // Expiré après la période limite
}
