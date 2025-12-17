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
public class MouvementStockServiceImpl implements IMouvementStockService {

    @Autowired
    private MouvementStockRepository mouvementStockRepository;

    @Autowired
    private ProduitRepository produitRepository;

    @Override
    public MouvementStock effectuerMouvement(Long produitId, Integer quantite, TypeMouvement type, String raison, String utilisateur) {
        Produit produit = produitRepository.findById(produitId).orElseThrow(() -> new RuntimeException("Produit non trouvé"));
        if (produit.getStock() == null) {
            throw new RuntimeException("Produit non assigné à un stock");
        }
        if (type == TypeMouvement.SORTIE) {
            int qteDisponible = calculerQuantiteProduit(produit);
            if (qteDisponible < quantite) {
                throw new RuntimeException("Quantité insuffisante");
            }
        }
        MouvementStock mouvement = new MouvementStock();
        mouvement.setProduit(produit);
        mouvement.setQuantite(quantite);
        mouvement.setType(type);
        mouvement.setRaison(raison);
        mouvement.setUtilisateur(utilisateur);
        return mouvementStockRepository.save(mouvement);
    }

    public int calculerQuantiteProduit(Produit produit) {
        return produit.getMouvements().stream().mapToInt(m -> m.getType() == TypeMouvement.ENTREE ? m.getQuantite() : -m.getQuantite()).sum();
    }
}