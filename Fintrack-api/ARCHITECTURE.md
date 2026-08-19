# Architecture

Transaction and Expense Splitting are separate modules that share core infrastructure (database, auth, logging, error contracts).
Transaction handles personal ledger entries per authenticated user.
Expense Splitting handles shared expenses and participant allocations.
Both modules follow layered flow: controller -> service -> repository -> ORM model.
Controllers map HTTP contracts and dependency injection.
Services enforce business rules, ownership boundaries, and financial validations.
Repositories encapsulate ORM persistence and query logic.
SharedExpense references participants through a one-to-many relation for split details.
Pending balances are computed in service logic from stored expenses and participant shares.
Netting is calculated per counterparty to provide who-owes-whom summaries.
This architecture is appropriate for fintech because it isolates critical monetary logic in testable service code.
It improves auditability through explicit logging and deterministic validation behavior.
It supports security by binding all reads/writes to authenticated user context.
The design is extensible for future settlement workflows and external payment integrations.
