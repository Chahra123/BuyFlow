package com.esprit.examen.controllers;

import com.esprit.examen.entities.CategorieProduit;
import com.esprit.examen.services.ICategorieProduitService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@CrossOrigin("*")
@RequiredArgsConstructor
public class CategorieProduitController {
    private final ICategorieProduitService categorieProduitService;

    @GetMapping("/categories")
    public List<CategorieProduit> getCategorieProduit() {
        List<CategorieProduit> list = categorieProduitService.retrieveAllCategorieProduits();
        return list;
    }

    @PostMapping("/categories")
    public CategorieProduit addCategorieProduit(@RequestBody CategorieProduit cp) {
        CategorieProduit categorieProduit = categorieProduitService.addCategorieProduit(cp);
        return categorieProduit;
    }

    @GetMapping("/{categorieProduit-id}")
    public CategorieProduit retrieveCategorieProduit(@PathVariable("categorieProduit-id") Long categorieProduitId) {
        return categorieProduitService.retrieveCategorieProduit(categorieProduitId);
    }

    @DeleteMapping("/categorieproduit/{categorieProduit-id}")
    public void removeCategorieProduit(@PathVariable("categorieProduit-id") Long categorieProduitId) {
        categorieProduitService.deleteCategorieProduit(categorieProduitId);
    }

    @PutMapping("/categorie-produit")
    public CategorieProduit modifyCategorieProduit(@RequestBody CategorieProduit categorieProduit) {
        return categorieProduitService.updateCategorieProduit(categorieProduit);
    }

}
