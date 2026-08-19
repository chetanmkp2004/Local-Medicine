package com.fintrack.api.common;

/** Thrown when user attempts to access resources they do not own. */
public class ForbiddenException extends ApiException {
    public ForbiddenException(String message) {
        super(message, 403);
    }
}
