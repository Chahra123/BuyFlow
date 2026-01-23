package com.esprit.examen.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
@com.fasterxml.jackson.annotation.JsonInclude(com.fasterxml.jackson.annotation.JsonInclude.Include.NON_NULL)
public class AuthenticationResponse {
    private String accessToken;
    private String refreshToken;
    private String message;
    private com.esprit.examen.dto.response.UserResponse user;
}
