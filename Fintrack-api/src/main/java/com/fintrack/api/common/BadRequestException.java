package com.fintrack.api.common;

/** Thrown when a request violates business validation rules. */
public class BadRequestException extends ApiException {
    public BadRequestException(String message) {
        super(message, 400);
    }
}
