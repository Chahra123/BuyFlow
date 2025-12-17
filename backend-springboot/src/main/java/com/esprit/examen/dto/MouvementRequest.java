package com.esprit.examen.dto;

import com.esprit.examen.entities.TypeMouvement;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class MouvementRequest {
    private Long produitId;
    private Integer quantite;
    private TypeMouvement type;
}