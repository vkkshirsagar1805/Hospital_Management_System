
package com.hospital.dao;

import com.hospital.model.StaffAttendance;
import com.hospital.util.DBConnection;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.sql.Statement;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.Duration;
import java.util.ArrayList;
import java.util.List;

public class StaffAttendanceDAO {
	
	public boolean checkIn(int staffId, LocalDateTime checkInTime)
	        throws SQLException {

	    StaffShiftScheduleDAO shiftDAO = new StaffShiftScheduleDAO();

	    StaffShiftScheduleDAO.Shift shift =
	            shiftDAO.getShiftForDate(staffId, checkInTime.toLocalDate());

	    int lateMinutes = 0;

	    if (shift != null) {
	        long minutes = Duration.between(
	                shift.getStartTime(),
	                checkInTime.toLocalTime()
	        ).toMinutes();

	        lateMinutes = (int) Math.max(0, minutes);
	    }

	    String sql =
	        "INSERT INTO staff_attendance " +
	        "(staff_id, attendance_date, check_in, " +
	        "attendance_status, late_minutes) " +
	        "VALUES (?, ?, ?, 'PRESENT', ?)";

	    try (Connection con = DBConnection.getConnection();
	         PreparedStatement ps = con.prepareStatement(sql)) {

	        ps.setInt(1, staffId);
	        ps.setDate(2, Date.valueOf(checkInTime.toLocalDate()));
	        ps.setObject(3, checkInTime);
	        ps.setInt(4, lateMinutes);

	        return ps.executeUpdate() == 1;
	    }
	}

	public boolean checkOut(int staffId, LocalDateTime checkOutTime) throws SQLException {

		StaffShiftScheduleDAO shiftDAO = new StaffShiftScheduleDAO();

		StaffShiftScheduleDAO.Shift shift = shiftDAO.getShiftForDate(staffId, checkOutTime.toLocalDate());

		int earlyDepartureMinutes = 0;
		int overtimeMinutes = 0;

		if (shift != null) {
			long earlyMinutes = Duration.between(
					checkOutTime.toLocalTime(),
					shift.getEndTime()
					).toMinutes();

			if (earlyMinutes > 0) {
				earlyDepartureMinutes = (int) earlyMinutes;
			}

			long overtime = Duration.between(
					shift.getEndTime(),
					checkOutTime.toLocalTime()
					).toMinutes();

			if (overtime > 0) { overtimeMinutes = (int) overtime;
        }
    }

		String sql =
				"UPDATE staff_attendance " +
						"SET check_out = ?, " +
						"early_departure_minutes = ?, " +
						"overtime_minutes = ? " +
						"WHERE staff_id = ? " +
						"AND attendance_date = ? " +
						"AND check_in IS NOT NULL " +
						"AND check_out IS NULL " +
						"AND attendance_status = 'PRESENT'";

		try (Connection con = DBConnection.getConnection();
				PreparedStatement ps = con.prepareStatement(sql)) {

			ps.setObject(1, checkOutTime);
			ps.setInt(2, earlyDepartureMinutes);
			ps.setInt(3, overtimeMinutes);
			ps.setInt(4, staffId);
			ps.setDate(5, Date.valueOf(checkOutTime.toLocalDate()));

			return ps.executeUpdate() == 1;
		}
	}
	
    public StaffAttendance getTodayAttendance(int staffId)
            throws SQLException {

        String sql =
            "SELECT * FROM staff_attendance " +
            "WHERE staff_id = ? AND attendance_date = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, staffId);
            ps.setDate(2, Date.valueOf(LocalDate.now(java.time.ZoneId.of("Asia/Kolkata"))));

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapAttendance(rs);
                }
            }
        }

        return null;
    }

    public List<StaffAttendance> getAttendanceByDate(LocalDate date)
            throws SQLException {

        List<StaffAttendance> records = new ArrayList<>();

        String sql =
            "SELECT * FROM staff_attendance " +
            "WHERE attendance_date = ? " +
            "ORDER BY staff_id";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setDate(1, Date.valueOf(date));

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    records.add(mapAttendance(rs));
                }
            }
        }

        return records;
    }

    private StaffAttendance mapAttendance(ResultSet rs)
            throws SQLException {

        StaffAttendance attendance = new StaffAttendance();

        attendance.setAttendanceId(rs.getInt("attendance_id"));
        attendance.setStaffId(rs.getInt("staff_id"));

        attendance.setAttendanceDate(
            rs.getDate("attendance_date").toLocalDate()
        );

        LocalDateTime checkIn =
            rs.getObject("check_in", LocalDateTime.class);

        if (checkIn != null) {
            attendance.setCheckIn(checkIn);
        }

        LocalDateTime checkOut =
            rs.getObject("check_out", LocalDateTime.class);

        if (checkOut != null) {
            attendance.setCheckOut(checkOut);
        }

        attendance.setAttendanceStatus(
            rs.getString("attendance_status")
        );

        attendance.setLateMinutes(rs.getInt("late_minutes"));

        attendance.setEarlyDepartureMinutes(
            rs.getInt("early_departure_minutes")
        );

        attendance.setOvertimeMinutes(
            rs.getInt("overtime_minutes")
        );

        attendance.setRemarks(rs.getString("remarks"));

        return attendance;
    }

    public Integer getStaffIdByUserId(int userId) throws SQLException {
    	String sql =
    			"SELECT staff_id FROM staff " +
    					"WHERE user_id = ? " +
    					"AND employment_status = 'ACTIVE'";

    	try (Connection con = DBConnection.getConnection();
    			PreparedStatement ps = con.prepareStatement(sql)) {

    		ps.setInt(1, userId);

    		try (ResultSet rs = ps.executeQuery()) {
    			if (rs.next()) {
    				return rs.getInt("staff_id");
    			}
    		}
    	}
    	
    return null;
    }
}
