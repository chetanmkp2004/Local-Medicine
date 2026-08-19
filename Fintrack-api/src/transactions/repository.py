"""Repository layer for transaction persistence."""

from sqlalchemy import delete, select
from sqlalchemy.orm import Session

from src.transactions.model import Transaction


class TransactionRepository:
    """Handles ORM operations for transactions."""

    def create(self, db: Session, *, user_id: str, description: str, amount: float) -> Transaction:
        """Persist and return a new transaction."""
        transaction = Transaction(user_id=user_id, description=description, amount=amount)
        db.add(transaction)
        db.commit()
        db.refresh(transaction)
        return transaction

    def get_by_user(self, db: Session, *, user_id: str) -> list[Transaction]:
        """Return all transactions owned by the provided user."""
        return list(db.scalars(select(Transaction).where(Transaction.user_id == user_id).order_by(Transaction.id.desc())))

    def delete_all_for_user(self, db: Session, *, user_id: str) -> int:
        """Delete and return count of transactions owned by the provided user."""
        rows = db.execute(delete(Transaction).where(Transaction.user_id == user_id))
        db.commit()
        return rows.rowcount or 0
