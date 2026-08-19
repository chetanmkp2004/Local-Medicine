"""Lightweight auth dependency for request user context."""

from fastapi import Header, HTTPException, status


def get_current_user_id(x_user_id: str | None = Header(default=None, alias="X-User-Id")) -> str:
    """Return authenticated user id from request header."""
    if not x_user_id:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Missing X-User-Id header",
        )
    return x_user_id
