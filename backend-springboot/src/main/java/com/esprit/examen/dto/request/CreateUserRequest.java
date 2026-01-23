package com.esprit.examen.dto.request;

import com.esprit.examen.entities.Role;
import javax.validation.constraints.Email;
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;
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
public class CreateUserRequest {

    @NotBlank(message = "First name is required")
    @Size(min = 2, max = 50, message = "2-50 characters")
    @Pattern(regexp = "^[a-zA-ZÀ-ÿ\\s-']+$", message = "Alphabetic characters only")
    private String firstName;

    @NotBlank(message = "Last name is required")
    @Size(min = 2, max = 50, message = "2-50 characters")
    @Pattern(regexp = "^[a-zA-ZÀ-ÿ\\s-']+$", message = "Alphabetic characters only")
    private String lastName;

    @NotBlank(message = "Email is required")
    @Email(message = "Email should be valid")
    @Pattern(regexp = "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$")
    private String email;

    @NotNull(message = "Role is required")
    private Role role;
    
    private String password; // Optional: Admin can set or auto-generate
}
