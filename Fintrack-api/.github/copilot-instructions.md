# Copilot Instructions - Fintrack API

## Stack and Architecture
- Use Python 3.11+, FastAPI, SQLAlchemy ORM, and Pydantic.
- Follow layered architecture: controller -> service -> repository -> model.
- Keep business logic in services and persistence logic in repositories.

## Coding Standards
- Use type hints on all functions and methods.
- Add docstrings for all public functions, classes, and methods.
- Use clear domain errors with explicit HTTP mapping.
- Keep files focused and avoid mixed responsibilities.

## Security Rules
- Never trust client-provided user identity from body/query for protected data access.
- Use header-based authenticated user context (`X-User-Id`) for this project.
- Enforce ownership checks on all transaction and balance reads.
- Validate all financial inputs (positive totals, participant counts, split consistency).

## Testing Expectations
- Add/update pytest coverage for happy path, validation failures, auth failures, and edge cases.
- For monetary comparisons, use consistent rounding and tolerance checks.

## Prompt Capture Rule
- Save every Copilot prompt used during development in `PROMPTS.md` with exact wording and rationale.
