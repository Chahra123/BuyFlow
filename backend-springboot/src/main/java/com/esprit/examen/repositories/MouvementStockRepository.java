package com.esprit.examen.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import com.esprit.examen.entities.MouvementStock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

@Repository
public interface MouvementStockRepository extends JpaRepository<MouvementStock, Long> {

    @Query(
            "SELECT COALESCE(" +
                    "SUM(CASE WHEN m.type = 'ENTREE' THEN m.quantite ELSE -m.quantite END), 0) " +
                    "FROM MouvementStock m " +
                    "WHERE m.produit.idProduit = :produitId"
    )
    Integer calculerQuantiteProduit(@Param("produitId") Long produitId);
}
