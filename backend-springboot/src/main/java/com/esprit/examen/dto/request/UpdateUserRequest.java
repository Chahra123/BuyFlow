package com.esprit.examen.dto.request;

import com.esprit.examen.entities.Role;
import javax.validation.constraints.Email;
import javax.validation.constraints.Pattern;
import javax.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class UpdateUserRequest {

    @Size(min = 2, max = 50, message = "2-50 characters")
    @Pattern(regexp = "^[a-zA-ZÀ-ÿ\\s-']+$", message = "Alphabetic characters only")
    private String firstName;

    @Size(min = 2, max = 50, message = "2-50 characters")
    @Pattern(regexp = "^[a-zA-ZÀ-ÿ\\s-']+$", message = "Alphabetic characters only")
    private String lastName;

    @Email(message = "Email should be valid")
    @Pattern(regexp = "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$")
    private String email;

    private Role role;
    
    private Boolean enabled;
    
    private String avatarUrl;
}
