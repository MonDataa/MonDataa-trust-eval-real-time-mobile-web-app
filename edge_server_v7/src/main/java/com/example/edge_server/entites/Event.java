package com.example.edge_server.entites;

import com.fasterxml.jackson.annotation.*;
import jakarta.annotation.Nullable;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
//@JsonIdentityInfo(generator = ObjectIdGenerators.PropertyGenerator.class, property = "id")
@NoArgsConstructor
@AllArgsConstructor
@Getter @Setter
public class Event {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String title;
    private String description;
    private LocalDateTime eventTime;
    private LocalDateTime expirationTime;
    private String imageName;

    @Enumerated(EnumType.STRING)
    private EventStatus status;

    // ✅ Relation avec le créateur
    @ManyToOne
    @JoinColumn(name = "creator_id", nullable = false)
    @JsonProperty(access = JsonProperty.Access.WRITE_ONLY)
    private Client creator;

    // ✅ Relation Many-to-One avec Category
    @ManyToOne
    @JoinColumn(name = "category_id", nullable = false)
    @JsonProperty(access = JsonProperty.Access.WRITE_ONLY)
    private Category category;

    @ManyToOne
    @JoinColumn(name = "location_id", nullable = false)
    private Location location;


    @OneToOne(cascade = CascadeType.ALL, orphanRemoval = true)
    @JoinColumn(name = "position_id", nullable = false)
    private Position position;

    @OneToOne(cascade = CascadeType.ALL, fetch = FetchType.LAZY, orphanRemoval = true)
    @JoinColumn(name = "confiance_event_id", referencedColumnName = "id", nullable = false)
    private ConfianceEvent confiance_event;

    // ✅ Correction : Relation OneToMany avec Confirmation
    @OneToMany(mappedBy = "event", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Confirmation> confirmations = new ArrayList<>();

}
