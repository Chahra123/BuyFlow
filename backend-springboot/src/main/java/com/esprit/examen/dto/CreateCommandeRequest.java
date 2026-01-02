package com.esprit.examen.dto;

import lombok.Getter;
import lombok.Setter;

import javax.validation.constraints.Min;
import javax.validation.constraints.NotNull;

@Getter
@Setter
public class CreateCommandeRequest {
    @NotNull
    private Long operateurId;

    @NotNull
    private Long produitId;

    @NotNull
    @Min(1)
    private Integer quantite;

    private String adresseLivraison;
    private Double latitude;
    private Double longitude;
}
