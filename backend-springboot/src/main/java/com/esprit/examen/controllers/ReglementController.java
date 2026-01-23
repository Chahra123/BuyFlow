package com.esprit.examen.controllers;

import com.esprit.examen.entities.Reglement;
import com.esprit.examen.services.IReglementService;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.*;

import java.util.Date;
import java.util.List;

@RestController
@CrossOrigin("*")
@RequiredArgsConstructor
public class ReglementController {
    private final IReglementService reglementService;

    @GetMapping(value = "/getChiffreAffaireEntreDeuxDate/{startDate}/{endDate}")
    public float getChiffreAffaireEntreDeuxDate(@PathVariable(name = "startDate") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) Date startDate, @PathVariable(name = "endDate") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) Date endDate) {
        try {
            return reglementService.getChiffreAffaireEntreDeuxDate(startDate, endDate);
        } catch (Exception e) {
            return 0;
        }
    }

    @GetMapping("/retrieveReglementByFacture/{facture-id}")
    @ResponseBody
    public List<Reglement> retrieveReglementByFacture(@PathVariable("facture-id") Long factureId) {
        return reglementService.retrieveReglementByFacture(factureId);
    }

    @GetMapping("/retrieve-reglement/{reglement-id}")
    @ResponseBody
    public Reglement retrieveReglement(@PathVariable("reglement-id") Long reglementId) {
        return reglementService.retrieveReglement(reglementId);
    }

    @GetMapping("/retrieve-all-reglements")
    @ResponseBody
    public List<Reglement> getReglement() {
        List<Reglement> list = reglementService.retrieveAllReglements();
        return list;
    }

    @PostMapping("/add-reglement")
    @ResponseBody
    public Reglement addReglement(@RequestBody Reglement r) {
        Reglement reglement = reglementService.addReglement(r);
        return reglement;
    }
}
