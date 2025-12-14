package com.esprit.examen.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import com.esprit.examen.entities.MouvementStock;

public interface MouvementStockRepository extends JpaRepository<MouvementStock, Long> {
}
