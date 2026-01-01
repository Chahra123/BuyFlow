package com.esprit.examen.security;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.esprit.examen.dto.response.AuthenticationResponse;
import com.esprit.examen.entities.User;
import com.esprit.examen.repositories.TokenRepository;
import com.esprit.examen.repositories.UserRepository;
import com.esprit.examen.services.JwtService;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.security.web.authentication.SimpleUrlAuthenticationSuccessHandler;
import org.springframework.stereotype.Component;

import java.io.IOException;
import com.esprit.examen.entities.Role;
import com.esprit.examen.entities.Token;

@Component
@RequiredArgsConstructor
public class OAuth2LoginSuccessHandler extends SimpleUrlAuthenticationSuccessHandler {

    private final JwtService jwtService;
    private final UserRepository userRepository;
    private final TokenRepository tokenRepository;

    @Override
    public void onAuthenticationSuccess(HttpServletRequest request, HttpServletResponse response,
                                        Authentication authentication) throws IOException, ServletException {
        OAuth2User oAuth2User = (OAuth2User) authentication.getPrincipal();
        String email = oAuth2User.getAttribute("email");
        String firstName = oAuth2User.getAttribute("given_name");
        String lastName = oAuth2User.getAttribute("family_name");
        
        User user = userRepository.findByEmail(email).orElseGet(() -> {
            User newUser = User.builder()
                    .firstName(firstName != null ? firstName : "User")
                    .lastName(lastName != null ? lastName : "")
                    .email(email)
                    .provider(User.Provider.GOOGLE)
                    .providerId(oAuth2User.getName()) // Google ID
                    .role(Role.USER)
                    .enabled(true) // OAuth users are verified by provider
                    .build();
            return userRepository.save(newUser);
        });

        // Update basic info if changed (optional)
        // Check provider? If LOCAL, might block or link accounts. Assuming auto-link or trust email.
        
        String jwtToken = jwtService.generateToken(user);
        String refreshToken = jwtService.generateRefreshToken(user);
        
        saveUserToken(user, jwtToken);

        AuthenticationResponse authResponse = AuthenticationResponse.builder()
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

        // Redirect to frontend with tokens in URL
        // In a real app, this should be configurable (e.g. from environment or request state)
        // For development, we redirect to localhost:5000 (common for dev) or similar
        String targetUrl = "http://localhost:52552/#/auth-callback" + 
                           "?accessToken=" + jwtToken + 
                           "&refreshToken=" + refreshToken;
        
        getRedirectStrategy().sendRedirect(request, response, targetUrl);
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
}
