"""Repository layer for shared expense persistence."""

from sqlalchemy import or_, select
from sqlalchemy.orm import Session, joinedload

from src.expense_splitting.model import ExpenseParticipant, SharedExpense


class SharedExpenseRepository:
    """Handles ORM operations for shared expenses."""

    def create_expense(
        self,
        db: Session,
        *,
        creator_id: str,
        description: str,
        total_amount: float,
        split_type: str,
        participants: list[dict[str, float | str]],
    ) -> SharedExpense:
        """Create a shared expense and participant splits."""
        expense = SharedExpense(
            creator_id=creator_id,
            description=description,
            total_amount=total_amount,
            split_type=split_type,
        )
        expense.participants = [
            ExpenseParticipant(user_id=str(item["user_id"]), share_amount=float(item["share_amount"]))
            for item in participants
        ]
        db.add(expense)
        db.commit()
        db.refresh(expense)
        return expense

    def get_expenses_for_user(self, db: Session, *, user_id: str) -> list[SharedExpense]:
        """Return all shared expenses where user is creator or participant."""
        stmt = (
            select(SharedExpense)
            .options(joinedload(SharedExpense.participants))
            .outerjoin(ExpenseParticipant, ExpenseParticipant.expense_id == SharedExpense.id)
            .where(or_(SharedExpense.creator_id == user_id, ExpenseParticipant.user_id == user_id))
            .order_by(SharedExpense.id.desc())
        )
        return list(db.scalars(stmt).unique())
