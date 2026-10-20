
package com.hospital.dao;

import com.hospital.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Time;
import java.sql.Types;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.TextStyle;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

public class StaffShiftScheduleDAO {

    /*
     * Retained for Staff Attendance functionality.
     * Do not change these existing getters or constructor.
     */
    public static class Shift {
        private final int shiftId;
        private final LocalTime startTime;
        private final LocalTime endTime;

        public Shift(
                int shiftId,
                LocalTime startTime,
                LocalTime endTime) {
            this.shiftId = shiftId;
            this.startTime = startTime;
            this.endTime = endTime;
        }

        public int getShiftId() {
            return shiftId;
        }

        public LocalTime getStartTime() {
            return startTime;
        }

        public LocalTime getEndTime() {
            return endTime;
        }
    }

    /*
     * Separate mutable model for shift management.
     * This avoids breaking the existing attendance Shift API.
     */
    public static class ShiftRecord {
        private int shiftId;
        private int staffId;
        private String staffName;
        private String designation;
        private String dayOfWeek;
        private LocalTime shiftStart;
        private LocalTime shiftEnd;
        private LocalDate effectiveFrom;
        private LocalDate effectiveUntil;
        private String shiftStatus;

        public int getShiftId() { return shiftId; }
        public void setShiftId(int v) { shiftId = v; }

        public int getStaffId() { return staffId; }
        public void setStaffId(int v) { staffId = v; }

        public String getStaffName() { return staffName; }
        public void setStaffName(String v) { staffName = v; }

        public String getDesignation() { return designation; }
        public void setDesignation(String v) { designation = v; }

        public String getDayOfWeek() { return dayOfWeek; }
        public void setDayOfWeek(String v) { dayOfWeek = v; }

        public LocalTime getShiftStart() { return shiftStart; }
        public void setShiftStart(LocalTime v) { shiftStart = v; }

        public LocalTime getShiftEnd() { return shiftEnd; }
        public void setShiftEnd(LocalTime v) { shiftEnd = v; }

        public LocalDate getEffectiveFrom() { return effectiveFrom; }
        public void setEffectiveFrom(LocalDate v) {
            effectiveFrom = v;
        }

        public LocalDate getEffectiveUntil() { return effectiveUntil; }
        public void setEffectiveUntil(LocalDate v) {
            effectiveUntil = v;
        }

        public String getShiftStatus() { return shiftStatus; }
        public void setShiftStatus(String v) {
            shiftStatus = v;
        }
    }

    private static final String SELECT_SHIFTS =
            "SELECT s.shift_id, s.staff_id, st.full_name, " +
            "st.designation, s.day_of_week, s.shift_start, " +
            "s.shift_end, s.effective_from, s.effective_until, " +
            "s.shift_status " +
            "FROM staff_shift_schedules s " +
            "JOIN staff st ON st.staff_id = s.staff_id ";

    // =====================================================
    // Existing method: used by Staff Attendance
    // =====================================================

    public Shift getShiftForDate(
            int staffId, LocalDate date) throws SQLException {

        String dayOfWeek = date.getDayOfWeek()
                .getDisplayName(
                        TextStyle.FULL, Locale.ENGLISH)
                .toUpperCase(Locale.ROOT);

        String sql =
                "SELECT shift_id, shift_start, shift_end " +
                "FROM staff_shift_schedules " +
                "WHERE staff_id = ? " +
                "AND day_of_week = ? " +
                "AND shift_status = 'ACTIVE' " +
                "AND effective_from <= ? " +
                "AND (effective_until IS NULL " +
                "     OR effective_until >= ?) " +
                "ORDER BY effective_from DESC, shift_id DESC " +
                "LIMIT 1";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, staffId);
            ps.setString(2, dayOfWeek);
            ps.setDate(3, java.sql.Date.valueOf(date));
            ps.setDate(4, java.sql.Date.valueOf(date));

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Time start = rs.getTime("shift_start");
                    Time end = rs.getTime("shift_end");

                    return new Shift(
                            rs.getInt("shift_id"),
                            start.toLocalTime(),
                            end.toLocalTime());
                }
            }
        }

        return null;
    }

    // =====================================================
    // List all schedules
    // =====================================================

    public List<ShiftRecord> getAllShifts()
            throws SQLException {

        List<ShiftRecord> shifts = new ArrayList<>();

        String sql = SELECT_SHIFTS +
                "ORDER BY FIELD(s.day_of_week, " +
                "'MONDAY','TUESDAY','WEDNESDAY','THURSDAY'," +
                "'FRIDAY','SATURDAY','SUNDAY'), st.full_name";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                shifts.add(mapShiftRecord(rs));
            }
        }

        return shifts;
    }

    // =====================================================
    // Get active staff for the form dropdown
    // =====================================================

    public List<ShiftRecord> getActiveStaff()
            throws SQLException {

        List<ShiftRecord> staffList = new ArrayList<>();

        String sql =
                "SELECT staff_id, full_name, designation " +
                "FROM staff " +
                "WHERE employment_status = 'ACTIVE' " +
                "ORDER BY full_name";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                ShiftRecord record = new ShiftRecord();
                record.setStaffId(rs.getInt("staff_id"));
                record.setStaffName(rs.getString("full_name"));
                record.setDesignation(rs.getString("designation"));
                staffList.add(record);
            }
        }

        return staffList;
    }

    // =====================================================
    // Find a schedule by ID
    // =====================================================

    public ShiftRecord getShiftById(int shiftId)
            throws SQLException {

        String sql = SELECT_SHIFTS +
                "WHERE s.shift_id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, shiftId);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapShiftRecord(rs) : null;
            }
        }
    }

    // =====================================================
    // Add a schedule
    // =====================================================

    public boolean addShift(ShiftRecord shift)
            throws SQLException {

        String sql =
                "INSERT INTO staff_shift_schedules " +
                "(staff_id, day_of_week, shift_start, shift_end, " +
                "effective_from, effective_until, shift_status) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?)";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            bindShift(ps, shift);
            return ps.executeUpdate() == 1;
        }
    }

    // =====================================================
    // Update a schedule
    // =====================================================

    public boolean updateShift(ShiftRecord shift)
            throws SQLException {

        String sql =
                "UPDATE staff_shift_schedules SET " +
                "staff_id = ?, day_of_week = ?, " +
                "shift_start = ?, shift_end = ?, " +
                "effective_from = ?, effective_until = ?, " +
                "shift_status = ? WHERE shift_id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            bindShift(ps, shift);
            ps.setInt(8, shift.getShiftId());

            return ps.executeUpdate() == 1;
        }
    }

    // =====================================================
    // Activate / deactivate a schedule
    // =====================================================

    public boolean updateShiftStatus(
            int shiftId, String status) throws SQLException {

        String sql =
                "UPDATE staff_shift_schedules " +
                "SET shift_status = ? WHERE shift_id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, status);
            ps.setInt(2, shiftId);

            return ps.executeUpdate() == 1;
        }
    }

    // =====================================================
    // Delete a schedule
    // =====================================================

    public boolean deleteShift(int shiftId)
            throws SQLException {

        String sql =
                "DELETE FROM staff_shift_schedules " +
                "WHERE shift_id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, shiftId);
            return ps.executeUpdate() == 1;
        }
    }

    // =====================================================
    // Internal helpers
    // =====================================================

    private void bindShift(
            PreparedStatement ps, ShiftRecord shift)
            throws SQLException {

        ps.setInt(1, shift.getStaffId());
        ps.setString(2, shift.getDayOfWeek());
        ps.setTime(3, Time.valueOf(shift.getShiftStart()));
        ps.setTime(4, Time.valueOf(shift.getShiftEnd()));
        ps.setDate(5,
                java.sql.Date.valueOf(shift.getEffectiveFrom()));

        if (shift.getEffectiveUntil() == null) {
            ps.setNull(6, Types.DATE);
        } else {
            ps.setDate(6,
                    java.sql.Date.valueOf(shift.getEffectiveUntil()));
        }

        ps.setString(7, shift.getShiftStatus());
    }

    private ShiftRecord mapShiftRecord(ResultSet rs)
            throws SQLException {

        ShiftRecord record = new ShiftRecord();

        record.setShiftId(rs.getInt("shift_id"));
        record.setStaffId(rs.getInt("staff_id"));
        record.setStaffName(rs.getString("full_name"));
        record.setDesignation(rs.getString("designation"));
        record.setDayOfWeek(rs.getString("day_of_week"));

        Time start = rs.getTime("shift_start");
        Time end = rs.getTime("shift_end");

        record.setShiftStart(
                start == null ? null : start.toLocalTime());
        record.setShiftEnd(
                end == null ? null : end.toLocalTime());

        java.sql.Date from = rs.getDate("effective_from");
        java.sql.Date until = rs.getDate("effective_until");

        record.setEffectiveFrom(
                from == null ? null : from.toLocalDate());
        record.setEffectiveUntil(
                until == null ? null : until.toLocalDate());

        record.setShiftStatus(rs.getString("shift_status"));

        return record;
    }
}
