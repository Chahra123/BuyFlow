package com.esprit.examen.dto;

import lombok.Data;

import javax.validation.Valid;
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotEmpty;
import java.util.List;

@Data
public class CreateOrderRequest {

    @NotEmpty
    @Valid
    private List<OrderItemRequest> items;

    @NotBlank
    private String deliveryAddress;

    private Double deliveryLat;
    private Double deliveryLng;

    private String deliveryInstructions;

    /** reserved for future online payments */
    private String paymentMethod; // e.g. COD / ONLINE
}
