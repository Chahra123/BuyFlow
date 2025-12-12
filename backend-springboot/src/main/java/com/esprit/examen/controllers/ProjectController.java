package com.esprit.examen.controllers;


import com.esprit.examen.entities.*;
import com.esprit.examen.services.*;


import com.esprit.examen.entities.CategorieProduit;
import com.esprit.examen.entities.Facture;
import com.esprit.examen.services.ICategorieProduitService;
import com.esprit.examen.services.IFactureService;




import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.*;
import java.util.Date;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.RestController;

@RestController
@CrossOrigin("*")


@RequiredArgsConstructor
public class ProjectController {

    private final IStockService stockService;
    private final IFactureService factureService;
    private final ICategorieProduitService categorieProduitService;

    private final IFournisseurService fournisseurService;

    private final IOperateurService operateurService;
    private final IProduitService produitService;

    private final IReglementService reglementService;

    private final ISecteurActiviteService secteurActiviteService;

    // http://localhost:8089/SpringMVC/reglement/getChiffreAffaireEntreDeuxDate/{startDate}/{endDate}
    @GetMapping(value = "/getChiffreAffaireEntreDeuxDate/{startDate}/{endDate}")
    public float getChiffreAffaireEntreDeuxDate(
            @PathVariable(name = "startDate") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) Date startDate,
            @PathVariable(name = "endDate") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) Date endDate) {
        try {
            return reglementService.getChiffreAffaireEntreDeuxDate(startDate, endDate);
        } catch (Exception e) {
            return 0;
        }
    }

    // http://localhost:8089/SpringMVC/reglement/retrieveReglementByFacture/8
    @GetMapping("/retrieveReglementByFacture/{facture-id}")
    @ResponseBody
    public List<Reglement> retrieveReglementByFacture(@PathVariable("facture-id") Long factureId) {
        return reglementService.retrieveReglementByFacture(factureId);
    }

    // http://localhost:8089/SpringMVC/reglement/retrieve-reglement/8
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

    // http://localhost:8089/SpringMVC/reglement/add-reglement
    @PostMapping("/add-reglement")
    @ResponseBody
    public Reglement addReglement(@RequestBody Reglement r) {
        Reglement reglement = reglementService.addReglement(r);
        return reglement;
    }

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

    @PutMapping(value = "/assignSecteurActiviteToFournisseur/{idSecteurActivite}/{idFournisseur}")
    public void assignSecteurActiviteToFournisseur(@PathVariable("idSecteurActivite") Long idSecteurActivite, @PathVariable("idFournisseur") Long idFournisseur) {
        fournisseurService.assignSecteurActiviteToFournisseur(idSecteurActivite, idFournisseur);
    }

    @GetMapping("/factures")
    public List<Facture> getFactures() {
        return factureService.retrieveAllFactures();
    }

    @GetMapping("/{facture-id}")

    public Facture retrieveFacture(@PathVariable("facture-id") Long factureId) {
        return factureService.retrieveFacture(factureId);
    }

    @PostMapping("/factures")
    public Facture addFacture(@RequestBody Facture f) {
        Facture facture = factureService.addFacture(f);
        return facture;
    }

    /*
     * une facture peut être annulée si elle a été saisie par erreur. Pour ce
     * faire, il suffit de mettre le champs active à false
     */
    @PutMapping("/cancel/{facture-id}")
    public void cancelFacture(@PathVariable("facture-id") Long factureId) {
        factureService.cancelFacture(factureId);
    }

    @GetMapping("/byfournisseur/{fournisseur-id}")
    public List<Facture> getFactureByFournisseur(@PathVariable("fournisseur-id") Long fournisseurId) {
        return factureService.getFacturesByFournisseur(fournisseurId);
    }

    @PutMapping(value = "/assign-to-operateur/{idOperateur}/{idFacture}")
    public void assignOperateurToFacture(@PathVariable("idOperateur") Long idOperateur, @PathVariable("idFacture") Long idFacture) {
        factureService.assignOperateurToFacture(idOperateur, idFacture);
    }

    @GetMapping(value = "/pourcentage-recouvrement/{startDate}/{endDate}")
    public float pourcentageRecouvrement(
            @PathVariable(name = "startDate") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) Date startDate,
            @PathVariable(name = "endDate") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) Date endDate) {

        return factureService.pourcentageRecouvrement(startDate, endDate);

    }
    
    @GetMapping("/categories")
    public List<CategorieProduit> getCategorieProduit() {
        List<CategorieProduit> list = categorieProduitService.retrieveAllCategorieProduits();
        return list;
    }

    @PostMapping("/categories")
    public CategorieProduit addCategorieProduit(@RequestBody CategorieProduit cp) {
        CategorieProduit categorieProduit = categorieProduitService.addCategorieProduit(cp);
        return categorieProduit;
    }

    @GetMapping("/{categorieProduit-id}")
    public CategorieProduit retrieveCategorieProduit(@PathVariable("categorieProduit-id") Long categorieProduitId) {
        return categorieProduitService.retrieveCategorieProduit(categorieProduitId);
    }

    @DeleteMapping("/categorieproduit/{categorieProduit-id}")
    public void removeCategorieProduit(@PathVariable("categorieProduit-id") Long categorieProduitId) {
        categorieProduitService.deleteCategorieProduit(categorieProduitId);
    }

    @PutMapping("/categorie-produit")
    public CategorieProduit modifyCategorieProduit(@RequestBody CategorieProduit categorieProduit) {
        return categorieProduitService.updateCategorieProduit(categorieProduit);
    }


    @GetMapping("/prdouits")
    public List<Produit> getProduits() {
        return produitService.retrieveAllProduits();
    }

    @GetMapping("/{produit-id}")
    public Produit retrieveRayon(@PathVariable("produit-id") Long produitId) {
        return produitService.retrieveProduit(produitId);
    }
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

    /*
     * Si le responsable magasin souhaite modifier le stock du produit il peut
     * le faire en l'affectant au stock en question
     */
    // http://localhost:8089/SpringMVC/produit/assignProduitToStock/1/5
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


    @GetMapping("/secteurs")
    public List<SecteurActivite> getSecteurActivite() {
        return secteurActiviteService.retrieveAllSecteurActivite();
    }


    @GetMapping("/retrieve-all-stocks")
    public List<Stock> getStocks() {
        return stockService.retrieveAllStocks();
    }
    @GetMapping("/{stock-id}")
    public Stock retrieveStock(@PathVariable("stock-id") Long stockId) {
        return stockService.retrieveStock(stockId);
    }

    @PostMapping("/stocks")
    public Stock addStock(@RequestBody Stock s) {
        Stock stock = stockService.addStock(s);
        return stock;
    }
    @DeleteMapping("/stock/{stock-id}")
    public void removeStock(@PathVariable("stock-id") Long stockId) {
        stockService.deleteStock(stockId);
    }

    @PutMapping("/stocks")
    public Stock modifyStock(@RequestBody Stock stock) {
        return stockService.updateStock(stock);
    }

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

