package com.esprit.examen.entities;

import lombok.*;

import javax.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CustomerOrder {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(optional = false)
    private User user;

    @ManyToOne
    private User assignedCourier; // role LIVREUR

    @Enumerated(EnumType.STRING)
    private OrderStatus status;

    @Enumerated(EnumType.STRING)
    private PaymentStatus paymentStatus;

    @Enumerated(EnumType.STRING)
    private PaymentMethod paymentMethod;

    /**
     * Delivery address in free text.
     */
    @Column(length = 500)
    private String deliveryAddress;

    private Double deliveryLat;
    private Double deliveryLng;

    @Column(length = 500)
    private String deliveryInstructions;

    /**
     * Secure token embedded into QR code.
     */
    @Column(unique = true, length = 64)
    private String deliveryToken;

    @Column(precision = 19, scale = 3)
    private BigDecimal subtotal;

    @Column(precision = 19, scale = 3)
    private BigDecimal shippingFee;

    @Column(precision = 19, scale = 3)
    private BigDecimal total;

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    @OneToMany(mappedBy = "order", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<CustomerOrderItem> items = new ArrayList<>();

    @PrePersist
    void onCreate() {
        if (status == null)
            status = OrderStatus.PLACED;
        if (paymentStatus == null)
            paymentStatus = PaymentStatus.UNPAID;
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}
