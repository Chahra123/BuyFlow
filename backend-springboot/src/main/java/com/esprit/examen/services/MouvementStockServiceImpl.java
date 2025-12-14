package com.esprit.examen.services;

import com.esprit.examen.entities.MouvementStock;
import com.esprit.examen.entities.Produit;
import com.esprit.examen.entities.Stock;
import com.esprit.examen.entities.TypeMouvement;
import com.esprit.examen.repositories.MouvementStockRepository;
import com.esprit.examen.repositories.ProduitRepository;
import com.esprit.examen.repositories.StockRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class MouvementStockServiceImpl implements IMouvementStockService{

    @Autowired
    private MouvementStockRepository mouvementStockRepository;

    @Autowired
    private ProduitRepository produitRepository;

    @Autowired
    private StockRepository stockRepository;

    public MouvementStock effectuerMouvement(Long produitId, int quantite, TypeMouvement type) {
        Produit produit = produitRepository.findById(produitId)
                .orElseThrow(() -> new RuntimeException("Produit non trouvé"));

        Stock stock = produit.getStock();
        if (stock == null) {
            throw new RuntimeException("Produit non assigné à un stock");
        }

        if (type == TypeMouvement.SORTIE && stock.getQte() < quantite) {
            throw new RuntimeException("Stock insuffisant");
        }

        // Mise à jour stock
        int nouvelleQte = type == TypeMouvement.ENTREE ?
                stock.getQte() + quantite :
                stock.getQte() - quantite;
        stock.setQte(nouvelleQte);
        stockRepository.save(stock);

        // Enregistrement mouvement
        MouvementStock mouvement = new MouvementStock();
        mouvement.setProduit(produit);
        mouvement.setQuantite(quantite);
        mouvement.setType(type);
        return mouvementStockRepository.save(mouvement);
    }
}