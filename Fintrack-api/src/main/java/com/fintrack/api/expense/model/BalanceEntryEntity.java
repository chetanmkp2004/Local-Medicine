package com.fintrack.api.expense.model;

import jakarta.persistence.*;

import java.math.BigDecimal;
import java.time.Instant;

@Entity
@Table(name = "balance_entries")
public class BalanceEntryEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(optional = false)
    @JoinColumn(name = "expense_id")
    private SharedExpenseEntity expense;

    @Column(nullable = false)
    private String debtorUserId;

    @Column(nullable = false)
    private String creditorUserId;

    @Column(nullable = false, precision = 19, scale = 2)
    private BigDecimal amount;

    @Column(nullable = false)
    private Instant createdAt;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public SharedExpenseEntity getExpense() { return expense; }
    public void setExpense(SharedExpenseEntity expense) { this.expense = expense; }
    public String getDebtorUserId() { return debtorUserId; }
    public void setDebtorUserId(String debtorUserId) { this.debtorUserId = debtorUserId; }
    public String getCreditorUserId() { return creditorUserId; }
    public void setCreditorUserId(String creditorUserId) { this.creditorUserId = creditorUserId; }
    public BigDecimal getAmount() { return amount; }
    public void setAmount(BigDecimal amount) { this.amount = amount; }
    public Instant getCreatedAt() { return createdAt; }
    public void setCreatedAt(Instant createdAt) { this.createdAt = createdAt; }
}
