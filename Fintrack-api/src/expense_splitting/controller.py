"""HTTP routes for expense splitting and balances."""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from src.core.auth import get_current_user_id
from src.core.database import get_db
from src.core.errors import ValidationError
from src.expense_splitting.schemas import BalanceResponse, SharedExpenseCreate, SharedExpenseResponse
from src.expense_splitting.service import SharedExpenseService

router = APIRouter(tags=["expense-splitting"])
service = SharedExpenseService()


@router.post("/shared-expenses", response_model=SharedExpenseResponse, status_code=status.HTTP_201_CREATED)
def create_shared_expense(
    payload: SharedExpenseCreate,
    db: Session = Depends(get_db),
    user_id: str = Depends(get_current_user_id),
):
    """Create a shared expense for authenticated user."""
    try:
        return service.create_shared_expense(db, creator_id=user_id, payload=payload)
    except ValidationError as exc:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(exc)) from exc


@router.get("/balances", response_model=list[BalanceResponse])
def get_pending_balances(
    db: Session = Depends(get_db),
    user_id: str = Depends(get_current_user_id),
):
    """Get pending balances and per-person net summary for authenticated user."""
    return service.get_pending_balances(db, user_id=user_id)
