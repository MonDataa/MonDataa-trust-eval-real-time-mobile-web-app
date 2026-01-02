package com.example.edge_server.dto;

import lombok.Data;

@Data
public class CustomCategoryCreateDTO {
    private String name;
    private String description;
    private String customLabel;
    private String imageName;
}
