"""Service layer for shared expense calculations."""

from collections import defaultdict

from sqlalchemy.orm import Session

from src.core.errors import ValidationError
from src.core.logging_config import get_logger
from src.expense_splitting.repository import SharedExpenseRepository
from src.expense_splitting.schemas import BalanceResponse, SharedExpenseCreate

logger = get_logger(__name__)


class SharedExpenseService:
    """Coordinates split validation, creation, and net balance calculations."""

    def __init__(self, repository: SharedExpenseRepository | None = None) -> None:
        """Initialize service with repository dependency."""
        self.repository = repository or SharedExpenseRepository()

    def create_shared_expense(self, db: Session, *, creator_id: str, payload: SharedExpenseCreate):
        """Create a shared expense with equal or custom split validation."""
        if len(payload.participants) < 2:
            raise ValidationError("At least 2 participants are required")

        participant_ids = [p.user_id for p in payload.participants]
        if len(set(participant_ids)) != len(participant_ids):
            raise ValidationError("Participant list contains duplicates")

        if creator_id not in participant_ids:
            raise ValidationError("Creator must be included in participants")

        participants: list[dict[str, str | float]] = []
        total_amount = round(payload.total_amount, 2)

        if payload.split_type == "equal":
            equal_share = round(total_amount / len(payload.participants), 2)
            shares = [equal_share for _ in payload.participants]
            diff = round(total_amount - sum(shares), 2)
            shares[-1] = round(shares[-1] + diff, 2)
            for participant, share in zip(payload.participants, shares, strict=True):
                participants.append({"user_id": participant.user_id, "share_amount": share})
        else:
            if any(p.share_amount is None for p in payload.participants):
                raise ValidationError("All custom split participants must include share_amount")
            custom_total = round(sum(float(p.share_amount or 0) for p in payload.participants), 2)
            if custom_total != total_amount:
                raise ValidationError("Custom split amounts must sum exactly to total_amount")
            for participant in payload.participants:
                participants.append({"user_id": participant.user_id, "share_amount": round(float(participant.share_amount or 0), 2)})

        logger.info(
            "create_shared_expense creator_id=%s split_type=%s total=%.2f participants=%d",
            creator_id,
            payload.split_type,
            total_amount,
            len(participants),
        )

        return self.repository.create_expense(
            db,
            creator_id=creator_id,
            description=payload.description.strip(),
            total_amount=total_amount,
            split_type=payload.split_type,
            participants=participants,
        )

    def get_pending_balances(self, db: Session, *, user_id: str) -> list[BalanceResponse]:
        """Compute pending balances and net summary per counterparty for user."""
        expenses = self.repository.get_expenses_for_user(db, user_id=user_id)
        ledger: dict[str, dict[str, float]] = defaultdict(lambda: {"owed_to_them": 0.0, "they_owe_you": 0.0})

        for expense in expenses:
            creator = expense.creator_id
            for participant in expense.participants:
                if participant.user_id == creator:
                    continue
                amount = round(participant.share_amount, 2)
                debtor = participant.user_id

                if user_id == debtor:
                    ledger[creator]["owed_to_them"] += amount
                elif user_id == creator:
                    ledger[debtor]["they_owe_you"] += amount

        results: list[BalanceResponse] = []
        for counterparty, values in sorted(ledger.items()):
            owed = round(values["owed_to_them"], 2)
            owed_you = round(values["they_owe_you"], 2)
            net = round(owed_you - owed, 2)
            results.append(
                BalanceResponse(
                    counterparty=counterparty,
                    owed_to_them=owed,
                    they_owe_you=owed_you,
                    net=net,
                )
            )

        logger.info("get_pending_balances user_id=%s counterparties=%d", user_id, len(results))
        return results
