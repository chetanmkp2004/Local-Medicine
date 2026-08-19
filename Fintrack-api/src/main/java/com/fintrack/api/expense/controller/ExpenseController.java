package com.fintrack.api.expense.controller;

import com.fintrack.api.expense.dto.CreateSharedExpenseRequest;
import com.fintrack.api.expense.dto.CreateSharedExpenseResponse;
import com.fintrack.api.expense.dto.PendingBalancesResponse;
import com.fintrack.api.expense.service.ExpenseSplittingService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

/** Exposes shared expense and balance APIs. */
@RestController
@Validated
@RequestMapping("/api")
public class ExpenseController {
    private final ExpenseSplittingService expenseSplittingService;

    public ExpenseController(ExpenseSplittingService expenseSplittingService) {
        this.expenseSplittingService = expenseSplittingService;
    }

    /** Creates a shared expense and stores participant balances. */
    @PostMapping("/expenses")
    public ResponseEntity<CreateSharedExpenseResponse> createExpense(
            @RequestHeader("X-User-Id") String callerUserId,
            @Valid @RequestBody CreateSharedExpenseRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(expenseSplittingService.createSharedExpense(callerUserId, request));
    }

    /** Returns pending net balances for the authenticated user. */
    @GetMapping("/users/{userId}/balances")
    public PendingBalancesResponse getPendingBalances(
            @RequestHeader("X-User-Id") String callerUserId,
            @PathVariable String userId) {
        return expenseSplittingService.getPendingBalances(callerUserId, userId);
    }
}
