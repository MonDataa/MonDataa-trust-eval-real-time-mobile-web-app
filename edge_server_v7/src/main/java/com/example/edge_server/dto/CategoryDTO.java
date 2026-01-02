package com.example.edge_server.dto;

import lombok.Data;

@Data
public class CategoryDTO {
    private Long id;
    private String name;
    private String description;
    private String categoryType;
    private String imageName;
}