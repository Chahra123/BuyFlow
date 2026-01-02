package com.esprit.examen.entities;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import javax.persistence.*;
import java.io.Serializable;
import java.time.Instant;
import java.util.UUID;

@Entity
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class Livraison implements Serializable {
    private static final long serialVersionUID = 1L;

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long idLivraison;

    @OneToOne(optional = false)
    private Commande commande;

    @Enumerated(EnumType.STRING)
    private LivraisonStatus status = LivraisonStatus.EN_ATTENTE;

    /**
     * Token used inside the QR code. We avoid exposing sequential IDs.
     */
    @Column(unique = true, nullable = false, updatable = false)
    private String qrToken = UUID.randomUUID().toString();

    private Instant createdAt = Instant.now();
    private Instant updatedAt = Instant.now();

    @ManyToOne
    private Operateur lastUpdatedBy;
}
