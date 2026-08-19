# PR Description

## Summary
Implemented a production-ready Transaction module remediation and added a new Expense Splitting feature with equal/custom split support, pending balances, and net-per-person summaries for authenticated users.

## AI Tool Disclosure
- **Copilot features used:** Copilot Chat, inline completion, chat-based test generation, and custom project instructions.
- **Accepted AI output:** Initial scaffolding for model/service shapes and baseline test skeletons.
- **Overrode AI output:** Ownership/auth rules, validation logic, layered boundaries, and balance-netting semantics.
- **Estimated contribution:** ~35% AI-generated scaffolding, ~65% hand-written/hand-corrected implementation.

## Testing Coverage
- Added 7 API integration tests (includes all 6 required scenarios plus transaction ownership isolation).
- Covered equal split, custom split valid/invalid, netting across multiple expenses, one-participant rejection, unauthorized access, and transaction ownership filtering.

## Known Gaps
- No async task queue for notifications/reminders yet.
- SQLite is default for local dev; production should switch to managed Postgres.

## Risk / Trade-off
- Rounding is handled to two decimals with residual allocation on equal splits; this is deterministic but may not match all business policies for fractional cent distribution.

## Self-Review Checklist
- [x] Layered architecture enforced
- [x] ORM-only data access (no raw DB driver)
- [x] Auth and ownership checks present
- [x] Validation and explicit error handling present
- [x] Logging added to core business operations
- [x] Required tests added and passing
- [x] Documentation artifacts completed

## Peer Review Simulation
1. **File:** `src/expense_splitting/service.py` (equal split branch)
   - **Comment:** Consider extracting residual-rounding into a helper so the policy is reusable and easier to unit-test.
   - **Why:** Current inline logic is correct but harder to audit when policy changes.

2. **File:** `src/transactions/controller.py` (`delete_all_transactions`)
   - **Comment:** Return `204 No Content` for empty and non-empty delete operations to align with REST conventions.
   - **Why:** Consumers currently parse a response body just to confirm deletion count.

3. **File:** `src/core/auth.py`
   - **Comment:** Add signed token verification before trusting `X-User-Id`; header-only identity is insecure outside local/dev.
   - **Why:** AI tools often accept simplistic auth placeholders that are unsafe for real fintech deployments.
