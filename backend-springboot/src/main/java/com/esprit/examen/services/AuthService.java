package com.esprit.examen.services;

import com.esprit.examen.dto.request.*;
import com.esprit.examen.dto.response.AuthenticationResponse;
import com.esprit.examen.entities.PasswordResetToken;
import com.esprit.examen.entities.Role;
import com.esprit.examen.entities.Token;
import com.esprit.examen.entities.User;
import com.esprit.examen.exception.EmailAlreadyExistsException;
import com.esprit.examen.repositories.PasswordResetTokenRepository;
import com.esprit.examen.repositories.TokenRepository;
import com.esprit.examen.repositories.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.UUID;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final TokenRepository tokenRepository;
    private final PasswordResetTokenRepository passwordResetTokenRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final AuthenticationManager authenticationManager;
    private final EmailService emailService;

    public AuthenticationResponse register(RegisterRequest request) {
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new EmailAlreadyExistsException("Cet email est déjà utilisé");
        }

        var user = User.builder()
                .firstName(request.getFirstName())
                .lastName(request.getLastName())
                .email(request.getEmail())
                .password(passwordEncoder.encode(request.getPassword()))
                .role(request.getRole() != null && request.getRole().equalsIgnoreCase("LIVREUR") ? Role.LIVREUR : Role.USER)
                .provider(User.Provider.LOCAL)
                .enabled(false) 
                .verificationToken(UUID.randomUUID().toString())
                .verificationTokenExpiry(java.time.LocalDateTime.now().plusHours(24))
                .build();

        var savedUser = userRepository.save(user);

        // Send Verification Email
        // Pointing to Frontend URL (port 52552) with hash strategy
        String verificationLink = "http://localhost:52552/#/verify-email?token=" + user.getVerificationToken();
        emailService.sendEmail(user.getEmail(), "Vérifiez votre email", 
            "<h1>Bienvenue !</h1><p>Cliquez <a href='" + verificationLink + "'>ici</a> pour vérifier votre compte.</p>");

        return AuthenticationResponse.builder()
                .message("Compte créé avec succès ! Vérifiez vos emails.")
                .build();
    }

    public AuthenticationResponse authenticate(AuthenticationRequest request) {
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                        request.getEmail(),
                        request.getPassword()));
        var user = userRepository.findByEmail(request.getEmail())
                .orElseThrow();
        var jwtToken = jwtService.generateToken(user);
        var refreshToken = jwtService.generateRefreshToken(user);
        revokeAllUserTokens(user);
        saveUserToken(user, jwtToken);
        
        return AuthenticationResponse.builder()
                .accessToken(jwtToken)
                .refreshToken(refreshToken)
                .user(com.esprit.examen.dto.response.UserResponse.builder()
                        .id(user.getId())
                        .email(user.getEmail())
                        .firstName(user.getFirstName())
                        .lastName(user.getLastName())
                        .role(user.getRole())
                        .avatarUrl(user.getAvatarUrl())
                        .build())
                .build();
    }

    private void saveUserToken(User user, String jwtToken) {
        var token = Token.builder()
                .user(user)
                .token(jwtToken)
                .tokenType(Token.TokenType.BEARER)
                .expired(false)
                .revoked(false)
                .build();
        tokenRepository.save(token);
    }

    private void revokeAllUserTokens(User user) {
        var validUserTokens = tokenRepository.findAllValidTokenByUser(user.getId());
        if (validUserTokens.isEmpty())
            return;
        validUserTokens.forEach(token -> {
            token.setExpired(true);
            token.setRevoked(true);
        });
        tokenRepository.saveAll(validUserTokens);
    }

    public AuthenticationResponse refreshToken(
            String refreshToken) {
        final String userEmail = jwtService.extractUsername(refreshToken);
        if (userEmail != null) {
            var user = this.userRepository.findByEmail(userEmail)
                    .orElseThrow();
            if (jwtService.isTokenValid(refreshToken, user)) {
                var accessToken = jwtService.generateToken(user);
                revokeAllUserTokens(user);
                saveUserToken(user, accessToken);
                return AuthenticationResponse.builder()
                        .accessToken(accessToken)
                        .refreshToken(refreshToken)
                        .user(com.esprit.examen.dto.response.UserResponse.builder()
                                .id(user.getId())
                                .email(user.getEmail())
                                .firstName(user.getFirstName())
                                .lastName(user.getLastName())
                                .role(user.getRole())
                                .avatarUrl(user.getAvatarUrl())
                                .build())
                        .build();
            }
        }
        throw new RuntimeException("Invalid refresh token");
    }
    public void forgotPassword(ForgotPasswordRequest request) {
        var user = userRepository.findByEmail(request.getEmail())
                .orElse(null);

        if (user != null) {
            String token = UUID.randomUUID().toString();
            PasswordResetToken resetToken = passwordResetTokenRepository.findByUser(user)
                    .orElse(new PasswordResetToken());
            
            resetToken.setToken(token);
            resetToken.setUser(user);
            resetToken.setExpiryDate(java.time.LocalDateTime.now().plusHours(1));
            passwordResetTokenRepository.save(resetToken);

            String resetLink = "http://localhost:52552/#/reset-password?token=" + token;
            emailService.sendEmail(user.getEmail(), "Réinitialisation de mot de passe", 
                "Cliquez sur ce lien pour réinitialiser votre mot de passe : " + resetLink); 
        }
        // Silently return even if user not found for security
    }

    public void resetPassword(ResetPasswordRequest request) {
        if (!request.getNewPassword().equals(request.getConfirmationPassword())) {
            throw new RuntimeException("Les mots de passe ne correspondent pas");
        }
        
        var resetToken = passwordResetTokenRepository.findByToken(request.getToken())
                .orElseThrow(() -> new RuntimeException("Token de réinitialisation invalide"));

        if (resetToken.isExpired()) {
            throw new RuntimeException("Le token a expiré");
        }

        var user = resetToken.getUser();
        user.setPassword(passwordEncoder.encode(request.getNewPassword()));
        userRepository.save(user);
        passwordResetTokenRepository.delete(resetToken);
    }

    public void verifyEmail(String token) {
        var user = userRepository.findByVerificationToken(token)
                .orElseThrow(() -> new RuntimeException("Invalid verification token"));
        
        if (user.getVerificationTokenExpiry() != null && 
            user.getVerificationTokenExpiry().isBefore(java.time.LocalDateTime.now())) {
            throw new RuntimeException("Verification token expired");
        }
        
        user.setEnabled(true);
        user.setVerificationToken(null);
        user.setVerificationTokenExpiry(null);
        userRepository.save(user);
    }

    public void resendVerificationEmail(String email) {
        var user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));
        
        if (user.isEnabled()) {
            throw new RuntimeException("Email already verified");
        }
        
        // Generate new token
        String newToken = UUID.randomUUID().toString();
        user.setVerificationToken(newToken);
        user.setVerificationTokenExpiry(java.time.LocalDateTime.now().plusHours(24));
        userRepository.save(user);
        
        // Send email
        String verificationLink = "http://localhost:52552/#/verify-email?token=" + newToken;
        emailService.sendEmail(user.getEmail(), "Verify your email", 
            "<h1>Email Verification</h1><p>Click <a href='" + verificationLink + "'>here</a> to verify your email.</p>");
    }
}
