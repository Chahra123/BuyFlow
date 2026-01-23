package com.esprit.examen.controllers;

import com.esprit.examen.entities.SecteurActivite;
import com.esprit.examen.services.ISecteurActiviteService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;


@RestController
@CrossOrigin("*")
@RequiredArgsConstructor
public class SecteurActiviteController {

    private final ISecteurActiviteService secteurActiviteService;

    @GetMapping("/secteurs")
    public List<SecteurActivite> getSecteurActivite() {
        return secteurActiviteService.retrieveAllSecteurActivite();
    }

    @GetMapping("/{secteurActivite-id}")
    public SecteurActivite retrieveSecteurActivite(@PathVariable("secteurActivite-id") Long secteurActiviteId) {
        return secteurActiviteService.retrieveSecteurActivite(secteurActiviteId);
    }

    @PostMapping("/secteurs")
    public SecteurActivite addSecteurActivite(@RequestBody SecteurActivite sa) {
        SecteurActivite secteurActivite = secteurActiviteService.addSecteurActivite(sa);
        return secteurActivite;
    }

    @DeleteMapping("/secteuractivite/{secteurActivite-id}")
    public void removeSecteurActivite(@PathVariable("secteurActivite-id") Long secteurActiviteId) {
        secteurActiviteService.deleteSecteurActivite(secteurActiviteId);
    }

    @PutMapping("/secteur-activite")
    public SecteurActivite modifySecteurActivite(@RequestBody SecteurActivite secteurActivite) {
        return secteurActiviteService.updateSecteurActivite(secteurActivite);
    }
}
