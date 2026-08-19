package com.fintrack.api.expense.repository;

import com.fintrack.api.expense.model.BalanceEntryEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface BalanceEntryRepository extends JpaRepository<BalanceEntryEntity, Long> {
    List<BalanceEntryEntity> findByDebtorUserIdOrCreditorUserId(String debtorUserId, String creditorUserId);
}
