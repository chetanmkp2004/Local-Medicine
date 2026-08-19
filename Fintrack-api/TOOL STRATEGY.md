# Tool Strategy

## Feature Usage Log
1. **Copilot Chat:** generated initial transaction model/service quickly to simulate inherited AI code; result required hardening.
2. **Inline completion:** accelerated repetitive schema/repository typing; reduced boilerplate time.
3. **Copilot Chat refactor prompt:** converted mixed logic into layered architecture; gave good scaffold, needed manual security edits.
4. **Copilot test generation:** produced baseline test scenarios; assertions were refined for financial semantics.
5. **Project custom instructions:** improved consistency of type hints/docstrings/error patterns across files.
6. **Iterative chat corrections:** used follow-up prompts to tighten auth and validation after spotting gaps.

## Scenario Responses
1. **Complex 500-line function understanding:** Use **Copilot Chat (Ask/Explain in Editor)** to summarize control flow and side effects before editing; it accelerates orientation while preserving context.
2. **Consistent error handling across 8 routes:** Use **Copilot Edits / multi-file edit in Chat** to apply uniform error wrapper patterns across handlers with shared constraints.
3. **Regex international phone verification:** Use **Copilot Chat + test generation** to propose cases and quickly iterate the regex against edge examples.
4. **Automated quality checks on every PR:** Use **GitHub Actions + Copilot Autofix awareness**; Actions enforces policy without human intervention and Copilot can assist fixing failures.
5. **Security review of AI auth module:** Use **Copilot code review + security-focused prompt in Chat** for first-pass findings, then manual threat modeling for IDOR/auth bypass.
6. **Consistent project conventions across sessions:** Use **repository `.github/copilot-instructions.md`** so Copilot output follows shared architecture and testing rules.

## Limitations Encountered
1. **Prompt:** initial low-effort transaction generation prompt.
   - **What went wrong:** output lacked ownership checks and validation.
   - **How detected:** manual fintech security review.
   - **Fix:** replaced with auth-bound service/controller and strict validation.
   - **Next time:** start with constrained prompts including security requirements.

2. **Prompt:** equal/custom split generation.
   - **What went wrong:** first draft ignored rounding residual edge cases.
   - **How detected:** manual arithmetic walkthrough.
   - **Fix:** deterministic residual adjustment on last participant.
   - **Next time:** explicitly require cent-level reconciliation policy in prompt.

3. **Prompt:** auto-generated tests.
   - **What went wrong:** generated tests asserted status only, not balance semantics.
   - **How detected:** review against product acceptance criteria.
   - **Fix:** added assertions for owed_to_them, they_owe_you, and net values.
   - **Next time:** ask for assertion-rich tests tied to business outcomes.
