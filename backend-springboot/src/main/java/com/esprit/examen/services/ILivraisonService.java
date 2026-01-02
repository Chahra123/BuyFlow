package com.esprit.examen.services;

import com.esprit.examen.dto.UpdateLivraisonStatusRequest;
import com.esprit.examen.entities.Livraison;

import java.util.List;

public interface ILivraisonService {
    List<Livraison> listAll();
    Livraison updateStatus(UpdateLivraisonStatusRequest request);
    Livraison getById(Long id);
}
