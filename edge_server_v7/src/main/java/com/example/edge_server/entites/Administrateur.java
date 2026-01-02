package com.example.edge_server.entites;

import jakarta.persistence.*;
import lombok.*;

@Entity
@DiscriminatorValue("ADMINEDGE") // 🔥 Indique que c'est un Administrateur en base
@NoArgsConstructor
//@AllArgsConstructor
@Getter
@Setter
public class Administrateur extends Useer {
}
