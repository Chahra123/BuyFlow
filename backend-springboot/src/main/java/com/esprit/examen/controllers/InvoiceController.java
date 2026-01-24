package com.esprit.examen.controllers;

import com.esprit.examen.entities.CustomerOrder;
import com.esprit.examen.services.InvoiceService;
import com.esprit.examen.services.OrderService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.security.Principal;

@RestController
@RequestMapping("/api/orders")
@CrossOrigin("*")
@RequiredArgsConstructor
public class InvoiceController {

    private final OrderService orderService;
    private final InvoiceService invoiceService;

    @GetMapping(value = "/{id}/invoice", produces = MediaType.APPLICATION_PDF_VALUE)
    public ResponseEntity<byte[]> invoice(@PathVariable Long id, Principal principal) {
        // Access control is enforced by OrderService
        CustomerOrder order = orderService.getMyOrder(id, principal);
        byte[] pdf = invoiceService.generateInvoicePdf(order.getId());
        System.out.println("generation of pdf complete successfully ****");

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=facture-commande-" + id + ".pdf")
                .contentType(MediaType.APPLICATION_PDF)
                .body(pdf);
    }
}
