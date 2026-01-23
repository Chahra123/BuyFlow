package com.esprit.examen.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class StockDto {
    private Long idStock;
    private String libelleStock;
    private Integer qteMin;
    private Integer qteTotale;
    private String status; // "CRITICAL", "WARNING", "GOOD"
}
