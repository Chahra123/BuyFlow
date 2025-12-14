package com.esprit.examen.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class ProduitDTO {
    private Long idProduit;
    private String codeProduit;
    private String libelleProduit;
    private float prix;
    private String dateCreation;
    private String dateDerniereModification;
    private Long idStock;
    private String libelleStock;
}
