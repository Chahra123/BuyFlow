package com.esprit.examen.services;

import com.esprit.examen.entities.Favorite;
import com.esprit.examen.entities.Produit;
import com.esprit.examen.entities.User;
import com.esprit.examen.repositories.FavoriteRepository;
import com.esprit.examen.repositories.ProduitRepository;
import com.esprit.examen.repositories.UserRepository;

import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class FavoriteService {

    private final FavoriteRepository favoriteRepository;
    private final ProduitRepository produitRepository;
    private final UserRepository userRepository;

    public FavoriteService(
            FavoriteRepository favoriteRepository,
            ProduitRepository produitRepository,
            UserRepository userRepository
    ) {
        this.favoriteRepository = favoriteRepository;
        this.produitRepository = produitRepository;
        this.userRepository = userRepository;
    }

    /**
     * Ajoute un produit aux favoris de l'utilisateur connecté.
     * Si le favori existe déjà, on ne fait rien (idempotent).
     */
    public void addFavorite(Long produitId, String userEmail) {

        User user = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new RuntimeException("User not found"));

        Produit produit = produitRepository.findById(produitId)
                .orElseThrow(() -> new RuntimeException("Produit not found"));

        boolean alreadyExists =
                favoriteRepository.existsByUserAndProduit(user, produit);

        if (alreadyExists) {
            return;
        }

        Favorite favorite = new Favorite();
        favorite.setUser(user);
        favorite.setProduit(produit);

        favoriteRepository.save(favorite);
    }

    /**
     * Supprime un produit des favoris de l'utilisateur connecté.
     * Si le favori n'existe pas, on ne fait rien.
     */
    public void removeFavorite(Long produitId, String userEmail) {

        User user = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new RuntimeException("User not found"));

        Produit produit = produitRepository.findById(produitId)
                .orElseThrow(() -> new RuntimeException("Produit not found"));

        Optional<Favorite> favoriteOpt =
                favoriteRepository.findByUserAndProduit(user, produit);

        favoriteOpt.ifPresent(favoriteRepository::delete);
    }

    /**
     * Retourne la liste des produits favoris de l'utilisateur connecté.
     */
    public List<Produit> getFavorites(String userEmail) {

        User user = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new RuntimeException("User not found"));

        return favoriteRepository.findByUser(user)
                .stream()
                .map(Favorite::getProduit)
                .collect(Collectors.toList());
    }
}
