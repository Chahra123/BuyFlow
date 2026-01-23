package com.esprit.examen.dto;

import lombok.Data;

/**
 * Admin assignment request.
 */
@Data
public class AssignCourierRequest {
    /** optional; if null => auto-assign */
    private Long courierUserId;
}
