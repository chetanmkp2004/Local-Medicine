package com.fintrack.api.expense.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;

import java.math.BigDecimal;

public record ParticipantShareRequest(
        @NotBlank String userId,
        @DecimalMin(value = "0.00") BigDecimal shareAmount
) {}
