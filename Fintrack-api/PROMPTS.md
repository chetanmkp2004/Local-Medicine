# Copilot Prompt Chain

## Prompt 1
- **Exact text:** "Generate a Transaction model and a Transaction service with create, get-by-user, and delete-all functions. Use a database."
- **Copilot feature:** Copilot Chat
- **Technique:** Constraint-based (minimal instruction)
- **Rationale:** Reproduced the inherited low-quality generation scenario as required.

## Prompt 2
- **Exact text:** "Refactor this transaction module into model/repository/service/controller layers using FastAPI and SQLAlchemy ORM with strict user ownership checks."
- **Copilot feature:** Copilot Chat + inline suggestions
- **Technique:** Specificity + decomposition
- **Rationale:** Broke remediation into architecture and auth concerns for more reliable output.

## Prompt 3
- **Exact text:** "Implement shared expense creation supporting equal and custom split types, with validation that custom shares equal total."
- **Copilot feature:** Copilot Chat
- **Technique:** Role-based (fintech backend engineer) + constraints
- **Rationale:** Focused generation on financial correctness and explicit validation rules.

## Prompt 4
- **Exact text:** "Generate balance-netting logic per counterparty where positive net means they owe current user."
- **Copilot feature:** Copilot Chat
- **Technique:** Iterative refinement
- **Rationale:** Refined business rules separately from persistence for correctness.

## Prompt 5
- **Exact text:** "Create pytest API tests for equal split, custom split success/failure, netting, one-participant edge case, and unauthorized access."
- **Copilot feature:** Copilot Chat + test generation
- **Technique:** Specificity
- **Rationale:** Ensured all required scenarios were explicitly covered.

## Prompt 6
- **Exact text:** "Rewrite route handlers to convert domain ValidationError into HTTP 400 and keep auth failures at 401."
- **Copilot feature:** Inline completion
- **Technique:** Constraint-based iterative correction
- **Rationale:** Locked in stable API error contract behavior.

## Copilot Features Used
1. Copilot Chat
2. Inline code completion
3. Test generation in Chat

## Prompting Techniques Used
1. Specificity
2. Decomposition
3. Constraint-based prompting
4. Role-based prompting
5. Iterative refinement

## Post-Generation Corrections
- Replaced unsafe user-id parameter access with authenticated header dependency.
- Added missing validation for amount positivity, participant count, duplicate participants, and custom sum checks.
- Corrected rounding behavior for equal split residual handling.
- Added structured logging, domain exceptions, and consistent HTTP error mapping.
- Added authorization-focused test ensuring users cannot read each other’s transactions.
- Saved the full prompt chain in this file as the project’s prompt reference log.
