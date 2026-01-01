package com.esprit.examen.dto.request;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class AuthenticationRequest {
    @javax.validation.constraints.NotBlank(message = "Email requis")
    @javax.validation.constraints.Email(message = "Format email invalide")
    private String email;

    @javax.validation.constraints.NotBlank(message = "Mot de passe requis")
    private String password;
}
