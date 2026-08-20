package com.fintrack.api.expense.model;

import jakarta.persistence.*;

import java.math.BigDecimal;

@Entity
@Table(name = "expense_participants")
public class ExpenseParticipantEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(optional = false)
    @JoinColumn(name = "expense_id")
    private SharedExpenseEntity expense;

    @Column(nullable = false)
    private String participantUserId;

    @Column(nullable = false, precision = 19, scale = 2)
    private BigDecimal shareAmount;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public SharedExpenseEntity getExpense() { return expense; }
    public void setExpense(SharedExpenseEntity expense) { this.expense = expense; }
    public String getParticipantUserId() { return participantUserId; }
    public void setParticipantUserId(String participantUserId) { this.participantUserId = participantUserId; }
    public BigDecimal getShareAmount() { return shareAmount; }
    public void setShareAmount(BigDecimal shareAmount) { this.shareAmount = shareAmount; }
}
