package com.esprit.examen.dto.request;

import javax.validation.constraints.Email;
import javax.validation.constraints.NotBlank;
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
public class RegisterRequest {

    @NotBlank(message = "Le prénom est requis")
    @Size(min = 2, max = 50, message = "2 à 50 caractères")
    @Pattern(regexp = "^[a-zA-ZÀ-ÿ\\s-']+$", message = "Caractères alphabétiques uniquement")
    private String firstName;

    @NotBlank(message = "Le nom est requis")
    @Size(min = 2, max = 50, message = "2 à 50 caractères")
    @Pattern(regexp = "^[a-zA-ZÀ-ÿ\\s-']+$", message = "Caractères alphabétiques uniquement")
    private String lastName;

    @NotBlank(message = "L'email est requis")
    @Email(message = "L'email doit être valide")
    @Pattern(regexp = "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$")
    private String email;

    @NotBlank(message = "Le mot de passe est requis")
    @Size(min = 8, max = 100, message = "8 à 100 caractères")
    @Pattern(regexp = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*?&])[A-Za-z\\d@$!%*?&]{8,}$",
             message = "Doit contenir une majuscule, une minuscule, un chiffre et un caractère spécial")
    private String password;

    private String role;
}
