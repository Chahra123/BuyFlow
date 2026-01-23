package com.esprit.examen.repositories;

import com.esprit.examen.entities.Favorite;
import com.esprit.examen.entities.User;
import com.esprit.examen.entities.Produit;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface FavoriteRepository extends JpaRepository<Favorite, Long> {

    boolean existsByUserAndProduit(User user, Produit produit);

    Optional<Favorite> findByUserAndProduit(User user, Produit produit);

    List<Favorite> findByUser(User user);
}
