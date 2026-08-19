package com.fintrack.api.transactions.controller;

import com.fintrack.api.transactions.dto.CreateTransactionRequest;
import com.fintrack.api.transactions.dto.TransactionResponse;
import com.fintrack.api.transactions.service.TransactionService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/** Exposes user-scoped transaction APIs. */
@RestController
@RequestMapping("/api/transactions")
@Validated
public class TransactionController {
    private final TransactionService transactionService;

    public TransactionController(TransactionService transactionService) {
        this.transactionService = transactionService;
    }

    /** Creates a transaction owned by the authenticated user. */
    @PostMapping
    public ResponseEntity<TransactionResponse> create(
            @RequestHeader("X-User-Id") String callerUserId,
            @Valid @RequestBody CreateTransactionRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(transactionService.create(callerUserId, request));
    }

    /** Retrieves transactions for the authenticated user. */
    @GetMapping("/{userId}")
    public List<TransactionResponse> getByUser(
            @RequestHeader("X-User-Id") String callerUserId,
            @PathVariable String userId) {
        return transactionService.getByUser(callerUserId, userId);
    }

    /** Deletes all transactions belonging to the authenticated user. */
    @DeleteMapping("/{userId}")
    public ResponseEntity<Void> deleteAll(
            @RequestHeader("X-User-Id") String callerUserId,
            @PathVariable String userId) {
        transactionService.deleteAllForUser(callerUserId, userId);
        return ResponseEntity.noContent().build();
    }
}
