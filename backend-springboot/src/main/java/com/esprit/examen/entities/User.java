package com.esprit.examen.entities;

import javax.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.SQLDelete;
import org.hibernate.annotations.Where;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.time.LocalDateTime;
import java.util.Collection;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "_user") // 'user' is a reserved keyword in some DBs
@SQLDelete(sql = "UPDATE _user SET deleted = true WHERE id = ?")
@Where(clause = "deleted = false")
public class User implements UserDetails {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String firstName;
    private String lastName;

    @Column(unique = true, nullable = false)
    private String email;

    @com.fasterxml.jackson.annotation.JsonIgnore
    private String password; // Nullable for OAuth2 users

    @Enumerated(EnumType.STRING)
    private Role role;

    private boolean enabled;
    
    @Builder.Default
    private boolean deleted = false;

    // For Email Verification
    private String verificationToken;
    private LocalDateTime verificationTokenExpiry;

    // For OAuth2
    @Enumerated(EnumType.STRING)
    private Provider provider;
    private String providerId;

    // Profile Picture URL
    private String avatarUrl;

    // Password Reset (Relationship)
    @com.fasterxml.jackson.annotation.JsonIgnore
    @OneToOne(mappedBy = "user", cascade = CascadeType.ALL)
    private PasswordResetToken passwordResetToken;

    // Account Audit
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public enum Provider {
        LOCAL, GOOGLE
    }

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
        if (role == null)
            role = Role.USER;
        if (provider == null)
            provider = Provider.LOCAL;
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return List.of(new SimpleGrantedAuthority("ROLE_" + role.name()));
    }

    @Override
    public String getUsername() {
        return email;
    }

    @Override
    public boolean isAccountNonExpired() {
        return true;
    }

    @Override
    public boolean isAccountNonLocked() {
        return true;
    }

    @Override
    public boolean isCredentialsNonExpired() {
        return true;
    }

    @Override
    public boolean isEnabled() {
        return enabled;
    }
}
