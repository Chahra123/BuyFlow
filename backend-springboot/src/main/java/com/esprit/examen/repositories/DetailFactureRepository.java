package com.esprit.examen.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import com.esprit.examen.entities.DetailFacture;

import org.springframework.stereotype.Repository;

@Repository
public interface DetailFactureRepository extends JpaRepository<DetailFacture, Long> {
    boolean existsByProduit_IdProduit(Long idProduit);
}
