package com.esprit.examen.controllers;

import com.esprit.examen.dto.MouvementRequest;
import com.esprit.examen.entities.MouvementStock;
import com.esprit.examen.entities.TypeMouvement;
import com.esprit.examen.services.IMouvementStockService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@CrossOrigin("*")
@RequestMapping("/mouvements")
public class MouvementStockController {

    @Autowired
    private IMouvementStockService mouvementStockService;

    @PostMapping
    public ResponseEntity<MouvementStock> creerMouvement(@RequestBody MouvementRequest req) {
        MouvementStock m = mouvementStockService.effectuerMouvement(req.getProduitId(), req.getQuantite(),
                req.getType(), req.getRaison(), req.getUtilisateur());
        return ResponseEntity.ok(m);
    }

    @GetMapping
    public List<MouvementStock> getAllMouvements() {
        return mouvementStockService.retrieveAllMouvements();
    }
}
