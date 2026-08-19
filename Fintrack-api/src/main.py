"""FastAPI application entrypoint."""

from fastapi import FastAPI

from src.core.database import Base, engine
from src.expense_splitting.controller import router as expense_router
from src.transactions.controller import router as transactions_router
# Ensure ORM models are imported before table creation.
from src.expense_splitting import model as _expense_models  # noqa: F401
from src.transactions import model as _transaction_models  # noqa: F401

app = FastAPI(title="Fintrack API", version="1.0.0")

Base.metadata.create_all(bind=engine)

app.include_router(transactions_router)
app.include_router(expense_router)


@app.get("/health")
def health_check() -> dict[str, str]:
    """Return service health status."""
    return {"status": "ok"}
