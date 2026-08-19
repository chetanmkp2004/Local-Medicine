package com.fintrack.api.auth;

import com.fintrack.api.common.ForbiddenException;
import org.springframework.stereotype.Component;

/** Validates caller identity from request headers. */
@Component
public class AuthGuard {

    /** Ensures the caller user id matches the target user id. */
    public void assertCallerMatches(String callerUserId, String targetUserId) {
        if (callerUserId == null || callerUserId.isBlank()) {
            throw new ForbiddenException("Missing X-User-Id header");
        }
        if (!callerUserId.equals(targetUserId)) {
            throw new ForbiddenException("Unauthorized access to another user's data");
        }
    }
}
