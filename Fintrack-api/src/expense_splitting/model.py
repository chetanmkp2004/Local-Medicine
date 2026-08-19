"""ORM models for shared expenses and participants."""

from datetime import UTC, datetime
from enum import Enum

from sqlalchemy import DateTime, Float, ForeignKey, Integer, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from src.core.database import Base


class SplitType(str, Enum):
    """Supported split types."""

    EQUAL = "equal"
    CUSTOM = "custom"


class SharedExpense(Base):
    """Represents a shared expense created by a user."""

    __tablename__ = "shared_expenses"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    creator_id: Mapped[str] = mapped_column(String(64), index=True)
    description: Mapped[str] = mapped_column(String(255))
    total_amount: Mapped[float] = mapped_column(Float)
    split_type: Mapped[str] = mapped_column(String(20))
    created_at: Mapped[datetime] = mapped_column(DateTime, default=lambda: datetime.now(UTC))

    participants: Mapped[list["ExpenseParticipant"]] = relationship(
        back_populates="expense",
        cascade="all, delete-orphan",
    )


class ExpenseParticipant(Base):
    """Represents a participant and share in a shared expense."""

    __tablename__ = "expense_participants"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    expense_id: Mapped[int] = mapped_column(ForeignKey("shared_expenses.id", ondelete="CASCADE"), index=True)
    user_id: Mapped[str] = mapped_column(String(64), index=True)
    share_amount: Mapped[float] = mapped_column(Float)

    expense: Mapped[SharedExpense] = relationship(back_populates="participants")
