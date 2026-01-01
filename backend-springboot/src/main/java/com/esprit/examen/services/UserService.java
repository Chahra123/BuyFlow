package com.esprit.examen.services;

import com.esprit.examen.dto.request.ChangePasswordRequest;
import com.esprit.examen.entities.User;
import com.esprit.examen.repositories.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.security.Principal;

@Service
@RequiredArgsConstructor
public class UserService {

    private final PasswordEncoder passwordEncoder;
    private final UserRepository userRepository;
    private final com.esprit.examen.repositories.TokenRepository tokenRepository;
    private final EmailService emailService;
    private final StorageService storageService;

    public void changePassword(ChangePasswordRequest request, Principal connectedUser) {

        var user = (User) ((org.springframework.security.authentication.UsernamePasswordAuthenticationToken) connectedUser)
                .getPrincipal();

        // check if the current password is correct
        if (!passwordEncoder.matches(request.getCurrentPassword(), user.getPassword())) {
            throw new IllegalStateException("Wrong password");
        }
        // check if the two new passwords are the same
        if (!request.getNewPassword().equals(request.getConfirmationPassword())) {
            throw new IllegalStateException("Password are not the same");
        }

        // update the password
        user.setPassword(passwordEncoder.encode(request.getNewPassword()));
        userRepository.save(user);
    }

    public com.esprit.examen.dto.response.UserResponse getProfile(Principal connectedUser) {
        var user = (User) ((org.springframework.security.authentication.UsernamePasswordAuthenticationToken) connectedUser)
                .getPrincipal();
        return com.esprit.examen.dto.response.UserResponse.builder()
                .id(user.getId())
                .firstName(user.getFirstName())
                .lastName(user.getLastName())
                .email(user.getEmail())
                .role(user.getRole())
                .avatarUrl(user.getAvatarUrl())
                .build();
    }

    public void updateProfile(com.esprit.examen.dto.request.UpdateProfileRequest request, Principal connectedUser) {
        var user = (User) ((org.springframework.security.authentication.UsernamePasswordAuthenticationToken) connectedUser)
                .getPrincipal();

        if (request.getFirstName() != null && !request.getFirstName().isBlank())
            user.setFirstName(request.getFirstName());
        if (request.getLastName() != null && !request.getLastName().isBlank())
            user.setLastName(request.getLastName());

        userRepository.save(user);
    }

    public String uploadProfilePicture(org.springframework.web.multipart.MultipartFile file, Principal connectedUser) {
        var user = (User) ((org.springframework.security.authentication.UsernamePasswordAuthenticationToken) connectedUser)
                .getPrincipal();
        String avatarUrl = storageService.saveAvatar(file);
        user.setAvatarUrl(avatarUrl);
        userRepository.save(user);
        return avatarUrl;
    }

    // Admin methods
    public User createUser(com.esprit.examen.dto.request.CreateUserRequest request) {
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new RuntimeException("Email already exists");
        }

        String password = request.getPassword() != null && !request.getPassword().isBlank()
                ? request.getPassword()
                : java.util.UUID.randomUUID().toString(); // Auto-generate if not provided

        var user = User.builder()
                .firstName(request.getFirstName())
                .lastName(request.getLastName())
                .email(request.getEmail())
                .password(passwordEncoder.encode(password))
                .role(request.getRole())
                .provider(User.Provider.LOCAL)
                .enabled(true) // Admin-created users are enabled by default
                .build();

        var savedUser = userRepository.save(user);

        // Send welcome email with credentials if password was auto-generated
        if (request.getPassword() == null || request.getPassword().isBlank()) {
            emailService.sendEmail(user.getEmail(), "Account Created",
                    "<h1>Welcome!</h1><p>Your account has been created.</p><p>Temporary password: <strong>" 
                    + password + "</strong></p><p>Please change it upon first login.</p>");
        }

        return savedUser;
    }

    public User updateUser(Long id, com.esprit.examen.dto.request.UpdateUserRequest request) {
        var user = userRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("User not found"));

        if (request.getFirstName() != null && !request.getFirstName().isBlank())
            user.setFirstName(request.getFirstName());
        if (request.getLastName() != null && !request.getLastName().isBlank())
            user.setLastName(request.getLastName());
        if (request.getEmail() != null && !request.getEmail().isBlank()) {
            if (!request.getEmail().equals(user.getEmail()) && userRepository.existsByEmail(request.getEmail())) {
                throw new RuntimeException("Email already in use");
            }
            user.setEmail(request.getEmail());
        }
        if (request.getRole() != null)
            user.setRole(request.getRole());
        if (request.getEnabled() != null)
            user.setEnabled(request.getEnabled());
        if (request.getAvatarUrl() != null)
            user.setAvatarUrl(request.getAvatarUrl());

        return userRepository.save(user);
    }

    public void toggleUserStatus(Long id, boolean enabled) {
        var user = userRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("User not found"));
        
        user.setEnabled(enabled);
        userRepository.save(user);

        // If disabling, revoke all tokens
        if (!enabled) {
            revokeAllUserTokens(user);
        }
    }

    private void revokeAllUserTokens(User user) {
        var validUserTokens = tokenRepository.findAllValidTokenByUser(user.getId());
        if (!validUserTokens.isEmpty()) {
            validUserTokens.forEach(token -> {
                token.setExpired(true);
                token.setRevoked(true);
            });
            tokenRepository.saveAll(validUserTokens);
        }
    }
}
