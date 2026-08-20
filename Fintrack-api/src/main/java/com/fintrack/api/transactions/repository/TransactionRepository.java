package com.fintrack.api.transactions.repository;

import com.fintrack.api.transactions.model.TransactionEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface TransactionRepository extends JpaRepository<TransactionEntity, Long> {
    List<TransactionEntity> findByUserIdOrderByCreatedAtDesc(String userId);
    void deleteByUserId(String userId);
}
