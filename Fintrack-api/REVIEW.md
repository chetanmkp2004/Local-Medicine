# REVIEW.md - Transaction Module Code Review

## Review Scope
Reviewed inherited AI-generated files in `/src/transactions/Transaction.java` and `/src/transactions/TransactionService.java`.

## Findings

### 1) Public mutable fields in model
- **Where:** `src/transactions/Transaction.java`
- **Severity:** High
- **Impact:** Any caller can mutate persisted transaction state without validation, causing audit and integrity failures in fintech flows.
- **Detection:** Manual code inspection; Copilot suggested standard POJO patterns but did not flag integrity risk.
- **Fix:** Replaced with JPA entity with private fields, typed money (`BigDecimal`), controlled persistence, and timestamp control.

### 2) Floating-point currency handling (`double`)
- **Where:** `src/transactions/Transaction.java`
- **Severity:** Critical
- **Impact:** Rounding drift in money values can produce incorrect balances and reconciliation defects.
- **Detection:** Human judgment based on fintech domain requirements.
- **Fix:** Use `BigDecimal` with fixed scale in remediated module.

### 3) In-memory static map as pseudo database
- **Where:** `src/transactions/TransactionService.java`
- **Severity:** Critical
- **Impact:** Data loss on restart, no transactional guarantees, and race conditions under concurrency.
- **Detection:** Architectural review and runtime-risk assessment.
- **Fix:** Replaced with Spring Data JPA repository and transactional service.

### 4) No authorization checks
- **Where:** `src/transactions/TransactionService.java`
- **Severity:** Critical
- **Impact:** Any user can read or mutate another user's transactions.
- **Detection:** Threat modeling + endpoint ownership requirements.
- **Fix:** Introduced `AuthGuard` and enforced caller/target matching on all user-scoped operations.

### 5) Missing input validation and error handling
- **Where:** inherited transaction service/model
- **Severity:** High
- **Impact:** Invalid records and generic failures propagate to clients, increasing fraud and reliability risk.
- **Detection:** Validation checklist and negative-case review.
- **Fix:** Added request DTO constraints and global exception handler with stable error responses.

### 6) Delete-all operation with global blast radius
- **Where:** `deleteAll()` in inherited service
- **Severity:** Critical
- **Impact:** Single call can wipe all users' transactions.
- **Detection:** API behavior analysis and abuse-case review.
- **Fix:** Scoped deletion to authenticated user's own transactions only.

### 7) Missing logging and observability
- **Where:** inherited service
- **Severity:** Medium
- **Impact:** Hard to trace financial state transitions and incidents.
- **Detection:** Operational-readiness review.
- **Fix:** Added structured service logs for create/delete operations.

## Review Process
1. Preserved generated files as unreviewed baseline.
2. Performed manual security + data integrity review.
3. Used Copilot for draft refactor options and test scaffolding.
4. Applied human review for domain-critical controls (money precision, authorization, blast-radius limits).

## Issues Copilot Introduced That Required Human Judgment
- Chose `double` for currency despite fintech domain.
- Generated global delete behavior (`deleteAll`) without tenant scoping.
- Omitted authorization logic and trusted user IDs blindly.
- Used mutable model and non-persistent fake storage while claiming database intent.
- Did not model failure boundaries or standardized API errors.
