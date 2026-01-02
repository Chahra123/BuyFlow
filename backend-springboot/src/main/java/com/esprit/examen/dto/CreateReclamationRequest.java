package com.esprit.examen.dto;

import lombok.Getter;
import lombok.Setter;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;

@Getter
@Setter
public class CreateReclamationRequest {
    @NotNull
    private Long operateurId;

    @NotNull
    private Long commandeId;

    @NotBlank
    private String objet;

    @NotBlank
    private String description;
}
