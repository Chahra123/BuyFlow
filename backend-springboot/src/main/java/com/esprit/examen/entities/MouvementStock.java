package com.esprit.examen.entities;

import java.io.Serializable;
import java.time.LocalDate;
import javax.persistence.*;
import javax.validation.constraints.NotNull;
import javax.validation.constraints.Positive;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class MouvementStock implements Serializable {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @NotNull(message = "Le produit est obligatoire pour un mouvement")
    private Produit produit;

    @Positive(message = "La quantité doit être strictement supérieure à 0")
    @NotNull(message = "La quantité est obligatoire")
    private Integer quantite;

    @Enumerated(EnumType.STRING)
    @NotNull(message = "Le type de mouvement est obligatoire")
    private TypeMouvement type;

    private LocalDate dateMouvement;

    private String raison;

    private String utilisateur;

    @PrePersist
    private void onCreate() {
        dateMouvement = LocalDate.now();
    }
}
