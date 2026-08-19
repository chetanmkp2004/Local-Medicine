# PROMPTS.md

## Prompt Chain Used

1. **Exact Prompt:** "Generate a Transaction model and a Transaction service with create, get-by-user, and delete-all functions. Use a database."
   - **Copilot Feature:** Copilot Chat (inline generation)
   - **Technique:** Constraint prompt (minimal, intentionally low-effort)
   - **Rationale:** Reproduced inherited unreviewed AI output exactly as required.

2. **Exact Prompt:** "Review this generated transaction code for fintech risks: security, money precision, data integrity, and multi-user isolation."
   - **Copilot Feature:** Copilot Chat (code review conversation)
   - **Technique:** Role-based + specificity
   - **Rationale:** Forced risk framing aligned to regulated financial behavior.

3. **Exact Prompt:** "Refactor transaction code into Spring layered architecture with entity, repository, service, controller, DTO validation, and ownership checks using header user identity."
   - **Copilot Feature:** Copilot Chat (multi-file refactor suggestions)
   - **Technique:** Decomposition + constraints
   - **Rationale:** Broke remediation into explicit architecture responsibilities.

4. **Exact Prompt:** "Design expense splitting service for EQUAL and CUSTOM splits, validate custom sums, and compute net balances between users."
   - **Copilot Feature:** Copilot Chat
   - **Technique:** Specificity + iterative refinement
   - **Rationale:** Captured core business rules and refined edge handling.

5. **Exact Prompt:** "Generate integration test scenarios for equal split, valid custom split, invalid custom split, netting over multiple expenses, one participant edge, and unauthorized access."
   - **Copilot Feature:** Copilot Chat + test generation assistance
   - **Technique:** Constraint-based acceptance criteria
   - **Rationale:** Guaranteed direct mapping to delivery checklist tests.

6. **Exact Prompt:** "Create concise project docs for architecture, tool strategy, and PR summary including AI disclosure and risks."
   - **Copilot Feature:** Copilot Chat (documentation drafting)
   - **Technique:** Structured output constraints
   - **Rationale:** Produced consistent sprint artifacts quickly while preserving manual review.

## Prompting Techniques Demonstrated
- Specificity
- Decomposition
- Constraint-based prompting
- Role-based prompting
- Iterative refinement

## Copilot Features Demonstrated
- Copilot Chat (design, refactor, review)
- Copilot inline completion (code drafting)
- Copilot test generation assistance
- Copilot docs drafting support

## Post-Generation Corrections
- Replaced floating-point money handling with `BigDecimal` and scale control.
- Removed global delete-all behavior and scoped deletes to authenticated user only.
- Added explicit authorization checks to prevent cross-user access.
- Replaced in-memory static map with ORM repositories and transactions.
- Added global exception mapping for stable API error responses.
- Added business validation for participant count, creator inclusion, and custom split sum matching.
