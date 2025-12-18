package com.esprit.examen.dto;

import com.esprit.examen.entities.TypeMouvement;
import lombok.Data;

import javax.persistence.EnumType;
import javax.persistence.Enumerated;

@Data
public class MouvementRequest {
    private Long produitId;
    private Integer quantite;
    @Enumerated(EnumType.STRING)
    private TypeMouvement type;
    private String raison;
    private String utilisateur;
}