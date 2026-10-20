
package com.hospital;

import com.hospital.util.DBConnection;
import com.hospital.util.PasswordUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

public class CreateTestUser {

    public static void main(String[] args) {

        String username = "admin_demo";
        String password = "DemoPass123!";

        String passwordHash = PasswordUtil.hashPassword(password);

        String sql = "INSERT INTO users "
                   + "(username, password_hash, role, account_status) "
                   + "VALUES (?, ?, 'ADMIN', 'ACTIVE')";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, username);
            ps.setString(2, passwordHash);

            int rows = ps.executeUpdate();

            if (rows == 1) {
                System.out.println("Test user created successfully.");
                System.out.println("Username: " + username);
                System.out.println("Password: " + password);
                System.out.println("Role: ADMIN");
            }

        } catch (SQLException e) {
            System.out.println(
                    "Could not create test user: " + e.getMessage()
            );
        }
    }
}
