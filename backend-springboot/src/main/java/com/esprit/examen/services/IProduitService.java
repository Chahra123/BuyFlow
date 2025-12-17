package com.esprit.examen.services;

import java.util.List;

import com.esprit.examen.dto.ProduitDTO;
import com.esprit.examen.entities.MouvementStock;
import com.esprit.examen.entities.Produit;

public interface IProduitService {

	List<Produit> retrieveAllProduits();

	Produit addProduit(Produit p);

	void deleteProduit(Long id);

	Produit updateProduit(Produit p);

	Produit retrieveProduit(Long id);

	void assignProduitToStock(Long idProduit, Long idStock);

    public void assignProduitToStock(Long idProduit, Long idStock, Integer qteInitiale);

    List<Produit> getProduitsByStock(Long idStock);

	ProduitDTO toDTO(Produit p);

	void removeProduitFromStock(Long idProduit);

	Integer getQuantiteProduit(Long produitId);

    List<MouvementStock> getMouvementsProduit(Long idProduit);
}
