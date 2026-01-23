package com.esprit.examen.services;

import com.esprit.examen.dto.CreateOrderRequest;
import com.esprit.examen.dto.OrderItemRequest;
import com.esprit.examen.entities.*;
import com.esprit.examen.exception.BadRequestException;
import com.esprit.examen.exception.InsufficientStockException;
import com.esprit.examen.exception.ResourceNotFoundException;
import com.esprit.examen.repositories.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.security.Principal;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class OrderService {

    private final CustomerOrderRepository orderRepository;
    private final CustomerOrderItemRepository orderItemRepository;
    private final UserRepository userRepository;
    private final ProduitRepository produitRepository;
    private final MouvementStockRepository mouvementStockRepository;

    private User getConnectedUser(Principal principal) {
        if (principal == null) throw new BadRequestException("Missing authentication");
        return userRepository.findByEmail(principal.getName())
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
    }

    public List<CustomerOrder> myOrders(Principal principal) {
        User user = getConnectedUser(principal);
        return orderRepository.findByUserOrderByCreatedAtDesc(user);
    }

    public CustomerOrder getMyOrder(Long id, Principal principal) {
        User user = getConnectedUser(principal);
        CustomerOrder order = orderRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Order not found"));
        if (!order.getUser().getId().equals(user.getId()) && user.getRole() != Role.ADMIN) {
            throw new org.springframework.security.access.AccessDeniedException("Not allowed");
        }
        return order;
    }

    public CustomerOrder getMyOrder(Long id) {
        CustomerOrder order = orderRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Order not found"));
        return order;
    }

    @Transactional
    public CustomerOrder createOrder(CreateOrderRequest request, Principal principal) {
        User user = getConnectedUser(principal);

        if (request.getItems() == null || request.getItems().isEmpty()) {
            throw new BadRequestException("Order items are required");
        }

        CustomerOrder order = CustomerOrder.builder()
                .user(user)
                .deliveryAddress(request.getDeliveryAddress())
                .deliveryLat(request.getDeliveryLat())
                .deliveryLng(request.getDeliveryLng())
                .deliveryInstructions(request.getDeliveryInstructions())
                .deliveryToken(UUID.randomUUID().toString().replace("-", ""))
                .status(OrderStatus.CONFIRMED)
                .paymentStatus(PaymentStatus.UNPAID)
                .shippingFee(BigDecimal.ZERO)
                .build();

        BigDecimal subtotal = BigDecimal.ZERO;
        for (OrderItemRequest itemReq : request.getItems()) {
            Produit produit = produitRepository.findById(itemReq.getProduitId())
                    .orElseThrow(() -> new ResourceNotFoundException("Produit not found: " + itemReq.getProduitId()));

            Integer available = mouvementStockRepository.calculerQuantiteProduit(produit.getIdProduit());
            if (available == null) available = 0;
            if (itemReq.getQuantity() == null || itemReq.getQuantity() < 1) {
                throw new BadRequestException("Invalid quantity for produit " + produit.getIdProduit());
            }
            if (available < itemReq.getQuantity()) {
                throw new InsufficientStockException(
                        "Insufficient stock for produit " + produit.getLibelleProduit() + " (available=" + available + ")"
                );
            }

            BigDecimal unitPrice = BigDecimal.valueOf(produit.getPrix());
            BigDecimal lineTotal = unitPrice.multiply(BigDecimal.valueOf(itemReq.getQuantity()));

            CustomerOrderItem orderItem = CustomerOrderItem.builder()
                    .order(order)
                    .produit(produit)
                    .quantity(itemReq.getQuantity())
                    .unitPrice(unitPrice)
                    .lineTotal(lineTotal)
                    .build();

            order.getItems().add(orderItem);
            subtotal = subtotal.add(lineTotal);

            // Stock decrement at validation (your rule)
            MouvementStock m = new MouvementStock();
            m.setProduit(produit);
            m.setQuantite(itemReq.getQuantity());
            m.setType(TypeMouvement.SORTIE);
            m.setRaison("ORDER_CONFIRMED:" + UUID.randomUUID());
            m.setUtilisateur(user.getEmail());
            mouvementStockRepository.save(m);
        }

        order.setSubtotal(subtotal);
        order.setTotal(subtotal.add(order.getShippingFee() == null ? BigDecimal.ZERO : order.getShippingFee()));

        CustomerOrder saved = orderRepository.save(order);
        // cascade saves items, but keep repository to satisfy JPA provider
        orderItemRepository.saveAll(saved.getItems());
        return saved;
    }

    @Transactional
    public CustomerOrder cancelMyOrder(Long orderId, Principal principal) {
        User user = getConnectedUser(principal);
        CustomerOrder order = orderRepository.findById(orderId)
                .orElseThrow(() -> new ResourceNotFoundException("Order not found"));

        if (!order.getUser().getId().equals(user.getId()) && user.getRole() != Role.ADMIN) {
            throw new org.springframework.security.access.AccessDeniedException("Not allowed");
        }
        if (order.getAssignedCourier() != null || order.getStatus() == OrderStatus.ASSIGNED || order.getStatus() == OrderStatus.OUT_FOR_DELIVERY) {
            throw new BadRequestException("Cannot cancel after courier assignment");
        }
        if (order.getStatus() == OrderStatus.CANCELLED || order.getStatus() == OrderStatus.DELIVERED) {
            throw new BadRequestException("Cannot cancel order in status " + order.getStatus());
        }

        // Restock
        for (CustomerOrderItem item : order.getItems()) {
            MouvementStock m = new MouvementStock();
            m.setProduit(item.getProduit());
            m.setQuantite(item.getQuantity());
            m.setType(TypeMouvement.ENTREE);
            m.setRaison("ORDER_CANCELLED:" + order.getId());
            m.setUtilisateur(user.getEmail());
            mouvementStockRepository.save(m);
        }

        order.setStatus(OrderStatus.CANCELLED);
        return orderRepository.save(order);
    }

    public String getQrData(Long orderId, Principal principal) {
        CustomerOrder order = getMyOrder(orderId, principal);
        return "ORDER:" + order.getId() + ":" + order.getDeliveryToken();
    }
    public String getQrData(Long orderId) {
        CustomerOrder order = getMyOrder(orderId);
        return "ORDER:" + order.getId() + ":" + order.getDeliveryToken();
    }
}
