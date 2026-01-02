package com.esprit.examen.controllers;

import com.esprit.examen.dto.UpdateLivraisonStatusRequest;
import com.esprit.examen.entities.Livraison;
import com.esprit.examen.services.ILivraisonService;
import lombok.RequiredArgsConstructor;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;
import java.util.List;

@RestController
@CrossOrigin("*")
@RequestMapping("/livraisons")
@RequiredArgsConstructor
@Validated
public class LivraisonController {

    private final ILivraisonService livraisonService;

    @GetMapping
    public List<Livraison> listAll() {
        return livraisonService.listAll();
    }

    @PostMapping("/scan")
    public Livraison updateStatusByQr(@Valid @RequestBody UpdateLivraisonStatusRequest request) {
        return livraisonService.updateStatus(request);
    }

    @GetMapping("/{id}")
    public Livraison get(@PathVariable("id") Long id) {
        return livraisonService.getById(id);
    }
}
