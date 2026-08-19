"""HTTP routes for transaction module."""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from src.core.auth import get_current_user_id
from src.core.database import get_db
from src.core.errors import ValidationError
from src.transactions.schemas import TransactionCreate, TransactionResponse
from src.transactions.service import TransactionService

router = APIRouter(prefix="/transactions", tags=["transactions"])
service = TransactionService()


@router.post("", response_model=TransactionResponse, status_code=status.HTTP_201_CREATED)
def create_transaction(
    payload: TransactionCreate,
    db: Session = Depends(get_db),
    user_id: str = Depends(get_current_user_id),
):
    """Create a transaction for the authenticated user."""
    try:
        return service.create_transaction(db, user_id=user_id, payload=payload)
    except ValidationError as exc:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(exc)) from exc


@router.get("", response_model=list[TransactionResponse])
def get_transactions(
    db: Session = Depends(get_db),
    user_id: str = Depends(get_current_user_id),
):
    """Get all transactions belonging to the authenticated user."""
    return service.get_transactions_for_user(db, user_id=user_id)


@router.delete("", status_code=status.HTTP_200_OK)
def delete_all_transactions(
    db: Session = Depends(get_db),
    user_id: str = Depends(get_current_user_id),
):
    """Delete all transactions belonging to the authenticated user."""
    deleted = service.delete_all_transactions_for_user(db, user_id=user_id)
    return {"deleted": deleted}
