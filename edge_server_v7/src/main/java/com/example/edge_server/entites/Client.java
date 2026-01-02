package com.example.edge_server.entites;

import com.fasterxml.jackson.annotation.*;
import jakarta.persistence.*;
import lombok.*;

import java.util.ArrayList;
import java.util.List;

@Entity
@DiscriminatorValue("CLIENT") // 🔥 Indique que c'est un Client en base
//@JsonIdentityInfo(generator = ObjectIdGenerators.PropertyGenerator.class, property = "id")
@NoArgsConstructor
@AllArgsConstructor
@Getter
@Setter
public class Client extends Useer {

    @OneToOne(cascade = CascadeType.ALL, fetch = FetchType.LAZY, orphanRemoval = true)
    @JoinColumn(name = "position_id", referencedColumnName = "id", nullable = true)
    //@JsonManagedReference // Ajouté ici
    private Position position;


    @ManyToOne
    @JoinColumn(name = "location_id", nullable = false)
    private Location location;

    @OneToOne(cascade = CascadeType.ALL, fetch = FetchType.LAZY, orphanRemoval = true)
    @JoinColumn(name = "confiance_id", referencedColumnName = "id", nullable = true)
    //@JsonManagedReference // Ajouté ici
    private Confiance confiance;

    @OneToMany(mappedBy = "client", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Confirmation> confirmations= new ArrayList<>(); // 🔥 Relation One-to-Many avec Confirmation

    // Relation 1:N - Créateur d'événements
    //@JsonIgnore
    @OneToMany(mappedBy = "creator", cascade = CascadeType.ALL, orphanRemoval = true)
    @JsonProperty(access = JsonProperty.Access.WRITE_ONLY)
    private List<Event> createdEvents= new ArrayList<>();
}
