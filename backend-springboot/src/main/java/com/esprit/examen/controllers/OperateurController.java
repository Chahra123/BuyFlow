package com.esprit.examen.controllers;

import com.esprit.examen.entities.Operateur;
import com.esprit.examen.services.IOperateurService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;


@RestController
@CrossOrigin("*")
@RequiredArgsConstructor
public class OperateurController {
    private final IOperateurService operateurService;

    @GetMapping("/operateurs")
    public List<Operateur> getOperateurs() {
        return operateurService.retrieveAllOperateurs();
    }

    @GetMapping("/{operateur-id}")
    public Operateur retrieveOperateur(@PathVariable("operateur-id") Long operateurId) {
        return operateurService.retrieveOperateur(operateurId);
    }

    @PostMapping("/operateurs")
    public Operateur addOperateur(@RequestBody Operateur op) {
        Operateur operateur = operateurService.addOperateur(op);
        System.out.println("***************TEST CONFLITS *****************");
        System.out.println("OPERATEUR:"+op);
        return operateur;
    }


    @DeleteMapping("/operateur/{operateur-id}")
    public void removeOperateur(@PathVariable("operateur-id") Long operateurId) {
        operateurService.deleteOperateur(operateurId);
    }


    @PutMapping("/operateurs")
    public Operateur modifyOperateur(@RequestBody Operateur operateur) {
        return operateurService.updateOperateur(operateur);
    }
}
