package com.example.edge_server.mappers;

import com.example.edge_server.dto.CustomCategoryCreateDTO;
import com.example.edge_server.entites.CustomCategory;
import org.springframework.stereotype.Component;

@Component
public class CustomCategoryMapper {

    public CustomCategory toEntity(CustomCategoryCreateDTO dto) {
        if (dto == null) {
            return null;
        }
        CustomCategory entity = new CustomCategory();
        entity.setName(dto.getName());
        entity.setDescription(dto.getDescription());
        entity.setCustomLabel(dto.getCustomLabel());
        entity.setImageName(dto.getImageName());
        return entity;
    }
}
