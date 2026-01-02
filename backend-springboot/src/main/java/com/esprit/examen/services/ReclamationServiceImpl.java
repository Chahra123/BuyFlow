package com.esprit.examen.services;

import com.esprit.examen.dto.CreateReclamationRequest;
import com.esprit.examen.entities.*;
import com.esprit.examen.repositories.CommandeRepository;
import com.esprit.examen.repositories.OperateurRepository;
import com.esprit.examen.repositories.ReclamationRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import javax.transaction.Transactional;
import java.time.Instant;
import java.util.List;

@Service
@RequiredArgsConstructor
public class ReclamationServiceImpl implements IReclamationService {

    private final ReclamationRepository reclamationRepository;
    private final OperateurRepository operateurRepository;
    private final CommandeRepository commandeRepository;

    @Override
    @Transactional
    public Reclamation create(CreateReclamationRequest request) {
        Operateur op = operateurRepository.findById(request.getOperateurId())
                .orElseThrow(() -> new IllegalArgumentException("Operateur introuvable"));
        Commande commande = commandeRepository.findById(request.getCommandeId())
                .orElseThrow(() -> new IllegalArgumentException("Commande introuvable"));

        Reclamation r = new Reclamation();
        r.setOperateur(op);
        r.setCommande(commande);
        r.setObjet(request.getObjet());
        r.setDescription(request.getDescription());
        r.setStatus(ReclamationStatus.OUVERT);
        r.setCreatedAt(Instant.now());
        r.setUpdatedAt(Instant.now());

        return reclamationRepository.save(r);
    }

    @Override
    public List<Reclamation> listByOperateur(Long operateurId) {
        return reclamationRepository.findByOperateur_IdOperateurOrderByCreatedAtDesc(operateurId);
    }

    @Override
    public List<Reclamation> listByCommande(Long commandeId) {
        return reclamationRepository.findByCommande_IdCommandeOrderByCreatedAtDesc(commandeId);
    }

    @Override
    @Transactional
    public Reclamation updateStatus(Long reclamationId, ReclamationStatus status) {
        Reclamation r = reclamationRepository.findById(reclamationId)
                .orElseThrow(() -> new IllegalArgumentException("Reclamation introuvable"));
        r.setStatus(status);
        r.setUpdatedAt(Instant.now());
        return reclamationRepository.save(r);
    }
}
