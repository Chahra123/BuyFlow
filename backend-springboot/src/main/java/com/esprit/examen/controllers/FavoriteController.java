package com.esprit.examen.controllers;

import com.esprit.examen.entities.Produit;
import com.esprit.examen.services.FavoriteService;

import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/favorites")
@PreAuthorize("hasRole('USER')")
public class FavoriteController {

    private final FavoriteService favoriteService;

    public FavoriteController(FavoriteService favoriteService) {
        this.favoriteService = favoriteService;
    }

    /**
     * Ajouter un produit aux favoris de l'utilisateur connecté
     */
    @PostMapping("/{produitId}")
    public ResponseEntity<Void> addFavorite(
            @PathVariable Long produitId,
            @AuthenticationPrincipal UserDetails userDetails
    ) {
        favoriteService.addFavorite(produitId, userDetails.getUsername());
        return ResponseEntity.ok().build();
    }

    /**
     * Supprimer un produit des favoris de l'utilisateur connecté
     */
    @DeleteMapping("/{produitId}")
    public ResponseEntity<Void> removeFavorite(
            @PathVariable Long produitId,
            @AuthenticationPrincipal UserDetails userDetails
    ) {
        favoriteService.removeFavorite(produitId, userDetails.getUsername());
        return ResponseEntity.noContent().build();
    }

    /**
     * Récupérer la liste des produits favoris de l'utilisateur connecté
     */
    @GetMapping
    public ResponseEntity<List<Produit>> getFavorites(
            @AuthenticationPrincipal UserDetails userDetails
    ) {
        List<Produit> favorites =
                favoriteService.getFavorites(userDetails.getUsername());
        return ResponseEntity.ok(favorites);
    }
}
