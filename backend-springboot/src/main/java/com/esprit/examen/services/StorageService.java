package com.esprit.examen.services;

import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.UUID;

@Service
public class StorageService {

    private final Path root = Paths.get("uploads");

    public StorageService() {
        try {
            Files.createDirectories(root);
            System.out.println("DEBUG: StorageService initialized. Upload root: " + root.toAbsolutePath());
        } catch (IOException e) {
            throw new RuntimeException("Could not initialize folder for upload!");
        }
    }

    public String saveAvatar(MultipartFile file) {
        try {
            if (file.isEmpty()) {
                throw new RuntimeException("Failed to store empty file.");
            }
            String extension = getExtension(file.getOriginalFilename());
            String filename = UUID.randomUUID().toString() + "." + extension;
            Files.copy(file.getInputStream(), this.root.resolve(filename), StandardCopyOption.REPLACE_EXISTING);
            return "/api/users/profile-picture/" + filename;
        } catch (Exception e) {
            throw new RuntimeException("Could not store the file. Error: " + e.getMessage());
        }
    }

    public org.springframework.core.io.Resource load(String filename) {
        try {
            Path file = root.resolve(filename);
            org.springframework.core.io.Resource resource = new org.springframework.core.io.UrlResource(file.toUri());

            if (resource.exists() || resource.isReadable()) {
                return resource;
            } else {
                throw new RuntimeException("Could not read the file!");
            }
        } catch (java.net.MalformedURLException e) {
            throw new RuntimeException("Error: " + e.getMessage());
        }
    }

    private String getExtension(String filename) {
        if (filename == null)
            return "png";
        int lastDotIndex = filename.lastIndexOf(".");
        if (lastDotIndex == -1)
            return "png";
        return filename.substring(lastDotIndex + 1);
    }
}
