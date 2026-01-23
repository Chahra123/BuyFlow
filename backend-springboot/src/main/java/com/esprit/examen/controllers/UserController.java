package com.esprit.examen.controllers;

import com.esprit.examen.dto.request.ChangePasswordRequest;
import com.esprit.examen.dto.response.UserResponse;
import com.esprit.examen.services.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.security.Principal;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @PatchMapping("/me/change-password")
    public ResponseEntity<?> changePassword(
            @RequestBody ChangePasswordRequest request,
            Principal connectedUser) {
        userService.changePassword(request, connectedUser);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/me")
    public ResponseEntity<UserResponse> getProfile(Principal connectedUser) {
        System.out.println("DEBUG: UserController.getProfile accessed by "
                + (connectedUser != null ? connectedUser.getName() : "anonymous"));
        return ResponseEntity.ok(userService.getProfile(connectedUser));
    }

    @PatchMapping("/me")
    public ResponseEntity<?> updateProfile(
            @RequestBody com.esprit.examen.dto.request.UpdateProfileRequest request,
            Principal connectedUser) {
        userService.updateProfile(request, connectedUser);
        return ResponseEntity.accepted().build();
    }

    @PostMapping("/me/photo")
    public ResponseEntity<String> uploadPhoto(
            @RequestParam("file") org.springframework.web.multipart.MultipartFile file,
            Principal connectedUser) {
        return ResponseEntity.ok(userService.uploadProfilePicture(file, connectedUser));
    }

    @GetMapping("/profile-picture/{filename:.+}")
    public ResponseEntity<org.springframework.core.io.Resource> getProfilePicture(@PathVariable String filename,
            javax.servlet.http.HttpServletRequest request) {
        System.out.println("DEBUG: Requesting profile picture: " + filename);
        org.springframework.core.io.Resource file = userService.loadProfilePicture(filename);

        try {
            System.out.println("DEBUG: Resolved file path: " + file.getFile().getAbsolutePath());
            System.out.println("DEBUG: File exists: " + file.exists() + ", Readable: " + file.isReadable());
        } catch (Exception e) {
            System.out.println("DEBUG: Error resolving file: " + e.getMessage());
        }

        String contentType = null;
        try {
            contentType = request.getServletContext().getMimeType(file.getFile().getAbsolutePath());
        } catch (java.io.IOException ex) {
            // logger.info("Could not determine file type.");
        }

        // Fallback to the default content type if type could not be determined
        if (contentType == null) {
            contentType = "application/octet-stream";
        }
        System.out.println("DEBUG: Serving with Content-Type: " + contentType);

        return ResponseEntity.ok()
                .header(org.springframework.http.HttpHeaders.CONTENT_DISPOSITION,
                        "inline; filename=\"" + file.getFilename() + "\"")
                .contentType(org.springframework.http.MediaType.parseMediaType(contentType))
                .body(file);
    }
}
