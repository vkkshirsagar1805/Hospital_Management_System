
package com.hospital.dao;

import com.hospital.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.LinkedHashMap;
import java.util.Map;

public class DashboardStatsDAO {

    public Map<String, Integer> getDashboardStats()
            throws SQLException {

        Map<String, Integer> stats = new LinkedHashMap<>();

        try (Connection con = DBConnection.getConnection()) {

            stats.put("totalPatients",
                    getCount(con, "SELECT COUNT(*) FROM patients"));

            stats.put("totalDoctors",
                    getCount(con, "SELECT COUNT(*) FROM doctors"));

            stats.put("totalStaff",
                    getCount(con, "SELECT COUNT(*) FROM staff"));

            stats.put("totalAppointments",
                    getCount(con, "SELECT COUNT(*) FROM appointments"));

            stats.put("totalEmergencyRequests",
                    getCount(con, "SELECT COUNT(*) FROM emergency_requests"));

            stats.put("availableAmbulances",
                    getCount(con,
                        "SELECT COUNT(*) FROM ambulances " +
                        "WHERE ambulance_status = 'AVAILABLE'"));
        }

        return stats;
    }

    private int getCount(Connection con, String sql)
            throws SQLException {

        try (PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                return rs.getInt(1);
            }
        }

        return 0;
    }
}
