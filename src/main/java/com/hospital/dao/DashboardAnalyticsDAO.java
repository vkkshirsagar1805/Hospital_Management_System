
package com.hospital.dao;

import com.hospital.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.YearMonth;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

public class DashboardAnalyticsDAO {

    // ---------------------------------------------------------
    // 1. APPOINTMENT STATUS SUMMARY
    // ---------------------------------------------------------
    public Map<String, Integer> getAppointmentSummary()
            throws SQLException {

        Map<String, Integer> summary = new LinkedHashMap<>();

        // Include every status, even if its count is zero.
        summary.put("REQUESTED", 0);
        summary.put("CONFIRMED", 0);
        summary.put("CHECKED_IN", 0);
        summary.put("COMPLETED", 0);
        summary.put("CANCELLED", 0);
        summary.put("NO_SHOW", 0);

        String sql =
                "SELECT appointment_status, COUNT(*) AS total " +
                "FROM appointments " +
                "GROUP BY appointment_status";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                String status = rs.getString("appointment_status");
                int total = rs.getInt("total");

                if (status != null) {
                    summary.put(status, total);
                }
            }
        }

        return summary;
    }

    // ---------------------------------------------------------
    // 2. EMERGENCY REQUEST STATUS SUMMARY
    // ---------------------------------------------------------
    public Map<String, Integer> getEmergencySummary()
            throws SQLException {

        Map<String, Integer> summary = new LinkedHashMap<>();

        summary.put("REPORTED", 0);
        summary.put("ACKNOWLEDGED", 0);
        summary.put("DISPATCHED", 0);
        summary.put("IN_PROGRESS", 0);
        summary.put("RESOLVED", 0);
        summary.put("CANCELLED", 0);

        String sql =
                "SELECT request_status, COUNT(*) AS total " +
                "FROM emergency_requests " +
                "GROUP BY request_status";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                String status = rs.getString("request_status");
                int total = rs.getInt("total");

                if (status != null) {
                    summary.put(status, total);
                }
            }
        }

        return summary;
    }

    // ---------------------------------------------------------
    // 3. PATIENT REGISTRATION TREND
    // ---------------------------------------------------------
    public List<Map<String, Object>> getPatientRegistrationTrend(
            String period) throws SQLException {

        String selectedPeriod =
                period == null ? "weekly" : period.toLowerCase(Locale.ROOT);

        if (!selectedPeriod.equals("daily")
                && !selectedPeriod.equals("weekly")
                && !selectedPeriod.equals("monthly")
                && !selectedPeriod.equals("yearly")) {
            selectedPeriod = "weekly";
        }

        LocalDate today = LocalDate.now();
        LocalDate startDate;
        LocalDate endDate;

        String dateFormat;

        switch (selectedPeriod) {

            case "daily":
                startDate = today;
                endDate = today.plusDays(1);
                dateFormat = "%H:00";
                break;

            case "monthly":
                startDate = today.withDayOfMonth(1);
                endDate = startDate.plusMonths(1);
                dateFormat = "%d %b";
                break;

            case "yearly":
                startDate = today.withDayOfYear(1);
                endDate = startDate.plusYears(1);
                dateFormat = "%b";
                break;

            default:
                startDate = today.minusDays(6);
                endDate = today.plusDays(1);
                dateFormat = "%a";
                break;
        }

        // Initialize all expected periods with zero.
        Map<String, Integer> totals = new LinkedHashMap<>();

        if ("daily".equals(selectedPeriod)) {

            for (int hour = 0; hour < 24; hour++) {
                totals.put(String.format(
                        Locale.ROOT, "%02d:00", hour), 0);
            }

        } else if ("weekly".equals(selectedPeriod)) {

            DateTimeFormatter formatter =
                    DateTimeFormatter.ofPattern("EEE", Locale.ENGLISH);

            for (LocalDate date = startDate;
                 date.isBefore(endDate);
                 date = date.plusDays(1)) {

                totals.put(date.format(formatter), 0);
            }

        } else if ("monthly".equals(selectedPeriod)) {

            DateTimeFormatter formatter =
                    DateTimeFormatter.ofPattern("dd MMM", Locale.ENGLISH);

            for (LocalDate date = startDate;
                 date.isBefore(endDate);
                 date = date.plusDays(1)) {

                totals.put(date.format(formatter), 0);
            }

        } else {

            DateTimeFormatter formatter =
                    DateTimeFormatter.ofPattern("MMM", Locale.ENGLISH);

            for (int month = 1; month <= 12; month++) {
                totals.put(
                        YearMonth.of(today.getYear(), month)
                                .format(formatter),
                        0
                );
            }
        }

        String sql =
                "SELECT DATE_FORMAT(registration_date, ?) AS period_label, " +
                "COUNT(*) AS total " +
                "FROM patients " +
                "WHERE registration_date >= ? " +
                "AND registration_date < ? " +
                "GROUP BY period_label " +
                "ORDER BY MIN(registration_date)";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, dateFormat);
            ps.setTimestamp(2, Timestamp.valueOf(startDate.atStartOfDay()));
            ps.setTimestamp(3, Timestamp.valueOf(endDate.atStartOfDay()));

            try (ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {
                    String label = rs.getString("period_label");
                    int total = rs.getInt("total");

                    if (label != null) {

                        // Match SQL labels to the initialized chart labels.
                    	if ("monthly".equals(selectedPeriod)) {
                    	    label = label.replaceFirst(
                    	            "^(\\d) ",
                    	            "0$1 "
                    	    );
                    	}

                        if (totals.containsKey(label)) {
                            totals.put(label, total);
                        }
                    }
                }
            }
        }

        List<Map<String, Object>> results = new ArrayList<>();

        for (Map.Entry<String, Integer> entry : totals.entrySet()) {
            Map<String, Object> point = new LinkedHashMap<>();
            point.put("label", entry.getKey());
            point.put("total", entry.getValue());
            results.add(point);
        }

        return results;
    }
}
