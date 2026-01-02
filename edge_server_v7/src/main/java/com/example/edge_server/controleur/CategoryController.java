package com.example.edge_server.controleur;

import com.example.edge_server.dto.CategoryDTO;
import com.example.edge_server.dto.CustomCategoryCreateDTO;
import com.example.edge_server.entites.CustomCategory;
import com.example.edge_server.service.CategoryService;
import com.example.edge_server.service.CustomCategoryService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/categories")
@RequiredArgsConstructor
public class CategoryController {

    private final CategoryService categoryService;
    private final CustomCategoryService customCategoryService;

    @GetMapping
    public ResponseEntity<List<CategoryDTO>> getAllCategories() {
        List<CategoryDTO> categories = categoryService.getAllCategories();
        return ResponseEntity.ok(categories);
    }

    @PostMapping("/custom")
    public ResponseEntity<CustomCategory> createCustomCategory(@RequestBody CustomCategoryCreateDTO dto) {

        CustomCategory createdCategory = customCategoryService.createCustomCategory(dto);
        return new ResponseEntity<>(createdCategory, HttpStatus.CREATED);
    }
}
