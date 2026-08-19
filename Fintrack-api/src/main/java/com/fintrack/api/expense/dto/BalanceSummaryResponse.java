package com.fintrack.api.expense.dto;

import java.math.BigDecimal;

public record BalanceSummaryResponse(String counterpartUserId, String direction, BigDecimal amount) {}
