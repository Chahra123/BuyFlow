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

	private static final long serialVersionUID = 1L;

	// =======================
	// IDENTITÉ
	// =======================
	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long idProduit;

	// =======================
	// DONNÉES MÉTIER
	// =======================
	private String codeProduit;

	private String libelleProduit;

	private float prix;

	private Integer qteMin;

	// =======================
	// IMAGE PRODUIT
	// =======================
	@Column(name = "image_url")
	private String imageUrl;

	// =======================
	// DATES (gérées par le backend)
	// =======================
	private LocalDate dateCreation;

	private LocalDate dateDerniereModification;

	// =======================
	// RELATIONS
	// =======================

	@ManyToOne
	@JsonIgnore
	private Stock stock;

	@ManyToOne
	@JoinColumn(name = "id_categorie_produit")
	@com.fasterxml.jackson.annotation.JsonIgnoreProperties({ "produits" })
	private CategorieProduit categorieProduit;

	@OneToMany(mappedBy = "produit")
	@JsonIgnore
	private Set<DetailFacture> detailFacture;

	@OneToMany(mappedBy = "produit")
	@JsonIgnore
	private Set<MouvementStock> mouvements;

	// =======================
	// LIFECYCLE JPA
	// =======================
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
