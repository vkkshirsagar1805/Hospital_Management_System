
package com.hospital;

import com.hospital.util.PasswordUtil;

public class PasswordUtilTest {

    public static void main(String[] args) {

        String password = "DemoPass123!";

        // Generate a secure password hash
        String hash = PasswordUtil.hashPassword(password);

        System.out.println("Password hash generated: "
                + !hash.isEmpty());

        // Test the correct password
        boolean correct = PasswordUtil.verifyPassword(
                password, hash);

        System.out.println("Correct password accepted: "
                + correct);

        // Test an incorrect password
        boolean incorrect = PasswordUtil.verifyPassword(
                "WrongPass456!", hash);

        System.out.println("Incorrect password rejected: "
                + !incorrect);
    }
}
