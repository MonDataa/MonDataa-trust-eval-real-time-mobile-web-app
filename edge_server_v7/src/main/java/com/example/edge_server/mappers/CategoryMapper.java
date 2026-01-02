package com.example.edge_server.mappers;

import com.example.edge_server.dto.CategoryDTO;
import com.example.edge_server.entites.Category;
import com.example.edge_server.entites.CustomCategory;
import org.springframework.stereotype.Component;

@Component
public class CategoryMapper {

    public CategoryDTO toDTO(Category category) {
        if (category == null) {
            return null;
        }
        CategoryDTO dto = new CategoryDTO();
        dto.setId(category.getId());
        dto.setName(category.getName());
        dto.setDescription(category.getDescription());
        dto.setImageName(category.getImageName());

        // Vérifier si la catégorie est personnalisée
        if (category instanceof CustomCategory) {
            dto.setCategoryType("CUSTOM");
        } else {
            dto.setCategoryType("PRECONFIGURED");
        }
        return dto;
    }
}
