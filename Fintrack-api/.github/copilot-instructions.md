# Copilot Instructions for Fintrack-api

## Stack
- Java 17 with Spring Boot 3
- Spring Data JPA with ORM entities and repositories
- REST APIs using Spring MVC
- Bean validation for request DTOs
- JUnit 5 + MockMvc integration tests

## Architecture
- Layered architecture: controller -> service -> repository -> model
- DTOs for all request/response contracts
- Domain entities isolated from API contracts
- Global exception handler for consistent error responses

## Coding Standards
- Use constructor injection only
- Public methods must include JavaDoc
- Use BigDecimal for money values
- Avoid raw types and unchecked casts
- Keep methods small and single-purpose

## Security Rules
- Never trust caller-supplied user IDs without header-based authorization checks
- Enforce ownership checks at service layer for every user-scoped read/write
- Never expose internal exception details in API responses
- No secrets in source code or logs

## Testing Expectations
- Cover positive and negative scenarios
- Validate authorization failures and validation errors
- Add regression tests for every bug fix
- Use deterministic test data and assert exact monetary outcomes
