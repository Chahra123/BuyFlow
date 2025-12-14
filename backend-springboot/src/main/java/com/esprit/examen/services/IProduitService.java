package com.esprit.examen.services;

import java.util.List;

import com.esprit.examen.dto.ProduitDTO;
import com.esprit.examen.entities.Produit;

public interface IProduitService {

	List<Produit> retrieveAllProduits();

	Produit addProduit(Produit p);

	void deleteProduit(Long id);

	Produit updateProduit(Produit p);

	Produit retrieveProduit(Long id);

	void assignProduitToStock(Long idProduit, Long idStock);

	List<Produit> getProduitsByStock(Long idStock);

	public ProduitDTO toDTO(Produit p);

	void removeProduitFromStock(Long idProduit);
}
