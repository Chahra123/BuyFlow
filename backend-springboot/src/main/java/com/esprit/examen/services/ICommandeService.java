package com.esprit.examen.services;

import com.esprit.examen.dto.CreateCommandeRequest;
import com.esprit.examen.entities.Commande;

import java.util.List;

public interface ICommandeService {
    Commande createCommande(CreateCommandeRequest request);
    List<Commande> getCommandesByOperateur(Long operateurId);
    Commande confirmCommande(Long commandeId);
    Commande cancelCommande(Long commandeId);
    Commande getById(Long commandeId);
}
