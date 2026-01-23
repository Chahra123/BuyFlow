package com.esprit.examen.dto.response;

import com.esprit.examen.entities.Role;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class UserResponse {
    private Long id;
    private String firstName;
    private String lastName;
    private String email;
    private Role role;
    private String avatarUrl;
    private boolean enabled;
    private java.time.LocalDateTime createdAt;
}
