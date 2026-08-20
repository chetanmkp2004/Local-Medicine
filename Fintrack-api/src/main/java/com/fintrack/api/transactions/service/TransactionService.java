package com.fintrack.api.transactions.service;

import com.fintrack.api.auth.AuthGuard;
import com.fintrack.api.transactions.dto.CreateTransactionRequest;
import com.fintrack.api.transactions.dto.TransactionResponse;
import com.fintrack.api.transactions.model.TransactionEntity;
import com.fintrack.api.transactions.repository.TransactionRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;

/** Provides transaction operations with user ownership validation. */
@Service
public class TransactionService {
    private static final Logger log = LoggerFactory.getLogger(TransactionService.class);

    private final TransactionRepository transactionRepository;
    private final AuthGuard authGuard;

    public TransactionService(TransactionRepository transactionRepository, AuthGuard authGuard) {
        this.transactionRepository = transactionRepository;
        this.authGuard = authGuard;
    }

    /** Creates a transaction for the authenticated user. */
    @Transactional
    public TransactionResponse create(String callerUserId, CreateTransactionRequest request) {
        authGuard.assertCallerMatches(callerUserId, request.userId());
        TransactionEntity entity = new TransactionEntity();
        entity.setUserId(request.userId());
        entity.setAmount(request.amount());
        entity.setNote(request.note());
        entity.setCreatedAt(Instant.now());
        TransactionEntity saved = transactionRepository.save(entity);
        log.info("Transaction created id={} userId={} amount={}", saved.getId(), saved.getUserId(), saved.getAmount());
        return toResponse(saved);
    }

    /** Returns all transactions for the requested user if authorized. */
    @Transactional(readOnly = true)
    public List<TransactionResponse> getByUser(String callerUserId, String userId) {
        authGuard.assertCallerMatches(callerUserId, userId);
        return transactionRepository.findByUserIdOrderByCreatedAtDesc(userId).stream().map(this::toResponse).toList();
    }

    /** Deletes all transactions belonging to the requested user if authorized. */
    @Transactional
    public void deleteAllForUser(String callerUserId, String userId) {
        authGuard.assertCallerMatches(callerUserId, userId);
        transactionRepository.deleteByUserId(userId);
        log.info("All transactions deleted for userId={}", userId);
    }

    private TransactionResponse toResponse(TransactionEntity entity) {
        return new TransactionResponse(entity.getId(), entity.getUserId(), entity.getAmount(), entity.getNote(), entity.getCreatedAt());
    }
}
