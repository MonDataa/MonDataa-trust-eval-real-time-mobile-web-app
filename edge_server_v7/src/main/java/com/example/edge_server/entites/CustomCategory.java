package com.example.edge_server.entites;

import jakarta.persistence.DiscriminatorValue;
import jakarta.persistence.Entity;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@DiscriminatorValue("CUSTOM")
@NoArgsConstructor
@AllArgsConstructor
@Getter
@Setter
public class CustomCategory extends Category {
    private String customLabel;
}
