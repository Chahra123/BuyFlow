package com.esprit.examen.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class AdminStatsResponse {
    private long totalUsers;
    private long enabledUsers;
    private long adminUsers;
    private long newUsersLast24h;
}
