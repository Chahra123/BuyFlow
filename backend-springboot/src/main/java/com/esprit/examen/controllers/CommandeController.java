package com.esprit.examen.controllers;

import com.esprit.examen.dto.CreateCommandeRequest;
import com.esprit.examen.entities.Commande;
import com.esprit.examen.services.ICommandeService;
import lombok.RequiredArgsConstructor;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;
import java.util.List;

@RestController
@CrossOrigin("*")
@RequestMapping("/commandes")
@RequiredArgsConstructor
@Validated
public class CommandeController {

    private final ICommandeService commandeService;

    @PostMapping
    public Commande create(@Valid @RequestBody CreateCommandeRequest request) {
        return commandeService.createCommande(request);
    }

    @GetMapping
    public List<Commande> listByOperateur(@RequestParam("operateurId") Long operateurId) {
        return commandeService.getCommandesByOperateur(operateurId);
    }

    @PutMapping("/{id}/confirm")
    public Commande confirm(@PathVariable("id") Long id) {
        return commandeService.confirmCommande(id);
    }

    @PutMapping("/{id}/cancel")
    public Commande cancel(@PathVariable("id") Long id) {
        return commandeService.cancelCommande(id);
    }

    @GetMapping("/{id}")
    public Commande get(@PathVariable("id") Long id) {
        return commandeService.getById(id);
    }
}
