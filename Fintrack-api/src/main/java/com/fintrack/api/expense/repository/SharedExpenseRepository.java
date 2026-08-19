package com.fintrack.api.expense.repository;

import com.fintrack.api.expense.model.SharedExpenseEntity;
import org.springframework.data.jpa.repository.JpaRepository;

public interface SharedExpenseRepository extends JpaRepository<SharedExpenseEntity, Long> {
}
