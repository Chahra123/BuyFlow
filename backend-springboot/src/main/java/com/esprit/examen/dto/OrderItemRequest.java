package com.esprit.examen.dto;

import lombok.Data;

import javax.validation.constraints.Min;
import javax.validation.constraints.NotNull;

@Data
public class OrderItemRequest {
    @NotNull
    private Long produitId;

    @NotNull
    @Min(1)
    private Integer quantity;
}
