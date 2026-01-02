package com.example.edge_server.entites;

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
public class ConfianceEvent {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Max(100)
    @NotNull
    private float score;

    @ElementCollection
    private List<Float> historique; // 🔥 Liste des scores passés

    @OneToOne(mappedBy = "confiance_event", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private Event confiance_event_id;
}
