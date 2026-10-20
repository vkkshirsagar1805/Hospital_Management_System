
package com.hospital.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import com.hospital.model.SearchResult;
import com.hospital.util.DBConnection;

public class SearchDAO {

    public List<SearchResult> search(String query)
            throws SQLException {

        List<SearchResult> results = new ArrayList<>();

        if (query == null || query.isBlank()) {
            return results;
        }

        query = query.trim();

        String patientSql = """
            SELECT patient_id, full_name, phone, email, record_status
            FROM patients
            WHERE CAST(patient_id AS CHAR) = ?
               OR full_name LIKE ?
               OR phone LIKE ?
               OR email LIKE ?
            ORDER BY full_name
            LIMIT 20
            """;

        String doctorSql = """
            SELECT doctor_id, full_name, specialization, phone, email,
                   employment_status
            FROM doctors
            WHERE CAST(doctor_id AS CHAR) = ?
               OR full_name LIKE ?
               OR specialization LIKE ?
               OR phone LIKE ?
               OR email LIKE ?
            ORDER BY full_name
            LIMIT 20
            """;

        String appointmentSql = """
            SELECT a.appointment_id, a.appointment_datetime,
                   a.appointment_status, a.reason,
                   p.full_name AS patient_name,
                   d.full_name AS doctor_name
            FROM appointments a
            JOIN patients p ON a.patient_id = p.patient_id
            JOIN doctors d ON a.doctor_id = d.doctor_id
            WHERE CAST(a.appointment_id AS CHAR) = ?
               OR a.appointment_status LIKE ?
               OR a.reason LIKE ?
               OR p.full_name LIKE ?
               OR d.full_name LIKE ?
            ORDER BY a.appointment_datetime DESC
            LIMIT 20
            """;

        String pattern = "%" + query + "%";

        try (Connection connection = DBConnection.getConnection()) {

            // Search patients
            try (PreparedStatement ps =
                     connection.prepareStatement(patientSql)) {

                ps.setString(1, query);
                ps.setString(2, pattern);
                ps.setString(3, pattern);
                ps.setString(4, pattern);

                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        results.add(new SearchResult(
                            "Patient",
                            String.valueOf(rs.getInt("patient_id")),
                            rs.getString("full_name"),
                            "Phone: " + safe(rs.getString("phone"))
                                + " | Email: " + safe(rs.getString("email")),
                            rs.getString("record_status"),
                            "/patients"
                        ));
                    }
                }
            }

            // Search doctors
            try (PreparedStatement ps =
                     connection.prepareStatement(doctorSql)) {

                ps.setString(1, query);
                ps.setString(2, pattern);
                ps.setString(3, pattern);
                ps.setString(4, pattern);
                ps.setString(5, pattern);

                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        results.add(new SearchResult(
                            "Doctor",
                            String.valueOf(rs.getInt("doctor_id")),
                            rs.getString("full_name"),
                            "Specialization: "
                                + safe(rs.getString("specialization"))
                                + " | Phone: " + safe(rs.getString("phone")),
                            rs.getString("employment_status"),
                            "/doctors"
                        ));
                    }
                }
            }

            // Search appointments
            try (PreparedStatement ps =
                     connection.prepareStatement(appointmentSql)) {

                ps.setString(1, query);
                ps.setString(2, pattern);
                ps.setString(3, pattern);
                ps.setString(4, pattern);
                ps.setString(5, pattern);

                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        results.add(new SearchResult(
                            "Appointment",
                            String.valueOf(rs.getInt("appointment_id")),
                            "Appointment #" + rs.getInt("appointment_id"),
                            "Patient: " + rs.getString("patient_name")
                                + " | Doctor: " + rs.getString("doctor_name")
                                + " | Date: "
                                + rs.getTimestamp("appointment_datetime"),
                            rs.getString("appointment_status"),
                            "/appointments"
                        ));
                    }
                }
            }
        }

        return results;
    }

    private String safe(String value) {
        return value == null || value.isBlank() ? "Not provided" : value;
    }
}
