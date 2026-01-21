package com.esprit.examen.entities;

import lombok.*;

import javax.persistence.*;
import java.math.BigDecimal;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CustomerOrderItem {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(optional = false)
    @com.fasterxml.jackson.annotation.JsonIgnore
    private CustomerOrder order;

    @ManyToOne(optional = false)
    private Produit produit;

    private Integer quantity;

    /** snapshot of price at purchase time */
    @Column(precision = 19, scale = 3)
    private BigDecimal unitPrice;

    @Column(precision = 19, scale = 3)
    private BigDecimal lineTotal;
}
