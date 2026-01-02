package com.esprit.examen.controllers;

import com.esprit.examen.dto.CreateReclamationRequest;
import com.esprit.examen.entities.Reclamation;
import com.esprit.examen.entities.ReclamationStatus;
import com.esprit.examen.services.IReclamationService;
import lombok.RequiredArgsConstructor;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;
import java.util.List;

@RestController
@CrossOrigin("*")
@RequestMapping("/reclamations")
@RequiredArgsConstructor
@Validated
public class ReclamationController {

    private final IReclamationService reclamationService;

    @PostMapping
    public Reclamation create(@Valid @RequestBody CreateReclamationRequest request) {
        return reclamationService.create(request);
    }

    @GetMapping
    public List<Reclamation> list(@RequestParam(required = false) Long operateurId,
                                  @RequestParam(required = false) Long commandeId) {
        if (commandeId != null) return reclamationService.listByCommande(commandeId);
        if (operateurId != null) return reclamationService.listByOperateur(operateurId);
        throw new IllegalArgumentException("operateurId ou commandeId requis");
    }

    @PutMapping("/{id}/status")
    public Reclamation updateStatus(@PathVariable Long id, @RequestParam ReclamationStatus status) {
        return reclamationService.updateStatus(id, status);
    }
}
