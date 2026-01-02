package com.example.edge_server.entites;

import com.fasterxml.jackson.annotation.JsonBackReference;
import com.fasterxml.jackson.annotation.JsonIdentityInfo;
import com.fasterxml.jackson.annotation.ObjectIdGenerators;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
//@JsonIdentityInfo(generator = ObjectIdGenerators.PropertyGenerator.class, property = "id")
@NoArgsConstructor
@AllArgsConstructor
@Getter
@Setter
public class Position {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private float latitude;
    private float longitude;

    private LocalDateTime horodatage; // 🔥 Timestamp de la position

    // ✅ Ajout de la relation inverse avec `Client`
    @OneToOne(mappedBy = "position", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    //@JsonBackReference // Ajouté ici
    private Client client;
}
