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
public class Reclamation implements Serializable {
    private static final long serialVersionUID = 1L;

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long idReclamation;

    @ManyToOne(optional = false)
    private Operateur operateur;

    @ManyToOne(optional = false)
    private Commande commande;

    private String objet;

    @Column(length = 2000)
    private String description;

    @Enumerated(EnumType.STRING)
    private ReclamationStatus status = ReclamationStatus.OUVERT;

    private Instant createdAt = Instant.now();
    private Instant updatedAt = Instant.now();
}
