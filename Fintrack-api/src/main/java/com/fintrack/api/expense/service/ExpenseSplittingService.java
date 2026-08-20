package com.fintrack.api.expense.service;

import com.fintrack.api.auth.AuthGuard;
import com.fintrack.api.common.BadRequestException;
import com.fintrack.api.expense.dto.*;
import com.fintrack.api.expense.model.*;
import com.fintrack.api.expense.repository.BalanceEntryRepository;
import com.fintrack.api.expense.repository.ExpenseParticipantRepository;
import com.fintrack.api.expense.repository.SharedExpenseRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.Instant;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/** Handles shared expense creation and pending balance computations. */
@Service
public class ExpenseSplittingService {
    private static final Logger log = LoggerFactory.getLogger(ExpenseSplittingService.class);

    private final SharedExpenseRepository sharedExpenseRepository;
    private final ExpenseParticipantRepository expenseParticipantRepository;
    private final BalanceEntryRepository balanceEntryRepository;
    private final AuthGuard authGuard;

    public ExpenseSplittingService(
            SharedExpenseRepository sharedExpenseRepository,
            ExpenseParticipantRepository expenseParticipantRepository,
            BalanceEntryRepository balanceEntryRepository,
            AuthGuard authGuard) {
        this.sharedExpenseRepository = sharedExpenseRepository;
        this.expenseParticipantRepository = expenseParticipantRepository;
        this.balanceEntryRepository = balanceEntryRepository;
        this.authGuard = authGuard;
    }

    /** Creates a shared expense and corresponding balance entries. */
    @Transactional
    public CreateSharedExpenseResponse createSharedExpense(String callerUserId, CreateSharedExpenseRequest request) {
        authGuard.assertCallerMatches(callerUserId, request.creatorUserId());
        validateParticipants(request);

        SharedExpenseEntity expense = new SharedExpenseEntity();
        expense.setCreatorUserId(request.creatorUserId());
        expense.setDescription(request.description());
        expense.setTotalAmount(request.totalAmount().setScale(2, RoundingMode.HALF_UP));
        expense.setSplitType(request.splitType());
        expense.setCreatedAt(Instant.now());
        SharedExpenseEntity savedExpense = sharedExpenseRepository.save(expense);

        Map<String, BigDecimal> shares = calculateShares(request);
        shares.forEach((participantId, amount) -> {
            ExpenseParticipantEntity participant = new ExpenseParticipantEntity();
            participant.setExpense(savedExpense);
            participant.setParticipantUserId(participantId);
            participant.setShareAmount(amount);
            expenseParticipantRepository.save(participant);

            if (!participantId.equals(request.creatorUserId()) && amount.compareTo(BigDecimal.ZERO) > 0) {
                BalanceEntryEntity entry = new BalanceEntryEntity();
                entry.setExpense(savedExpense);
                entry.setDebtorUserId(participantId);
                entry.setCreditorUserId(request.creatorUserId());
                entry.setAmount(amount);
                entry.setCreatedAt(Instant.now());
                balanceEntryRepository.save(entry);
            }
        });

        log.info("Shared expense created id={} creator={} total={}", savedExpense.getId(), savedExpense.getCreatorUserId(), savedExpense.getTotalAmount());
        return new CreateSharedExpenseResponse(savedExpense.getId(), savedExpense.getCreatedAt());
    }

    /** Returns net pending balances for the authenticated user against each counterpart. */
    @Transactional(readOnly = true)
    public PendingBalancesResponse getPendingBalances(String callerUserId, String userId) {
        authGuard.assertCallerMatches(callerUserId, userId);
        List<BalanceEntryEntity> entries = balanceEntryRepository.findByDebtorUserIdOrCreditorUserId(userId, userId);

        Map<String, BigDecimal> netByCounterpart = new HashMap<>();
        for (BalanceEntryEntity entry : entries) {
            if (userId.equals(entry.getCreditorUserId())) {
                netByCounterpart.merge(entry.getDebtorUserId(), entry.getAmount(), BigDecimal::add);
            } else {
                netByCounterpart.merge(entry.getCreditorUserId(), entry.getAmount().negate(), BigDecimal::add);
            }
        }

        List<BalanceSummaryResponse> balances = netByCounterpart.entrySet().stream()
                .filter(e -> e.getValue().compareTo(BigDecimal.ZERO) != 0)
                .map(e -> {
                    BigDecimal net = e.getValue().setScale(2, RoundingMode.HALF_UP);
                    if (net.compareTo(BigDecimal.ZERO) > 0) {
                        return new BalanceSummaryResponse(e.getKey(), "OWED_TO_YOU", net);
                    }
                    return new BalanceSummaryResponse(e.getKey(), "YOU_OWE", net.abs());
                })
                .sorted(Comparator.comparing(BalanceSummaryResponse::counterpartUserId))
                .toList();

        return new PendingBalancesResponse(userId, balances);
    }

    private void validateParticipants(CreateSharedExpenseRequest request) {
        if (request.participants().size() < 2) {
            throw new BadRequestException("Shared expense must include at least 2 participants");
        }
        boolean creatorIncluded = request.participants().stream().anyMatch(p -> p.userId().equals(request.creatorUserId()));
        if (!creatorIncluded) {
            throw new BadRequestException("Participants must include expense creator");
        }
    }

    private Map<String, BigDecimal> calculateShares(CreateSharedExpenseRequest request) {
        if (request.splitType() == SplitType.EQUAL) {
            return calculateEqualShares(request);
        }
        return calculateCustomShares(request);
    }

    private Map<String, BigDecimal> calculateEqualShares(CreateSharedExpenseRequest request) {
        int size = request.participants().size();
        BigDecimal total = request.totalAmount().setScale(2, RoundingMode.HALF_UP);
        BigDecimal base = total.divide(BigDecimal.valueOf(size), 2, RoundingMode.DOWN);
        BigDecimal remainder = total.subtract(base.multiply(BigDecimal.valueOf(size)));

        Map<String, BigDecimal> shares = new HashMap<>();
        for (int i = 0; i < size; i++) {
            ParticipantShareRequest participant = request.participants().get(i);
            BigDecimal share = i == 0 ? base.add(remainder) : base;
            shares.put(participant.userId(), share);
        }
        return shares;
    }

    private Map<String, BigDecimal> calculateCustomShares(CreateSharedExpenseRequest request) {
        Map<String, BigDecimal> shares = new HashMap<>();
        BigDecimal total = BigDecimal.ZERO;
        for (ParticipantShareRequest participant : request.participants()) {
            if (participant.shareAmount() == null) {
                throw new BadRequestException("Custom split requires share amount for each participant");
            }
            BigDecimal normalized = participant.shareAmount().setScale(2, RoundingMode.HALF_UP);
            shares.put(participant.userId(), normalized);
            total = total.add(normalized);
        }
        if (total.compareTo(request.totalAmount().setScale(2, RoundingMode.HALF_UP)) != 0) {
            throw new BadRequestException("Custom split amounts must sum exactly to total amount");
        }
        return shares;
    }
}
