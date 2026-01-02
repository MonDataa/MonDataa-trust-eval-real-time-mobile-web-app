package com.example.edge_server.entites;

import com.fasterxml.jackson.annotation.JsonIdentityInfo;
import com.fasterxml.jackson.annotation.ObjectIdGenerators;
import jakarta.persistence.*;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.NotNull;
import lombok.*;

import java.util.List;

@Entity
//@JsonIdentityInfo(generator = ObjectIdGenerators.PropertyGenerator.class, property = "id")
@NoArgsConstructor
@AllArgsConstructor
@Getter
@Setter
public class Confiance {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Max(100)
    @NotNull
    private float score;

    @ElementCollection
    private List<Float> historique; // 🔥 Liste des scores passés

    // ✅ Ajout de la relation inverse avec `Client`
    @OneToOne(mappedBy = "confiance", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private Client client;
}
