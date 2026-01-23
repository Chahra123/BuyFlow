package com.esprit.examen.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.util.List;
import java.util.Map;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class StockStatsResponse {
    private long totalStocks;
    private long totalProducts;
    private long lowStockCount;
    private List<MovementSummaryDTO> recentMovements;

    @Data
    @AllArgsConstructor
    @NoArgsConstructor
    public static class MovementSummaryDTO {
        private Long id;
        private String produitLibelle;
        private Integer quantite;
        private String type;
        private String date;
        private String raison;
    }
}
