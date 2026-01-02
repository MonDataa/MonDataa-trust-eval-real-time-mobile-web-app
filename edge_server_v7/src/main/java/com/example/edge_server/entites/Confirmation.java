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
public class Confirmation {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private LocalDateTime confirmationTime;

    private boolean status; // ✅ Indique si l'événement est confirmé ou non

    @ManyToOne
    @JoinColumn(name = "event_id", nullable = false) // ✅ Plusieurs confirmations pour un seul événement
    private Event event;

    @ManyToOne
    @JoinColumn(name = "client_id", nullable = false) // ✅ Un client peut faire plusieurs confirmations
    //@JsonBackReference // Ajouté ici
    private Client client;
}

