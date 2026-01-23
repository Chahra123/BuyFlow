package com.esprit.examen.controllers;

import com.esprit.examen.dto.CreateOrderRequest;
import com.esprit.examen.dto.response.QrDataResponse;
import com.esprit.examen.entities.CustomerOrder;
import com.esprit.examen.services.OrderService;
import lombok.RequiredArgsConstructor;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;
import java.security.Principal;
import java.util.List;

@RestController
@RequestMapping("/api/orders")
@CrossOrigin("*")
@RequiredArgsConstructor
@Validated
public class OrderController {

    private final OrderService orderService;

    @GetMapping
    public List<CustomerOrder> myOrders(Principal principal) {
        return orderService.myOrders(principal);
    }

    @GetMapping("/{id}")
    public CustomerOrder getOrder(@PathVariable Long id, Principal principal) {
        return orderService.getMyOrder(id, principal);
    }

    @PostMapping
    public CustomerOrder create(@Valid @RequestBody CreateOrderRequest request, Principal principal) {
        return orderService.createOrder(request, principal);
    }

    @PostMapping("/{id}/cancel")
    public CustomerOrder cancel(@PathVariable Long id, Principal principal) {
        return orderService.cancelMyOrder(id, principal);
    }

    @GetMapping("/{id}/qr")
    public QrDataResponse qr(@PathVariable Long id, Principal principal) {
        return new QrDataResponse(orderService.getQrData(id));
    }
}
