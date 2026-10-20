
package com.hospital.dao;

import com.hospital.model.DoctorSchedule;
import com.hospital.util.DBConnection;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Time;

import java.util.ArrayList;
import java.util.List;

public class DoctorScheduleDAO {

    // 1. Get all schedules with doctor names
    public List<DoctorSchedule> getAllSchedules() throws SQLException {
        List<DoctorSchedule> schedules = new ArrayList<>();

        String sql = """
                SELECT ds.*, d.full_name AS doctor_name
                FROM doctor_schedules ds
                INNER JOIN doctors d
                    ON ds.doctor_id = d.doctor_id
                ORDER BY ds.schedule_id ASC
                """;

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                schedules.add(mapSchedule(rs));
            }
        }

        return schedules;
    }

    // 2. Get one schedule by ID
    public DoctorSchedule getScheduleById(int scheduleId)
            throws SQLException {

        String sql = """
                SELECT ds.*, d.full_name AS doctor_name
                FROM doctor_schedules ds
                INNER JOIN doctors d
                    ON ds.doctor_id = d.doctor_id
                WHERE ds.schedule_id = ?
                """;

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, scheduleId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapSchedule(rs);
                }
            }
        }

        return null;
    }

    // 3. Get active doctors for the schedule form
    public List<com.hospital.model.Doctor> getActiveDoctors()
            throws SQLException {

        List<com.hospital.model.Doctor> doctors = new ArrayList<>();

        String sql = """
                SELECT *
                FROM doctors
                WHERE employment_status = 'ACTIVE'
                ORDER BY full_name
                """;

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                com.hospital.model.Doctor doctor =
                        new com.hospital.model.Doctor();

                doctor.setDoctorId(rs.getInt("doctor_id"));
                doctor.setFullName(rs.getString("full_name"));

                doctors.add(doctor);
            }
        }

        return doctors;
    }

    // 4. Add a new schedule
    public boolean addSchedule(DoctorSchedule schedule)
            throws SQLException {

        String sql = """
                INSERT INTO doctor_schedules
                (doctor_id, day_of_week, start_time, end_time,
                 valid_from, valid_until, schedule_status)
                VALUES (?, ?, ?, ?, ?, ?, ?)
                """;

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            setScheduleParameters(ps, schedule);

            return ps.executeUpdate() == 1;
        }
    }
    
    // Add multiple weekday schedules in one database transaction
    public boolean addSchedules(List<DoctorSchedule> schedules)
            throws SQLException {

        if (schedules == null || schedules.isEmpty()) {
            throw new IllegalArgumentException(
                    "Select at least one weekday.");
        }

        String sql = """
                INSERT INTO doctor_schedules
                (doctor_id, day_of_week, start_time, end_time,
                 valid_from, valid_until, schedule_status)
                VALUES (?, ?, ?, ?, ?, ?, ?)
                """;

        try (Connection con = DBConnection.getConnection()) {

            con.setAutoCommit(false);

            try (PreparedStatement ps = con.prepareStatement(sql)) {

                for (DoctorSchedule schedule : schedules) {
                    setScheduleParameters(ps, schedule);

                    if (ps.executeUpdate() != 1) {
                        throw new SQLException(
                                "Failed to save schedule for "
                                + schedule.getDayOfWeek());
                    }
                }

                con.commit();
                return true;

            } catch (SQLException | RuntimeException e) {
                try {
                    con.rollback();
                } catch (SQLException rollbackError) {
                    e.addSuppressed(rollbackError);
                }
                throw e;
            }
        }
    }

    // 5. Update an existing schedule
    public boolean updateSchedule(DoctorSchedule schedule)
            throws SQLException {

        String sql = """
                UPDATE doctor_schedules
                SET doctor_id = ?,
                    day_of_week = ?,
                    start_time = ?,
                    end_time = ?,
                    valid_from = ?,
                    valid_until = ?,
                    schedule_status = ?
                WHERE schedule_id = ?
                """;

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            setScheduleParameters(ps, schedule);
            ps.setInt(8, schedule.getScheduleId());

            return ps.executeUpdate() == 1;
        }
    }

    // 6. Delete a schedule
    public boolean deleteSchedule(int scheduleId)
            throws SQLException {

        String sql = """
                DELETE FROM doctor_schedules
                WHERE schedule_id = ?
                """;

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, scheduleId);

            return ps.executeUpdate() == 1;
        }
    }

    // 7. Activate or deactivate a schedule
    public boolean updateScheduleStatus(int scheduleId, String status)
            throws SQLException {

        if (!"ACTIVE".equals(status) && !"INACTIVE".equals(status)) {
            throw new IllegalArgumentException("Invalid schedule status.");
        }

        String sql = """
                UPDATE doctor_schedules
                SET schedule_status = ?
                WHERE schedule_id = ?
                """;

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, status);
            ps.setInt(2, scheduleId);

            return ps.executeUpdate() == 1;
        }
    }

    // 8. Map a database row to the model
    private DoctorSchedule mapSchedule(ResultSet rs)
            throws SQLException {

        DoctorSchedule schedule = new DoctorSchedule();

        schedule.setScheduleId(rs.getInt("schedule_id"));
        schedule.setDoctorId(rs.getInt("doctor_id"));
        schedule.setDoctorName(rs.getString("doctor_name"));
        schedule.setDayOfWeek(rs.getString("day_of_week"));
        schedule.setStartTime(rs.getTime("start_time"));
        schedule.setEndTime(rs.getTime("end_time"));
        schedule.setValidFrom(rs.getDate("valid_from"));
        schedule.setValidUntil(rs.getDate("valid_until"));
        schedule.setScheduleStatus(rs.getString("schedule_status"));

        return schedule;
    }

    // 9. Set parameters shared by insert and update
    private void setScheduleParameters(
            PreparedStatement ps,
            DoctorSchedule schedule) throws SQLException {

        ps.setInt(1, schedule.getDoctorId());
        ps.setString(2, schedule.getDayOfWeek());
        ps.setTime(3, schedule.getStartTime());
        ps.setTime(4, schedule.getEndTime());
        ps.setDate(5, schedule.getValidFrom());

        if (schedule.getValidUntil() != null) {
            ps.setDate(6, schedule.getValidUntil());
        } else {
            ps.setNull(6, java.sql.Types.DATE);
        }

        ps.setString(7, schedule.getScheduleStatus());
    }
}
