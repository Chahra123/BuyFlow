package com.esprit.examen.controllers;

import com.esprit.examen.entities.Fournisseur;
import com.esprit.examen.services.IFournisseurService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;


@RestController
@CrossOrigin("*")
@RequiredArgsConstructor
public class FournisseurController {

    private final IFournisseurService fournisseurService;

    @GetMapping("/fournisseurs")
    public List<Fournisseur> getFournisseurs() {
        return fournisseurService.retrieveAllFournisseurs();
    }

    @GetMapping("/{fournisseur-id}")
    public Fournisseur retrieveFournisseur(@PathVariable("fournisseur-id") Long fournisseurId) {
        return fournisseurService.retrieveFournisseur(fournisseurId);
    }

    @PostMapping("/fournisseurs")
    public Fournisseur addFournisseur(@RequestBody Fournisseur f) {
        Fournisseur fournisseur = fournisseurService.addFournisseur(f);
        return fournisseur;
    }

    @DeleteMapping("/fournisseur/{fournisseur-id}")
    public void removeFournisseur(@PathVariable("fournisseur-id") Long fournisseurId) {
        fournisseurService.deleteFournisseur(fournisseurId);
    }

    @PutMapping("/fournisseurs")
    public Fournisseur modifyFournisseur(@RequestBody Fournisseur fournisseur) {
        return fournisseurService.updateFournisseur(fournisseur);
    }

    @PutMapping(value = "/assignSecteurActiviteToFournisseur/{idSecteurActivite}/{idFournisseur}")
    public void assignSecteurActiviteToFournisseur(@PathVariable("idSecteurActivite") Long idSecteurActivite, @PathVariable("idFournisseur") Long idFournisseur) {
        fournisseurService.assignSecteurActiviteToFournisseur(idSecteurActivite, idFournisseur);
    }

}
