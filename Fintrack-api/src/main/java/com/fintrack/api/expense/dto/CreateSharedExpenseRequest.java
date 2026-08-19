package com.fintrack.api.expense.dto;

import com.fintrack.api.expense.model.SplitType;
import jakarta.validation.Valid;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.math.BigDecimal;
import java.util.List;

public record CreateSharedExpenseRequest(
        @NotBlank String creatorUserId,
        @NotBlank @Size(max = 200) String description,
        @NotNull @DecimalMin(value = "0.01") BigDecimal totalAmount,
        @NotNull SplitType splitType,
        @NotEmpty List<@Valid ParticipantShareRequest> participants
) {}
