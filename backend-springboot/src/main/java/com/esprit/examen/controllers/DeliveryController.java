package com.esprit.examen.controllers;

import com.esprit.examen.dto.ScanQrRequest;
import com.esprit.examen.entities.CustomerOrder;
import com.esprit.examen.services.DeliveryService;
import lombok.RequiredArgsConstructor;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;
import java.security.Principal;
import java.util.List;

@RestController
@RequestMapping("/api/delivery/orders")
@CrossOrigin("*")
@RequiredArgsConstructor
@Validated
public class DeliveryController {

    private final DeliveryService deliveryService;

    @GetMapping
    public List<CustomerOrder> myOrders(Principal principal) {
        return deliveryService.myAssignedOrders(principal);
    }

    @PostMapping("/{id}/start")
    public CustomerOrder start(@PathVariable Long id, Principal principal) {
        return deliveryService.startDelivery(id, principal);
    }

    @PostMapping("/{id}/scan")
    public CustomerOrder scan(@PathVariable Long id, @Valid @RequestBody ScanQrRequest request, Principal principal) {
        return deliveryService.scanAndDeliver(id, request, principal);
    }

    @PostMapping("/{id}/validate")
    public CustomerOrder validate(@PathVariable Long id, Principal principal) {
        return deliveryService.validateDelivery(id, principal);
    }
}
