package com.esprit.examen.repositories;

import com.esprit.examen.entities.Commande;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface CommandeRepository extends JpaRepository<Commande, Long> {
    List<Commande> findByOperateur_IdOperateurOrderByCreatedAtDesc(Long operateurId);
}
