package com.esprit.examen.services;

import com.esprit.examen.dto.UpdateLivraisonStatusRequest;
import com.esprit.examen.entities.Livraison;
import com.esprit.examen.entities.Operateur;
import com.esprit.examen.repositories.LivraisonRepository;
import com.esprit.examen.repositories.OperateurRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import javax.transaction.Transactional;
import java.time.Instant;
import java.util.List;

@Service
@RequiredArgsConstructor
public class LivraisonServiceImpl implements ILivraisonService {

    private final LivraisonRepository livraisonRepository;
    private final OperateurRepository operateurRepository;

    @Override
    public List<Livraison> listAll() {
        return livraisonRepository.findAll();
    }

    @Override
    @Transactional
    public Livraison updateStatus(UpdateLivraisonStatusRequest request) {
        Livraison livraison = livraisonRepository.findByQrToken(request.getQrToken())
                .orElseThrow(() -> new IllegalArgumentException("QR invalide"));

        livraison.setStatus(request.getStatus());
        livraison.setUpdatedAt(Instant.now());

        if (request.getUpdatedByOperateurId() != null) {
            Operateur op = operateurRepository.findById(request.getUpdatedByOperateurId())
                    .orElse(null);
            livraison.setLastUpdatedBy(op);
        }

        return livraisonRepository.save(livraison);
    }

    @Override
    public Livraison getById(Long id) {
        return livraisonRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Livraison introuvable"));
    }
}
