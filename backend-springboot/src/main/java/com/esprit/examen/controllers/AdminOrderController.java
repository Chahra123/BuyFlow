package com.esprit.examen.controllers;

import com.esprit.examen.dto.AssignCourierRequest;
import com.esprit.examen.entities.CustomerOrder;
import com.esprit.examen.services.AdminOrderService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;

@RestController
@RequestMapping("/api/admin/orders")
@CrossOrigin("*")
@RequiredArgsConstructor
public class AdminOrderController {

    private final AdminOrderService adminOrderService;

    @PostMapping("/{id}/assign")
    public CustomerOrder assign(@PathVariable Long id, @RequestBody(required = false) AssignCourierRequest request) {
        return adminOrderService.assignCourier(id, request);
    }

    @GetMapping
    public java.util.List<CustomerOrder> getAllOrders() {
        return adminOrderService.getAllOrders();
    }
}
