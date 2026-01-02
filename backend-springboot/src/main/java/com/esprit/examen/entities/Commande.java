package com.esprit.examen.entities;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import javax.persistence.*;
import java.io.Serializable;
import java.time.Instant;

@Entity
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class Commande implements Serializable {
    private static final long serialVersionUID = 1L;

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long idCommande;

    @ManyToOne(optional = false)
    private Operateur operateur;

    @ManyToOne(optional = false)
    private Produit produit;

    private Integer quantite;

    @Column(length = 600)
    private String adresseLivraison;

    private Double latitude;
    private Double longitude;

    @Enumerated(EnumType.STRING)
    private CommandeStatus status = CommandeStatus.EN_ATTENTE_CONFIRMATION;

    private Instant createdAt = Instant.now();
}
