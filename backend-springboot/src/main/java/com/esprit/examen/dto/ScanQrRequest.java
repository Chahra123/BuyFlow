package com.esprit.examen.dto;

import lombok.Data;

import javax.validation.constraints.NotBlank;

@Data
public class ScanQrRequest {
    @NotBlank
    private String qrData;
}
