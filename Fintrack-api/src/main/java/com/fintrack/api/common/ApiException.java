package com.fintrack.api.common;

/** Base API exception with HTTP status code mapping support. */
public class ApiException extends RuntimeException {
    private final int status;

    public ApiException(String message, int status) {
        super(message);
        this.status = status;
    }

    public int getStatus() {
        return status;
    }
}
