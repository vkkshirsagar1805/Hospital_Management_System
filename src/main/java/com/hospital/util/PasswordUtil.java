
package com.hospital.util;

import org.mindrot.jbcrypt.BCrypt;

public class PasswordUtil {

    private PasswordUtil() {
        // Prevent object creation
    }

    // Convert a plain-text password into a BCrypt hash
    public static String hashPassword(String plainPassword) {
        if (plainPassword == null || plainPassword.isEmpty()) {
            throw new IllegalArgumentException(
                "Password cannot be empty."
            );
        }

        return BCrypt.hashpw(
            plainPassword,
            BCrypt.gensalt(12)
        );
    }

    // Verify a password against its stored BCrypt hash
    public static boolean verifyPassword(
            String plainPassword, String passwordHash) {

        if (plainPassword == null || passwordHash == null) {
            return false;
        }

        try {
            return BCrypt.checkpw(plainPassword, passwordHash);
        } catch (IllegalArgumentException e) {
            return false;
        }
    }
}
