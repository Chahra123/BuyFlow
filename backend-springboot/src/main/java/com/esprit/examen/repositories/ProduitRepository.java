package com.esprit.examen.repositories;


import org.springframework.data.jpa.repository.JpaRepository;
import com.esprit.examen.entities.Produit;

import java.util.List;

public interface ProduitRepository extends JpaRepository<Produit, Long> {
    List<Produit> findByStock_IdStock(Long idStock);

	/*@Query("SELECT sum(df.prixTotal) FROM DetailFacture df where df.produit=:produit and df.facture.dateFacture between :startDate"
			+ " and :endDate and df.facture.active=true")
	public float getRevenuBrutProduit(@Param("produit") Produit produit, @Param("startDate") Date startDate,
			@Param("endDate") Date endDate);*/
}
