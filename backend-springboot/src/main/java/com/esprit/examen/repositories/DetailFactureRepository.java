package com.esprit.examen.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import com.esprit.examen.entities.DetailFacture;


public interface DetailFactureRepository extends JpaRepository<DetailFacture, Long> {

}
