package com.esprit.examen.services;

import com.esprit.examen.entities.MouvementStock;
import com.esprit.examen.entities.TypeMouvement;

public interface IMouvementStockService {

    public MouvementStock effectuerMouvement(Long produitId, Integer quantite, TypeMouvement type, String raison, String utilisateur);
}
