package com.esprit.examen.entities;

import java.io.Serializable;
import java.util.Set;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.OneToMany;
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
public class Stock implements Serializable {
    private static final long serialVersionUID = 1L;

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long idStock;
    @NotBlank(message = "Le libellé du stock est obligatoire")
    private String libelleStock;
    @PositiveOrZero(message = "La quantité minimale ne peut pas être négative")
    private Integer qteMin;
    @OneToMany(mappedBy = "stock")
    @JsonIgnore
    private Set<Produit> produits;

    public Stock(String libelleStock, Integer qteMin) {
        super();
        this.libelleStock = libelleStock;
        this.qteMin = qteMin;
    }

    public Stock(long idStock, String libelleStock, Integer qteMin) {
        super();
        this.idStock = idStock;
        this.libelleStock = libelleStock;
        this.qteMin = qteMin;
    }

}
