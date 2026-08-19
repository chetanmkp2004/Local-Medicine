"""Schemas for transaction module."""

from datetime import datetime

from pydantic import BaseModel, Field


class TransactionCreate(BaseModel):
    """Payload for creating a transaction."""

    description: str = Field(min_length=1, max_length=255)
    amount: float = Field(gt=0)


class TransactionResponse(BaseModel):
    """Serialized transaction response."""

    id: int
    user_id: str
    description: str
    amount: float
    created_at: datetime

    model_config = {"from_attributes": True}
