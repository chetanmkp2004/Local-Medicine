# PR Description

## Summary
Implemented a complete Java Spring Boot `Fintrack-api` module delivering expense splitting and a remediated transaction subsystem. The work includes project Copilot standards, risk-driven review documentation, production-grade layered backend code, required tests, and sprint documentation artifacts.

## Why
The feature enables shared expense tracking and user net-balance visibility, while also hardening previously unreviewed AI-generated transaction code before downstream usage.

## AI Tool Disclosure
- **Copilot features used:** Chat for review/refactor/design, inline completion for boilerplate, test drafting support, doc drafting support.
- **Accepted vs overridden:** Accepted structural drafts for DTO/entity/controller scaffolding; overrode security, money precision, validation, and authorization logic.
- **Estimated code origin:** ~45% AI-generated draft patterns, ~55% human-written/reworked logic.

## Testing Coverage
- Integration tests implemented for all requested scenarios:
  1. Equal split among 3 participants
  2. Valid custom split
  3. Invalid custom split sum
  4. Net balance over multiple expenses
  5. Single participant edge failure
  6. Unauthorized access failure

### Known Gaps
- No pagination/filtering for large balance datasets.
- No external identity provider integration (header-based identity is local simulation).

## Risk / Trade-off
Using per-expense balance entries with on-read net aggregation favors write simplicity and correctness, but may require optimization/caching for high-volume ledgers.

## Self-Review Checklist
- [x] Layered architecture enforced
- [x] ORM-only data access (no raw DB driver)
- [x] Fintech-safe money type (`BigDecimal`)
- [x] Authorization checks for user-scoped data
- [x] Input validation + specific error responses
- [x] Structured logging included
- [x] Required tests pass locally
- [x] Documentation artifacts completed

## Peer Review Simulation
1. **`src/main/java/com/fintrack/api/expense/service/ExpenseSplittingService.java`**
   - Consider deterministic sorting of balance responses before returning.
   - This improves API response stability and prevents flaky client assumptions.

2. **`src/main/java/com/fintrack/api/common/ApiExceptionHandler.java`**
   - Add correlation/request IDs into error responses or logs.
   - This will improve production incident tracing, which AI-generated code usually misses.

3. **`src/test/java/com/fintrack/api/ExpenseSplittingIntegrationTest.java`**
   - Add rounding-focused tests for equal split totals that are not evenly divisible.
   - This helps protect financial correctness for cent-level remainder behavior.
