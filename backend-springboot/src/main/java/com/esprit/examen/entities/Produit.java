package com.esprit.examen.entities;

import java.io.Serializable;
import java.time.LocalDate;
import java.util.Set;
import javax.persistence.*;
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.PositiveOrZero;

import com.fasterxml.jackson.annotation.JsonIgnore;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class Produit implements Serializable {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long idProduit;
	@NotBlank(message = "Le code produit est obligatoire")
	private String codeProduit;
	@NotBlank(message = "Le libellé produit est obligatoire")
	private String libelleProduit;
	@PositiveOrZero(message = "Le prix ne peut pas être négatif")
	private float prix;
	@PositiveOrZero(message = "La quantité minimale ne peut pas être négative")
	private Integer qteMin;
	private LocalDate dateCreation;
	private LocalDate dateDerniereModification;
	@ManyToOne
	@JsonIgnore
	private Stock stock;
	@OneToMany(mappedBy = "produit")
	@JsonIgnore
	private Set<DetailFacture> detailFacture;
	@ManyToOne
	@JsonIgnore
	private CategorieProduit categorieProduit;

	@OneToMany(mappedBy = "produit", cascade = CascadeType.ALL, orphanRemoval = true)
	@JsonIgnore
	private Set<MouvementStock> mouvements;

	@PrePersist
	private void onCreate() {
		dateCreation = LocalDate.now();
		dateDerniereModification = LocalDate.now();
	}

	@PreUpdate
	private void onUpdate() {
		dateDerniereModification = LocalDate.now();
	}

}
