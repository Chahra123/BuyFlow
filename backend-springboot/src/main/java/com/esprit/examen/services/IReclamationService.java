package com.esprit.examen.services;

import com.esprit.examen.dto.CreateReclamationRequest;
import com.esprit.examen.entities.Reclamation;
import com.esprit.examen.entities.ReclamationStatus;

import java.util.List;

public interface IReclamationService {
    Reclamation create(CreateReclamationRequest request);
    List<Reclamation> listByOperateur(Long operateurId);
    List<Reclamation> listByCommande(Long commandeId);
    Reclamation updateStatus(Long reclamationId, ReclamationStatus status);
}
