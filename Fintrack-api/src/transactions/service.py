"""Service layer for transaction business logic."""

from sqlalchemy.orm import Session

from src.core.logging_config import get_logger
from src.core.errors import ValidationError
from src.transactions.repository import TransactionRepository
from src.transactions.schemas import TransactionCreate

logger = get_logger(__name__)


class TransactionService:
    """Coordinates transaction use-cases."""

    def __init__(self, repository: TransactionRepository | None = None) -> None:
        """Initialize service with repository dependency."""
        self.repository = repository or TransactionRepository()

    def create_transaction(self, db: Session, *, user_id: str, payload: TransactionCreate):
        """Validate and create a user-owned transaction."""
        if payload.amount <= 0:
            raise ValidationError("Transaction amount must be greater than zero")
        logger.info("create_transaction user_id=%s amount=%.2f", user_id, payload.amount)
        return self.repository.create(
            db,
            user_id=user_id,
            description=payload.description.strip(),
            amount=round(payload.amount, 2),
        )

    def get_transactions_for_user(self, db: Session, *, user_id: str):
        """Return all transactions for an authenticated user."""
        logger.info("get_transactions_for_user user_id=%s", user_id)
        return self.repository.get_by_user(db, user_id=user_id)

    def delete_all_transactions_for_user(self, db: Session, *, user_id: str) -> int:
        """Delete all transactions for an authenticated user and return deleted count."""
        logger.info("delete_all_transactions_for_user user_id=%s", user_id)
        return self.repository.delete_all_for_user(db, user_id=user_id)
