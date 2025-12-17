package com.esprit.examen.controllers;

import com.esprit.examen.dto.ProduitDTO;
import com.esprit.examen.entities.MouvementStock;
import com.esprit.examen.entities.Produit;
import com.esprit.examen.services.IProduitService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

@RestController
//@RequestMapping("/produits")
@CrossOrigin("*")
@RequiredArgsConstructor
public class ProduitController {

    private final IProduitService produitService;

    /* Ajouter en produit tout en lui affectant la catégorie produit et le stock associés */
    @PostMapping
    public Produit addProduit(@RequestBody Produit p) {
        return produitService.addProduit(p);
    }

    @DeleteMapping("/produit/{produit-id}")
    public void removeProduit(@PathVariable("produit-id") Long produitId) {
        produitService.deleteProduit(produitId);
    }

    @PutMapping("/produits")
    public Produit modifyProduit(@RequestBody Produit p) {
        return produitService.updateProduit(p);
    }

    @GetMapping("/produit/{produit-id}")
    public Produit retrieveRayon(@PathVariable("produit-id") Long produitId) {
        return produitService.retrieveProduit(produitId);
    }

    @GetMapping("/prdouits")
    public List<ProduitDTO> getProduits() {
        return produitService.retrieveAllProduits().stream().map(produitService::toDTO).collect(Collectors.toList());
    }


    @GetMapping("/getProduitByStock/{idStock}")
    public List<Produit> getProduitsByStock(@PathVariable Long idStock) {
        return produitService.getProduitsByStock(idStock);
    }

    /*
     * Si le responsable magasin souhaite modifier le stock du produit il peut
     * le faire en l'affectant au stock en question
     */
    @PutMapping(value = "/assignProduitToStock/{idProduit}/{idStock}")
    public void assignProduitToStock(@PathVariable("idProduit") Long idProduit, @PathVariable("idStock") Long idStock) {
        produitService.assignProduitToStock(idProduit, idStock);
    }

    /*
     * Revenu Brut d'un produit (qte * prix unitaire de toutes les lignes du
     * detailFacture du produit envoyé en paramètre )
     */
    // http://localhost:8089/SpringMVC/produit/getRevenuBrutProduit/1/{startDate}/{endDate}
/*	@GetMapping(value = "/getRevenuBrutProduit/{idProduit}/{startDate}/{endDate}")
	public float getRevenuBrutProduit(@PathVariable("idProduit") Long idProduit,
			@PathVariable(name = "startDate") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) Date startDate,
			@PathVariable(name = "endDate") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) Date endDate) {

		return produitService.getRevenuBrutProduit(idProduit, startDate, endDate);
	}*/




    /*
     * Spring Scheduler : Comparer QteMin tolérée (à ne pa dépasser) avec
     * Quantité du stock et afficher sur console la liste des produits inférieur
     * au stock La fct schédulé doit obligatoirement etre sans paramètres et
     * sans retour (void)
     */
    // http://localhost:8089/SpringMVC/stock/retrieveStatusStock
    // @Scheduled(fixedRate = 60000)
    // @Scheduled(fixedDelay = 60000)
    //@Scheduled(cron = "*/60 * * * * *")
    //@GetMapping("/retrieveStatusStock")
//	@ResponseBody
//	public void retrieveStatusStock() {
//		stockService.retrieveStatusStock();
//	}


    @PutMapping("/removeProduitFromStock/{idProduit}")
    public void removeProduitFromStock(@PathVariable Long idProduit) {
        produitService.removeProduitFromStock(idProduit);
    }

    @GetMapping("/produits/{id}/quantite")
    public Integer getQuantiteProduit(@PathVariable Long id) {
        return produitService.getQuantiteProduit(id);
    }

    @PutMapping(value = "/assignProduitToStock/{idProduit}/{idStock}/{qteInitiale}")
    public void assignProduitToStock(@PathVariable Long idProduit, @PathVariable Long idStock, @PathVariable Integer qteInitiale) {
        produitService.assignProduitToStock(idProduit, idStock, qteInitiale);
    }

    @GetMapping("/produit/{id}/mouvements")
    public List<MouvementStock> getMouvementsProduit(@PathVariable Long id) {
        return produitService.getMouvementsProduit(id);
    }
}
