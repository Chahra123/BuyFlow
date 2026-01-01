package com.esprit.examen.config;

import com.esprit.examen.entities.Role;
import com.esprit.examen.entities.User;
import com.esprit.examen.repositories.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.password.PasswordEncoder;

@Configuration
@RequiredArgsConstructor
@Slf4j
public class DataInitializer {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    @Bean
    public CommandLineRunner initAdmin() {
        return args -> {
            String adminEmail = "admin@buyflow.com";
            if (!userRepository.existsByEmail(adminEmail)) {
                User admin = User.builder()
                        .firstName("Admin")
                        .lastName("BuyFlow")
                        .email(adminEmail)
                        .password(passwordEncoder.encode("Admin123!"))
                        .role(Role.ADMIN)
                        .enabled(true)
                        .provider(User.Provider.LOCAL)
                        .build();
                userRepository.save(admin);
                log.info("Default admin user created: {}", adminEmail);
            } else {
                log.info("Admin user already exists.");
            }
        };
    }
}
