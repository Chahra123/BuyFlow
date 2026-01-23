package com.esprit.examen.controllers;

import com.esprit.examen.entities.User;
import com.esprit.examen.repositories.UserRepository;
import com.esprit.examen.services.UserService;
import javax.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/admin")
@RequiredArgsConstructor
@PreAuthorize("hasRole('ADMIN')")
public class AdminController {

    private final UserRepository userRepository;
    private final UserService userService;

    @GetMapping("/users")
    public ResponseEntity<Page<com.esprit.examen.dto.response.UserResponse>> getAllUsers(
            @RequestParam(required = false, defaultValue = "") String query,
            Pageable pageable) {
        Page<User> users;
        if (query == null || query.trim().isEmpty()) {
            users = userRepository.findAll(pageable);
        } else {
            users = userRepository.searchUsers(query.trim(), pageable);
        }
        
        return ResponseEntity.ok(users.map(this::mapToUserResponse));
    }

    private com.esprit.examen.dto.response.UserResponse mapToUserResponse(User user) {
        return com.esprit.examen.dto.response.UserResponse.builder()
                .id(user.getId())
                .firstName(user.getFirstName())
                .lastName(user.getLastName())
                .email(user.getEmail())
                .role(user.getRole())
                .avatarUrl(user.getAvatarUrl())
                .enabled(user.isEnabled())
                .createdAt(user.getCreatedAt())
                .build();
    }

    @GetMapping("/stats")
    public ResponseEntity<com.esprit.examen.dto.response.AdminStatsResponse> getStats() {
        long total = userRepository.count();
        long enabled = userRepository.countByEnabledTrue();
        long admins = userRepository.countByRole(com.esprit.examen.entities.Role.ADMIN);
        
        // Simplified new users last 24h
        java.time.LocalDateTime last24h = java.time.LocalDateTime.now().minusHours(24);
        long newUsers = userRepository.countByCreatedAtAfter(last24h);

        return ResponseEntity.ok(com.esprit.examen.dto.response.AdminStatsResponse.builder()
                .totalUsers(total)
                .enabledUsers(enabled)
                .adminUsers(admins)
                .newUsersLast24h(newUsers)
                .build());
    }

    @GetMapping("/users/{id}")
    public ResponseEntity<com.esprit.examen.dto.response.UserResponse> getUser(@PathVariable Long id) {
        return ResponseEntity.ok(userRepository.findById(id)
                .map(this::mapToUserResponse)
                .orElseThrow());
    }

    @DeleteMapping("/users/{id}")
    public ResponseEntity<?> deleteUser(@PathVariable Long id) {
        userRepository.deleteById(id);
        return ResponseEntity.accepted().build();
    }

    @PostMapping("/users")
    public ResponseEntity<com.esprit.examen.dto.response.UserResponse> createUser(@RequestBody @Valid com.esprit.examen.dto.request.CreateUserRequest request) {
        return ResponseEntity.ok(mapToUserResponse(userService.createUser(request)));
    }

    @PutMapping("/users/{id}")
    public ResponseEntity<com.esprit.examen.dto.response.UserResponse> updateUser(@PathVariable Long id, 
                                           @RequestBody @Valid com.esprit.examen.dto.request.UpdateUserRequest request) {
        return ResponseEntity.ok(mapToUserResponse(userService.updateUser(id, request)));
    }

    @PatchMapping("/users/{id}/status")
    public ResponseEntity<?> toggleUserStatus(@PathVariable Long id, @RequestParam boolean enabled) {
        userService.toggleUserStatus(id, enabled);
        return ResponseEntity.ok().build();
    }
}
