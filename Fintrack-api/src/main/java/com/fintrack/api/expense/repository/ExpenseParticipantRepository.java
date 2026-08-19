package com.fintrack.api.expense.repository;

import com.fintrack.api.expense.model.ExpenseParticipantEntity;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ExpenseParticipantRepository extends JpaRepository<ExpenseParticipantEntity, Long> {
}
