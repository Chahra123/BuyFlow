package com.esprit.examen.repositories;

import com.esprit.examen.entities.Livraison;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface LivraisonRepository extends JpaRepository<Livraison, Long> {
    Optional<Livraison> findByQrToken(String qrToken);
    Optional<Livraison> findByCommande_IdCommande(Long commandeId);
}
