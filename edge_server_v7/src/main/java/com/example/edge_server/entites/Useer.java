package com.example.edge_server.entites;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonManagedReference;
import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.persistence.*;
import lombok.*;

import java.util.ArrayList;
import java.util.List;

@Entity
@Inheritance(strategy = InheritanceType.JOINED) // Héritage pour Administrateur & Client
@DiscriminatorColumn(name = "user_type", discriminatorType = DiscriminatorType.STRING) // 🔥 Stocke "ADMIN" ou "CLIENT"
@NoArgsConstructor
@AllArgsConstructor
@Getter @Setter
public abstract class Useer { // 🔥 Rend la classe abstraite pour éviter l'instanciation directe

        @Id
        @GeneratedValue(strategy = GenerationType.IDENTITY)
        private Long id;

        @Column(nullable = false, unique = true)
        private String username;

        @Column(nullable = false)
        private String password;

        @Column(nullable = false)
        private String email;



}
