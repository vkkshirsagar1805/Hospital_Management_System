
package com.hospital.dao;

import com.hospital.model.User;
import com.hospital.util.DBConnection;
import com.hospital.util.PasswordUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class UserDAO {

    public User getUserByUsername(String username) throws SQLException {

        String sql = "SELECT user_id, username, password_hash, role, "
                   + "account_status, created_at, updated_at "
                   + "FROM users WHERE username = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, username);

            try (ResultSet rs = ps.executeQuery()) {

                if (rs.next()) {
                    User user = new User();

                    user.setUserId(rs.getInt("user_id"));
                    user.setUsername(rs.getString("username"));
                    user.setPasswordHash(rs.getString("password_hash"));
                    user.setRole(rs.getString("role"));
                    user.setAccountStatus(rs.getString("account_status"));
                    user.setCreatedAt(rs.getTimestamp("created_at"));
                    user.setUpdatedAt(rs.getTimestamp("updated_at"));

                    return user;
                }
            }
        }

        return null;
    }

    public boolean createUser(
    		String username, String plainPassword, String role) throws SQLException {

    		String sql = "INSERT INTO users "
    				+ "(username, password_hash, role, account_status) "
    				+ "VALUES (?, ?, ?, 'ACTIVE')";

    		String passwordHash =
    				PasswordUtil.hashPassword(plainPassword);

    		try (Connection con = DBConnection.getConnection();
    				PreparedStatement ps = con.prepareStatement(sql)) {

        ps.setString(1, username);
        ps.setString(2, passwordHash);
        ps.setString(3, role);

        		return ps.executeUpdate() == 1;
    		}
    }
    
    public Integer getDoctorIdByUserId(int userId) throws SQLException {

        String sql =
            "SELECT doctor_id FROM doctors WHERE user_id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("doctor_id");
                }
            }
        }

        return null;
    }
}
