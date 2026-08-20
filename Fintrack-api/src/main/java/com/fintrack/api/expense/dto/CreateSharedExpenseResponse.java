package com.fintrack.api.expense.dto;

import java.time.Instant;

public record CreateSharedExpenseResponse(Long expenseId, Instant createdAt) {}
