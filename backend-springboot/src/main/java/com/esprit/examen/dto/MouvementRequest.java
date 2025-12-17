package com.esprit.examen.dto;

import com.esprit.examen.entities.TypeMouvement;
import lombok.Data;

@Data
public class MouvementRequest {
    private Long produitId;
    private Integer quantite;
    private TypeMouvement type;
    private String raison;
    private String utilisateur;
}