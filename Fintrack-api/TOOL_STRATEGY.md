# TOOL STRATEGY.md

## Feature Usage Log
1. Used Copilot Chat to generate initial transaction baseline quickly to simulate inherited teammate output.
2. Used Copilot Chat in review mode to enumerate security and fintech integrity concerns before refactoring.
3. Used Copilot inline completion for repetitive entity/repository scaffolding to reduce manual boilerplate errors.
4. Used Copilot Chat decomposition prompts to separate controller/service/repository responsibilities.
5. Used Copilot test generation support to draft scenario-aligned integration test skeletons.
6. Used Copilot documentation drafting support to structure sprint artifacts consistently.

## Scenario Responses
1. **Complex 500-line function understanding:** Use Copilot Chat with selected code context to request step-by-step flow and side-effect mapping.
2. **Consistent error handling across 8 routes:** Use Copilot Edits/Chat refactor prompt to apply a shared exception strategy and normalized responses in batch.
3. **Regex verification for international numbers:** Use Copilot Chat plus generated example sets/tests to validate pattern behavior against diverse country formats.
4. **Automated code quality on each PR:** Use GitHub Actions with Copilot-generated workflow YAML and quality gates (test/lint/security) for fully automated enforcement.
5. **Security review of AI auth module:** Use Copilot Chat security-focused review prompt, then manually validate findings with threat modeling and exploit paths.
6. **Consistent project conventions across sessions:** Use `.github/copilot-instructions.md` so Copilot outputs remain aligned to architecture and standards.

## Limitations Encountered
1. Prompt: "Generate a Transaction model and service..."
   - **Issue:** Returned unsafe money type (`double`) and weak data model.
   - **Detection:** Manual fintech correctness check.
   - **Fix:** Migrated to `BigDecimal` and JPA entity constraints.
   - **Next time:** Add strict currency handling constraints in first prompt.

2. Prompt: "Add delete-all function"
   - **Issue:** Produced globally destructive behavior without tenancy boundaries.
   - **Detection:** Abuse-case and authorization review.
   - **Fix:** Scoped delete to authenticated user only.
   - **Next time:** Specify ownership enforcement requirements explicitly.

3. Prompt: "Compute balances"
   - **Issue:** Initial draft omitted creator-in-participants validation.
   - **Detection:** Edge-case walkthrough.
   - **Fix:** Added business validation to require creator in participant set.
   - **Next time:** Include domain invariants as prompt constraints upfront.
