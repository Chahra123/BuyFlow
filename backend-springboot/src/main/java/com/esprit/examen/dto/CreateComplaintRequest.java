package com.esprit.examen.dto;

import com.esprit.examen.entities.ComplaintCategory;
import lombok.Data;

import javax.validation.constraints.NotNull;
import javax.validation.constraints.Size;

@Data
public class CreateComplaintRequest {
    @NotNull
    private Long orderId;

    @NotNull
    private ComplaintCategory category;

    @Size(max = 2000)
    private String description;
}
