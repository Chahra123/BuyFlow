package com.esprit.examen.services;

import com.esprit.examen.dto.ScanQrRequest;
import com.esprit.examen.entities.*;
import com.esprit.examen.exception.BadRequestException;
import com.esprit.examen.exception.ResourceNotFoundException;
import com.esprit.examen.repositories.CustomerOrderRepository;
import com.esprit.examen.repositories.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.security.Principal;
import java.util.List;

@Service
@RequiredArgsConstructor
public class DeliveryService {

    private final CustomerOrderRepository orderRepository;
    private final UserRepository userRepository;

    private User getCourier(Principal principal) {
        if (principal == null)
            throw new BadRequestException("Missing authentication");
        return userRepository.findByEmail(principal.getName())
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
    }

    public List<CustomerOrder> myAssignedOrders(Principal principal) {
        User courier = getCourier(principal);
        return orderRepository.findByAssignedCourierAndStatusInOrderByUpdatedAtDesc(
                courier,
                List.of(OrderStatus.ASSIGNED, OrderStatus.OUT_FOR_DELIVERY));
    }

    @Transactional
    public CustomerOrder startDelivery(Long orderId, Principal principal) {
        User courier = getCourier(principal);
        CustomerOrder order = orderRepository.findById(orderId)
                .orElseThrow(() -> new ResourceNotFoundException("Order not found"));
        if (order.getAssignedCourier() == null || !order.getAssignedCourier().getId().equals(courier.getId())) {
            throw new org.springframework.security.access.AccessDeniedException("Not assigned to you");
        }
        if (order.getStatus() != OrderStatus.ASSIGNED && order.getStatus() != OrderStatus.OUT_FOR_DELIVERY) {
            throw new BadRequestException("Cannot start delivery for status " + order.getStatus());
        }
        order.setStatus(OrderStatus.OUT_FOR_DELIVERY);
        return orderRepository.save(order);
    }

    @Transactional
    public CustomerOrder scanAndDeliver(Long orderId, ScanQrRequest request, Principal principal) {
        User courier = getCourier(principal);
        CustomerOrder order = orderRepository.findById(orderId)
                .orElseThrow(() -> new ResourceNotFoundException("Order not found"));
        if (order.getAssignedCourier() == null || !order.getAssignedCourier().getId().equals(courier.getId())) {
            throw new org.springframework.security.access.AccessDeniedException("Not assigned to you");
        }
        if (order.getStatus() != OrderStatus.OUT_FOR_DELIVERY && order.getStatus() != OrderStatus.ASSIGNED) {
            throw new BadRequestException("Order not in deliverable status");
        }

        String qr = request.getQrData();
        // Expected: ORDER:<id>:<token>
        String[] parts = qr.split(":");
        if (parts.length != 3 || !"ORDER".equals(parts[0])) {
            throw new BadRequestException("Invalid QR format");
        }
        Long parsedId;
        try {
            parsedId = Long.valueOf(parts[1]);
        } catch (NumberFormatException e) {
            throw new BadRequestException("Invalid QR order id");
        }
        String token = parts[2];
        if (!order.getId().equals(parsedId) || order.getDeliveryToken() == null
                || !order.getDeliveryToken().equals(token)) {
            throw new BadRequestException("QR does not match this order");
        }

        order.setStatus(OrderStatus.DELIVERED);
        if (order.getPaymentStatus() == PaymentStatus.UNPAID) {
            order.setPaymentStatus(PaymentStatus.PAID);
        }
        return orderRepository.save(order);
    }
}
