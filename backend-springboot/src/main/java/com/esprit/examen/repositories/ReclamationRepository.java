package com.esprit.examen.repositories;

import com.esprit.examen.entities.Reclamation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ReclamationRepository extends JpaRepository<Reclamation, Long> {
    List<Reclamation> findByOperateur_IdOperateurOrderByCreatedAtDesc(Long operateurId);
    List<Reclamation> findByCommande_IdCommandeOrderByCreatedAtDesc(Long commandeId);
}
