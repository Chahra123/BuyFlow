package com.esprit.examen.entities;

import java.io.Serializable;
import java.time.LocalDate;
import javax.persistence.*;

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
    private Produit produit;

    private Integer quantite;

    @Enumerated(EnumType.STRING)
    private TypeMouvement type;

    private LocalDate dateMouvement;

    @PrePersist
    private void onCreate() {
        dateMouvement = LocalDate.now();
    }
}
