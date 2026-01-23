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
        System.out.println("DEBUG: UserController.getProfile accessed by " + (connectedUser != null ? connectedUser.getName() : "anonymous"));
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
}
