package com.example.edge_server.mappers;

import com.example.edge_server.dto.CreateConfianceEventDTO;
import com.example.edge_server.entites.ConfianceEvent;
import org.springframework.stereotype.Component;

@Component
public class ConfianceEventMapperManual {

    public static ConfianceEvent toEntity(CreateConfianceEventDTO dto) {
        if (dto == null) {
            return null;
        }
        ConfianceEvent confianceEvent = new ConfianceEvent();
        // Si l'id est fourni (cas de mise à jour par exemple) on peut le définir.
        confianceEvent.setId(dto.getId());
        confianceEvent.setScore(dto.getScore());
        // Vous pouvez ajouter ici d'autres mappings si nécessaire (par exemple l'historique)
        return confianceEvent;
    }
}
