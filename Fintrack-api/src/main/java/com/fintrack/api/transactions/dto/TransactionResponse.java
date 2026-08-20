package com.fintrack.api.transactions.dto;

import java.math.BigDecimal;
import java.time.Instant;

public record TransactionResponse(Long id, String userId, BigDecimal amount, String note, Instant createdAt) {}
