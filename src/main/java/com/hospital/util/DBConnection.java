
package com.hospital.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {

    private static final String DEFAULT_URL =
        "jdbc:mysql://localhost:3306/hospital_db"
        + "?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";

    private static final String URL =
        getEnv("DB_URL", DEFAULT_URL);

    private static final String USER =
        getEnv("DB_USER", "root");

    private static final String PASSWORD =
        getEnv("DB_PASSWORD", "");

    private DBConnection() {
    }

    private static String getEnv(String name, String defaultValue) {
        String value = System.getenv(name);
        return (value == null || value.isBlank())
                ? defaultValue
                : value;
    }

    public static Connection getConnection() throws SQLException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new SQLException(
                "MySQL JDBC driver could not be loaded.", e);
        }

        return DriverManager.getConnection(URL, USER, PASSWORD);
    }
}
