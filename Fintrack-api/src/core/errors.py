"""Domain-level custom exceptions."""


class ValidationError(Exception):
    """Raised when domain validation fails."""


class AuthorizationError(Exception):
    """Raised when authorization rules fail."""
