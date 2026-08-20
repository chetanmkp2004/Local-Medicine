package com.fintrack.api.expense.dto;

import java.util.List;

public record PendingBalancesResponse(String userId, List<BalanceSummaryResponse> balances) {}
