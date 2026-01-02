package com.example.edge_server.controleur;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

@RestController
@RequestMapping("/api/files")
public class FileController {
    private final String sharedFolderPath = "/app/public-data";  // Path inside backend container
    private final String fileName = "events.json"; // Name of the file
    private final ObjectMapper objectMapper;  // JSON Mapper

    public FileController(ObjectMapper objectMapper) {
        this.objectMapper = objectMapper;
    }

    @GetMapping("/{filename}")
    public ResponseEntity<Resource> getFile(@PathVariable String filename) throws IOException {
        System.out.println("in in in ");
        Path filePath = Paths.get(sharedFolderPath).resolve(filename);
        Resource resource = new UrlResource(filePath.toUri());

        if (resource.exists() && resource.isReadable()) {
            return ResponseEntity.ok()
                    .header(HttpHeaders.CONTENT_DISPOSITION, "inline; filename=\"" + resource.getFilename() + "\"")
                    .body(resource);
        } else {
            return ResponseEntity.notFound().build();
        }
    }
    @PostMapping("/write")
    public ResponseEntity<String> writeToFile(@RequestBody String jsonData) {
        try {
            // Ensure the directory exists
            Path directoryPath = Paths.get(sharedFolderPath);
            if (!Files.exists(directoryPath)) {
                Files.createDirectories(directoryPath);
            }

            // Write JSON data to file
            File file = new File(sharedFolderPath, fileName);
            objectMapper.writeValue(file, objectMapper.readTree(jsonData));

            return ResponseEntity.ok("✅ Successfully written to " + fileName);
        } catch (IOException e) {
            return ResponseEntity.internalServerError()
                    .body("❌ Error writing to file: " + e.getMessage());
        }
    }
}
