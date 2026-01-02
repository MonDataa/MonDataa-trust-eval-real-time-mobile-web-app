package com.example.edge_server.service;

import com.example.edge_server.dto.CustomCategoryCreateDTO;
import com.example.edge_server.entites.CustomCategory;
import com.example.edge_server.repositories.CategoryRepository;
import com.example.edge_server.mappers.CustomCategoryMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
@Service
@RequiredArgsConstructor
public class CustomCategoryService {

    private final CategoryRepository categoryRepository;
    private final CustomCategoryMapper customCategoryMapper;

    @Transactional
    public CustomCategory createCustomCategory(CustomCategoryCreateDTO dto) {
        System.out.println("imagebckend"+ dto.getImageName());
        // Vous pouvez ajouter ici une vérification pour éviter les doublons (ex. vérifier si un nom existe déjà)
        if (categoryRepository.existsByName(dto.getName())) {
            throw new RuntimeException("Une catégorie portant le nom " + dto.getName() + " existe déjà.");
        }
        CustomCategory customCategory = customCategoryMapper.toEntity(dto);
        return categoryRepository.save(customCategory);
    }
}