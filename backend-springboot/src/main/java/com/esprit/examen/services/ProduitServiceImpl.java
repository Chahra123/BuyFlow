package com.esprit.examen.services;

import java.util.ArrayList;
import java.util.List;
import javax.transaction.Transactional;
import com.esprit.examen.entities.CategorieProduit;
import com.esprit.examen.dto.ProduitDTO;
import com.esprit.examen.entities.TypeMouvement;
import com.esprit.examen.repositories.MouvementStockRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.esprit.examen.entities.Produit;
import com.esprit.examen.entities.Stock;
import com.esprit.examen.repositories.ProduitRepository;
import com.esprit.examen.repositories.StockRepository;
import com.esprit.examen.repositories.CategorieProduitRepository;
import lombok.extern.slf4j.Slf4j;
import com.esprit.examen.entities.MouvementStock;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import org.springframework.web.multipart.MultipartFile;



@Service
@Slf4j
public class ProduitServiceImpl implements IProduitService {

    @Autowired
    ProduitRepository produitRepository;
    @Autowired
    StockRepository stockRepository;
    @Autowired
    private CategorieProduitRepository categorieProduitRepository;


    @Autowired
    MouvementStockRepository mouvementStockRepository;

    @Autowired
    StockServiceImpl stockService;

    @Autowired
    MouvementStockServiceImpl mouvementStockService;

    @Override
    public List<Produit> retrieveAllProduits() {
        List<Produit> produits = (List<Produit>) produitRepository.findAll();
        for (Produit produit : produits) {
            log.info(" Produit : " + produit);
        }
        return produits;
    }

    @Transactional
    public Produit addProduit(Produit p) {

        if (p.getCategorieProduit() != null && p.getCategorieProduit().getIdCategorieProduit() != null) {
            CategorieProduit categorie = categorieProduitRepository
                    .findById(p.getCategorieProduit().getIdCategorieProduit())
                    .orElseThrow(() -> new RuntimeException("Catégorie introuvable"));

            p.setCategorieProduit(categorie);
        }

        produitRepository.save(p);
        return p;
    }


//	@Override
//	public void deleteProduit(Long produitId) {
//		produitRepository.deleteById(produitId);
//	}

    @Transactional
    @Override
    public void deleteProduit(Long idProduit) {
        Produit produit = produitRepository.findById(idProduit).orElseThrow(() -> new RuntimeException("Produit non trouvé"));

        int quantiteActuelle = produit.getMouvements().stream().mapToInt(m -> m.getType() == TypeMouvement.ENTREE ? m.getQuantite() : -m.getQuantite()).sum();

        if (quantiteActuelle > 0) {
            throw new RuntimeException("Impossible de supprimer un produit dont la quantité actuelle dans le stock est > 0");
        }

        // Supprimer tous les mouvements associés
        mouvementStockRepository.deleteAll(produit.getMouvements());

        produitRepository.delete(produit);
    }


    @Override
    @Transactional
    public Produit updateProduit(Produit p) {

        Produit existing = produitRepository.findById(p.getIdProduit())
                .orElseThrow(() -> new RuntimeException("Produit introuvable"));

        // Champs simples
        existing.setCodeProduit(p.getCodeProduit());
        existing.setLibelleProduit(p.getLibelleProduit());
        existing.setPrix(p.getPrix());

        // Catégorie (si fournie)
        if (p.getCategorieProduit() != null && p.getCategorieProduit().getIdCategorieProduit() != null) {
            CategorieProduit categorie = categorieProduitRepository
                    .findById(p.getCategorieProduit().getIdCategorieProduit())
                    .orElseThrow(() -> new RuntimeException("Catégorie introuvable"));
            existing.setCategorieProduit(categorie);
        }

        // ⚠️ IMPORTANT : on NE TOUCHE PAS au stock ici
        // Le stock est géré EXCLUSIVEMENT par assignProduitToStock

        return produitRepository.save(existing);
    }



    @Override
    public Produit retrieveProduit(Long produitId) {
        Produit produit = produitRepository.findById(produitId).orElse(null);
        log.info("produit :" + produit);
        return produit;
    }

    @Override
    public void assignProduitToStock(Long idProduit, Long idStock) {
        Produit p = retrieveProduit(idProduit);
        Stock s = stockService.retrieveStock(idStock);
        p.setQteMin(s.getQteMin());
        p.setStock(s);
        updateProduit(p);
    }

    @Override
    public List<Produit> getProduitsByStock(Long idStock) {
        return produitRepository.findByStock_IdStock(idStock);

    }

    @Override
    public ProduitDTO toDTO(Produit p) {
        return new ProduitDTO(
                p.getIdProduit(),
                p.getCodeProduit(),
                p.getLibelleProduit(),
                p.getPrix(),
                p.getDateCreation() != null ? p.getDateCreation().toString() : null,
                p.getDateDerniereModification() != null ? p.getDateDerniereModification().toString() : null,
                p.getStock() != null ? p.getStock().getIdStock() : null,
                p.getStock() != null ? p.getStock().getLibelleStock() : null,
                p.getCategorieProduit() != null ? p.getCategorieProduit().getIdCategorieProduit() : null,
                p.getCategorieProduit() != null ? p.getCategorieProduit().getLibelleCategorie() : null
        );

    }

    public void removeProduitFromStock(Long idProduit) {
        Produit produit = produitRepository.findById(idProduit).orElseThrow(() -> new RuntimeException("Produit non trouvé"));
        produit.setStock(null);
        produitRepository.save(produit);
    }

    @Override
    public Integer getQuantiteProduit(Long produitId) {
        return mouvementStockRepository.calculerQuantiteProduit(produitId);
    }

  @Override
    public void assignProduitToStock(Long idProduit, Long idStock, Integer qteInitiale) {
        Produit p = retrieveProduit(idProduit);
        Stock s = stockService.retrieveStock(idStock);
        p.setQteMin(s.getQteMin());
        p.setStock(s);
        updateProduit(p);
        if (qteInitiale > 0) {
            mouvementStockService.effectuerMouvement(idProduit, qteInitiale, TypeMouvement.ENTREE, "Assignation initiale", "admin");
        }
    }

    @Override
    public List<MouvementStock> getMouvementsProduit(Long idProduit) {
        Produit p = retrieveProduit(idProduit);
        return new ArrayList<>(p.getMouvements());
    }

    @Override
    public Produit uploadImage(Long produitId, MultipartFile file) {

        Produit produit = produitRepository.findById(produitId)
                .orElseThrow(() -> new RuntimeException("Produit non trouvé"));

        if (file == null || file.isEmpty()) {
            throw new RuntimeException("Fichier image manquant");
        }

        String contentType = file.getContentType();
        if (contentType == null ||
                (!contentType.equals("image/png") && !contentType.equals("image/jpeg"))) {
            throw new RuntimeException("Format image non supporté");
        }

        String extension = contentType.equals("image/png") ? "png" : "jpg";
        String fileName = "produit-" + produitId + "." + extension;

        try {
            Path uploadPath = Paths.get("uploads/products");
            if (!Files.exists(uploadPath)) {
                Files.createDirectories(uploadPath);
            }

            Path filePath = uploadPath.resolve(fileName);
            Files.copy(file.getInputStream(), filePath, StandardCopyOption.REPLACE_EXISTING);

            produit.setImageUrl("/uploads/products/" + fileName);
            return produitRepository.save(produit);

        } catch (IOException e) {
            throw new RuntimeException("Erreur lors de l'upload de l'image", e);
        }
    }


}
