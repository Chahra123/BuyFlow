package com.esprit.examen.controllers;

import com.esprit.examen.entities.Commande;
import com.esprit.examen.entities.Livraison;
import com.esprit.examen.repositories.LivraisonRepository;
import com.esprit.examen.services.ICommandeService;
import com.lowagie.text.*;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfWriter;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.io.ByteArrayOutputStream;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;

@RestController
@CrossOrigin("*")
@RequestMapping("/commandes")
@RequiredArgsConstructor
public class CommandeInvoiceController {

    private final ICommandeService commandeService;
    private final LivraisonRepository livraisonRepository;

    @GetMapping(value = "/{id}/invoice.pdf", produces = MediaType.APPLICATION_PDF_VALUE)
    public ResponseEntity<byte[]> downloadInvoice(@PathVariable("id") Long id) throws Exception {
        Commande c = commandeService.getById(id);
        Livraison livraison = livraisonRepository.findByCommande_IdCommande(c.getIdCommande()).orElse(null);

        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        Document document = new Document(PageSize.A4);
        PdfWriter.getInstance(document, baos);

        document.open();
        Font title = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 18);
        Font small = FontFactory.getFont(FontFactory.HELVETICA, 10);

        document.add(new Paragraph("FACTURE", title));
        document.add(new Paragraph("Commande #" + c.getIdCommande(), small));
        String date = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm")
                .withZone(ZoneId.systemDefault())
                .format(c.getCreatedAt());
        document.add(new Paragraph("Date: " + date, small));
        document.add(Chunk.NEWLINE);

        PdfPTable table = new PdfPTable(2);
        table.setWidthPercentage(100);
        table.addCell("Client");
        table.addCell(c.getOperateur().getPrenom() + " " + c.getOperateur().getNom());
        table.addCell("Produit");
        table.addCell(c.getProduit().getLibelleProduit());
        table.addCell("Quantité");
        table.addCell(String.valueOf(c.getQuantite()));
        table.addCell("Adresse de livraison");
        table.addCell(c.getAdresseLivraison() == null ? "" : c.getAdresseLivraison());
        if (livraison != null) {
            table.addCell("Statut livraison");
            table.addCell(livraison.getStatus().name());
        }
        document.add(table);

        document.close();

        byte[] pdf = baos.toByteArray();
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=facture-commande-" + id + ".pdf")
                .contentType(MediaType.APPLICATION_PDF)
                .body(pdf);
    }
}
