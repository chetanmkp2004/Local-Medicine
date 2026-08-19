"""Schemas for shared expense and balances."""

from datetime import datetime
from typing import Literal

from pydantic import BaseModel, Field


class ParticipantInput(BaseModel):
    """Participant payload entry for shared expense creation."""

    user_id: str = Field(min_length=1, max_length=64)
    share_amount: float | None = Field(default=None, ge=0)


class SharedExpenseCreate(BaseModel):
    """Payload for creating a shared expense."""

    description: str = Field(min_length=1, max_length=255)
    total_amount: float = Field(gt=0)
    split_type: Literal["equal", "custom"]
    participants: list[ParticipantInput]


class ParticipantResponse(BaseModel):
    """Serialized participant split response."""

    user_id: str
    share_amount: float

    model_config = {"from_attributes": True}


class SharedExpenseResponse(BaseModel):
    """Serialized shared expense response."""

    id: int
    creator_id: str
    description: str
    total_amount: float
    split_type: str
    created_at: datetime
    participants: list[ParticipantResponse]

    model_config = {"from_attributes": True}


class BalanceResponse(BaseModel):
    """Serialized net balance against a counterparty."""

    counterparty: str
    owed_to_them: float
    they_owe_you: float
    net: float
