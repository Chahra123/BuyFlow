package com.esprit.examen.services;

import com.esprit.examen.dto.CreateCommandeRequest;
import com.esprit.examen.entities.*;
import com.esprit.examen.repositories.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import javax.transaction.Transactional;
import java.util.List;

@Service
@RequiredArgsConstructor
public class CommandeServiceImpl implements ICommandeService {

    private final CommandeRepository commandeRepository;
    private final OperateurRepository operateurRepository;
    private final ProduitRepository produitRepository;
    private final LivraisonRepository livraisonRepository;

    @Override
    @Transactional
    public Commande createCommande(CreateCommandeRequest request) {
        Operateur op = operateurRepository.findById(request.getOperateurId())
                .orElseThrow(() -> new IllegalArgumentException("Operateur introuvable"));
        Produit produit = produitRepository.findById(request.getProduitId())
                .orElseThrow(() -> new IllegalArgumentException("Produit introuvable"));

        Commande c = new Commande();
        c.setOperateur(op);
        c.setProduit(produit);
        c.setQuantite(request.getQuantite());
        c.setAdresseLivraison(request.getAdresseLivraison());
        c.setLatitude(request.getLatitude());
        c.setLongitude(request.getLongitude());
        c.setStatus(CommandeStatus.EN_ATTENTE_CONFIRMATION);

        return commandeRepository.save(c);
    }

    @Override
    public List<Commande> getCommandesByOperateur(Long operateurId) {
        return commandeRepository.findByOperateur_IdOperateurOrderByCreatedAtDesc(operateurId);
    }

    @Override
    @Transactional
    public Commande confirmCommande(Long commandeId) {
        Commande c = getById(commandeId);
        c.setStatus(CommandeStatus.CONFIRMEE);
        Commande saved = commandeRepository.save(c);

        // Create delivery on first confirmation if not exists
        livraisonRepository.findByCommande_IdCommande(saved.getIdCommande())
                .orElseGet(() -> {
                    Livraison livraison = new Livraison();
                    livraison.setCommande(saved);
                    livraison.setStatus(LivraisonStatus.EN_ATTENTE);
                    return livraisonRepository.save(livraison);
                });
        return saved;
    }

    @Override
    public Commande cancelCommande(Long commandeId) {
        Commande c = getById(commandeId);
        c.setStatus(CommandeStatus.ANNULEE);
        return commandeRepository.save(c);
    }

    @Override
    public Commande getById(Long commandeId) {
        return commandeRepository.findById(commandeId)
                .orElseThrow(() -> new IllegalArgumentException("Commande introuvable"));
    }
}
