# ARCHITECTURE.md

Transaction and Expense Splitting are separate modules inside one Spring Boot API.
Transactions provide user-scoped money records and serve as adjacent financial capability.
Expense Splitting builds shared-expense logic and writes balance entries derived from participant shares.
Controllers accept REST requests, validate DTOs, and delegate to services.
Services enforce business rules, authorization, and money calculations.
Repositories isolate persistence using Spring Data JPA ORM entities.
Shared exception handling provides consistent error responses across modules.
AuthGuard centralizes caller identity checks using `X-User-Id`.
Data flow: request -> controller -> service validation/rules -> repository writes/reads -> response DTO.
Balance netting is computed from stored debtor/creditor entries per user-counterpart pair.
This architecture is appropriate for fintech because it prioritizes correctness, traceability, and isolation.
Using `BigDecimal` avoids floating-point errors in financial values.
Layering limits blast radius and makes audits/testing of critical logic easier.
Explicit ownership checks reduce unauthorized data access risk.
The design keeps extension points open for real identity providers and external databases.
