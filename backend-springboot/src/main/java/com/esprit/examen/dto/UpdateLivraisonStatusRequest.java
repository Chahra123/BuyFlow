package com.esprit.examen.dto;

import com.esprit.examen.entities.LivraisonStatus;
import lombok.Getter;
import lombok.Setter;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;

@Getter
@Setter
public class UpdateLivraisonStatusRequest {
    @NotBlank
    private String qrToken;

    @NotNull
    private LivraisonStatus status;

    private Long updatedByOperateurId;
}
