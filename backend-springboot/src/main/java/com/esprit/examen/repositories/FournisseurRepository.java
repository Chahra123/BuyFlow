package com.esprit.examen.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import com.esprit.examen.entities.Fournisseur;

public interface FournisseurRepository extends JpaRepository<Fournisseur, Long> {

}
