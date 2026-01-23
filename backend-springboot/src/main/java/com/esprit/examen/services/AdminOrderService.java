package com.esprit.examen.services;

import com.esprit.examen.dto.AssignCourierRequest;
import com.esprit.examen.entities.*;
import com.esprit.examen.exception.BadRequestException;
import com.esprit.examen.exception.ResourceNotFoundException;
import com.esprit.examen.repositories.CustomerOrderRepository;
import com.esprit.examen.repositories.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class AdminOrderService {

    private final CustomerOrderRepository orderRepository;
    private final UserRepository userRepository;

    @Transactional
    public CustomerOrder assignCourier(Long orderId, AssignCourierRequest request) {
        CustomerOrder order = orderRepository.findById(orderId)
                .orElseThrow(() -> new ResourceNotFoundException("Order not found"));

        if (order.getStatus() == OrderStatus.CANCELLED || order.getStatus() == OrderStatus.DELIVERED) {
            throw new BadRequestException("Cannot assign courier for status " + order.getStatus());
        }

        User courier;
        if (request != null && request.getCourierUserId() != null) {
            courier = userRepository.findById(request.getCourierUserId())
                    .orElseThrow(() -> new ResourceNotFoundException("Courier not found"));
        } else {
            List<User> couriers = userRepository.findByRole(Role.LIVREUR);
            if (couriers.isEmpty()) {
                throw new BadRequestException("No courier available");
            }
            courier = couriers.get(0);
        }
        if (courier.getRole() != Role.LIVREUR) {
            throw new BadRequestException("Selected user is not a courier");
        }

        order.setAssignedCourier(courier);
        order.setStatus(OrderStatus.ASSIGNED);
        return orderRepository.save(order);
    }
}
