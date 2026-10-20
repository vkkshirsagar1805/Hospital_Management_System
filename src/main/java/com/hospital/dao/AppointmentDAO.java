
package com.hospital.dao;

import com.hospital.model.Appointment;
import com.hospital.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Time;
import java.util.ArrayList;
import java.util.List;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.LocalDateTime;

public class AppointmentDAO {

    public List<Appointment> getAllAppointments()
            throws SQLException {

        List<Appointment> appointments = new ArrayList<>();

        String sql =
            "SELECT a.*, " +
            "p.full_name AS patient_name, " +
            "d.full_name AS doctor_name " +
            "FROM appointments a " +
            "JOIN patients p ON a.patient_id = p.patient_id " +
            "JOIN doctors d ON a.doctor_id = d.doctor_id " +
            "ORDER BY a.appointment_datetime DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {

                Appointment a = new Appointment();

                a.setAppointmentId(
                    rs.getInt("appointment_id"));

                a.setPatientId(
                    rs.getInt("patient_id"));

                a.setDoctorId(
                    rs.getInt("doctor_id"));

                a.setScheduleId(
                    (Integer) rs.getObject("schedule_id"));

                a.setPatientName(
                    rs.getString("patient_name"));

                a.setDoctorName(
                    rs.getString("doctor_name"));

                a.setAppointmentDatetime(
                    rs.getTimestamp("appointment_datetime"));

                a.setReason(
                    rs.getString("reason"));

                a.setAppointmentStatus(
                    rs.getString("appointment_status"));

                a.setCreatedBy(
                    (Integer) rs.getObject("created_by"));

                a.setNotes(
                    rs.getString("notes"));

                a.setCreatedAt(
                    rs.getTimestamp("created_at"));

                a.setUpdatedAt(
                    rs.getTimestamp("updated_at"));

                appointments.add(a);
            }
        }

        return appointments;
    }
    
    public boolean addAppointment(Appointment a) throws SQLException {

        String lockDoctorSql =
                "SELECT doctor_id FROM doctors " +
                "WHERE doctor_id = ? FOR UPDATE";

        String checkSql =
                "SELECT appointment_id FROM appointments " +
                "WHERE doctor_id = ? " +
                "AND appointment_datetime = ? " +
                "AND appointment_status <> 'CANCELLED' " +
                "LIMIT 1";

        String insertSql =
                "INSERT INTO appointments " +
                "(patient_id, doctor_id, schedule_id, " +
                "appointment_datetime, reason, appointment_status, notes) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?)";

        try (Connection con = DBConnection.getConnection()) {

            con.setAutoCommit(false);

            try {
                // Lock this doctor's database row so simultaneous
                // appointment submissions for this doctor are serialized.
                try (PreparedStatement ps =
                             con.prepareStatement(lockDoctorSql)) {

                    ps.setInt(1, a.getDoctorId());

                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) {
                            con.rollback();
                            return false;
                        }
                    }
                }

                // Check whether this exact time is already booked.
                try (PreparedStatement ps =
                             con.prepareStatement(checkSql)) {

                    ps.setInt(1, a.getDoctorId());
                    ps.setTimestamp(2, a.getAppointmentDatetime());

                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            con.rollback();
                            return false;
                        }
                    }
                }

                // Insert only if the slot is still available.
                try (PreparedStatement ps =
                             con.prepareStatement(insertSql)) {

                    ps.setInt(1, a.getPatientId());
                    ps.setInt(2, a.getDoctorId());

                    if (a.getScheduleId() != null) {
                        ps.setInt(3, a.getScheduleId());
                    } else {
                        ps.setNull(3, java.sql.Types.INTEGER);
                    }

                    ps.setTimestamp(4, a.getAppointmentDatetime());
                    ps.setString(5, a.getReason());
                    ps.setString(6, a.getAppointmentStatus());
                    ps.setString(7, a.getNotes());

                    int rows = ps.executeUpdate();

                    if (rows == 1) {
                        con.commit();
                        return true;
                    }

                    con.rollback();
                    return false;
                }

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

    public List<String[]> getPatientsForDropdown() throws SQLException {

    	List<String[]> patients = new ArrayList<>();

    	String sql =
    			"SELECT patient_id, full_name " +
    					"FROM patients " +
    					"WHERE record_status = 'ACTIVE' " +
    					"ORDER BY full_name";
    		
    	try (Connection con = DBConnection.getConnection();
    			PreparedStatement ps = con.prepareStatement(sql);
    			ResultSet rs = ps.executeQuery()) {

        while (rs.next()) {
            patients.add(new String[] {
                String.valueOf(rs.getInt("patient_id")),
                rs.getString("full_name")
            	});
        	}
    	}

    	return patients;
	}
    
    public List<String[]> getDepartmentsForDropdown()
            throws SQLException {

        List<String[]> departments = new ArrayList<>();

        String sql =
            "SELECT department_id, department_name " +
            "FROM departments " +
            "WHERE status = 'ACTIVE' " +
            "ORDER BY department_name";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                departments.add(new String[] {
                    String.valueOf(rs.getInt("department_id")),
                    rs.getString("department_name")
                });
            }
        }

        return departments;
    }
    
    public List<String[]> getDoctorsByDepartment(int departmentId)
            throws SQLException {

        List<String[]> doctors = new ArrayList<>();

        String sql =
            "SELECT doctor_id, full_name, specialization " +
            "FROM doctors " +
            "WHERE department_id = ? " +
            "AND employment_status = 'ACTIVE' " +
            "ORDER BY full_name";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, departmentId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    doctors.add(new String[] {
                        String.valueOf(rs.getInt("doctor_id")),
                        rs.getString("full_name"),
                        rs.getString("specialization")
                    });
                }
            }
        }

        return doctors;
    }

	public List<String[]> getDoctorsForDropdown()
        throws SQLException {

		List<String[]> doctors = new ArrayList<>();

		String sql =
				"SELECT doctor_id, full_name " +
						"FROM doctors " +
						"WHERE employment_status = 'ACTIVE' " +
						"ORDER BY full_name";

		try (Connection con = DBConnection.getConnection();
				PreparedStatement ps = con.prepareStatement(sql);
				ResultSet rs = ps.executeQuery()) {
			
			while (rs.next()) {
				doctors.add(new String[] {
						String.valueOf(rs.getInt("doctor_id")),
						rs.getString("full_name")
            	});
        	}
    	}

    	return doctors;
	}
	
	public List<String[]> getScheduleTimesForDoctorOnDate(
	        int doctorId, LocalDate appointmentDate) throws SQLException {

	    List<String[]> schedules = new ArrayList<>();

	    String dayOfWeek = appointmentDate.getDayOfWeek().name();

	    String sql =
	        "SELECT TIME_FORMAT(start_time, '%H:%i') AS start_time, " +
	        "TIME_FORMAT(end_time, '%H:%i') AS end_time " +
	        "FROM doctor_schedules " +
	        "WHERE doctor_id = ? " +
	        "AND day_of_week = ? " +
	        "AND schedule_status = 'ACTIVE' " +
	        "AND valid_from <= ? " +
	        "AND (valid_until IS NULL OR valid_until >= ?) " +
	        "ORDER BY start_time";

	    try (Connection con = DBConnection.getConnection();
	         PreparedStatement ps = con.prepareStatement(sql)) {

	        ps.setInt(1, doctorId);
	        ps.setString(2, dayOfWeek);
	        ps.setDate(3, java.sql.Date.valueOf(appointmentDate));
	        ps.setDate(4, java.sql.Date.valueOf(appointmentDate));

	        try (ResultSet rs = ps.executeQuery()) {
	            while (rs.next()) {
	                schedules.add(new String[] {
	                    rs.getString("start_time"),
	                    rs.getString("end_time")
	                });
	            }
	        }
	    }

	    return schedules;
	}
	
	public List<String> getBookedAppointmentTimesForDoctorOnDate(
	        int doctorId, LocalDate appointmentDate) throws SQLException {

	    List<String> bookedTimes = new ArrayList<>();

	    String sql =
	        "SELECT DISTINCT TIME_FORMAT(appointment_datetime, '%H:%i') " +
	        "AS appointment_time " +
	        "FROM appointments " +
	        "WHERE doctor_id = ? " +
	        "AND DATE(appointment_datetime) = ? " +
	        "AND appointment_status <> 'CANCELLED'";

	    try (Connection con = DBConnection.getConnection();
	         PreparedStatement ps = con.prepareStatement(sql)) {

	        ps.setInt(1, doctorId);
	        ps.setDate(2, java.sql.Date.valueOf(appointmentDate));

	        try (ResultSet rs = ps.executeQuery()) {
	            while (rs.next()) {
	                bookedTimes.add(rs.getString("appointment_time"));
	            }
	        }
	    }

	    return bookedTimes;
	}
	
	public List<String> generate15MinuteSlots(
	        LocalTime startTime, LocalTime endTime) {

	    List<String> slots = new ArrayList<>();

	    LocalTime slot = startTime;

	    while (!slot.plusMinutes(15).isAfter(endTime)) {
	        slots.add(slot.toString());
	        slot = slot.plusMinutes(15);
	    }

	    return slots;
	}

	public boolean isDoctorAvailableForAppointment(
			int doctorId, LocalDateTime appointmentDateTime)
					throws SQLException {

		String sql =
				"SELECT COUNT(*) " +
						"FROM doctors d " +
						"WHERE d.doctor_id = ? " +
						"AND d.employment_status = 'ACTIVE' " +
						"AND EXISTS ( " +
						"    SELECT 1 " +
						"    FROM doctor_schedules ds " +
						"    WHERE ds.doctor_id = d.doctor_id " +
						"    AND ds.day_of_week = ? " +
						"    AND ds.schedule_status = 'ACTIVE' " +
						"    AND ds.valid_from <= ? " +
						"    AND (ds.valid_until IS NULL OR ds.valid_until >= ?) " +
						"    AND ? >= ds.start_time " +
						"    AND ADDTIME(?, '00:15:00') <= ds.end_time " +
						")";

		try (Connection con = DBConnection.getConnection();
				PreparedStatement ps = con.prepareStatement(sql)) {

			LocalDateTime slotEnd = appointmentDateTime.plusMinutes(15);

			ps.setInt(1, doctorId);
			ps.setString(
					2, appointmentDateTime.getDayOfWeek().name()
					);
			ps.setDate(
					3, java.sql.Date.valueOf(appointmentDateTime.toLocalDate())
					);
			ps.setDate(
					4, java.sql.Date.valueOf(appointmentDateTime.toLocalDate())
					);
			ps.setTime(5, Time.valueOf(appointmentDateTime.toLocalTime()));
			ps.setTime(6, Time.valueOf(slotEnd.toLocalTime()));

			try (ResultSet rs = ps.executeQuery()) {
				if (rs.next()) {
					return rs.getInt(1) > 0;
				}
			}
		}

		return false;
	}	
	
	public Integer getScheduleIdForAppointment(
	        int doctorId, LocalDateTime appointmentDateTime)
	        throws SQLException {

	    String sql =
	        "SELECT ds.schedule_id " +
	        "FROM doctor_schedules ds " +
	        "JOIN doctors d ON d.doctor_id = ds.doctor_id " +
	        "WHERE ds.doctor_id = ? " +
	        "AND d.employment_status = 'ACTIVE' " +
	        "AND ds.day_of_week = ? " +
	        "AND ds.schedule_status = 'ACTIVE' " +
	        "AND ds.valid_from <= ? " +
	        "AND (ds.valid_until IS NULL OR ds.valid_until >= ?) " +
	        "AND TIME(?) >= ds.start_time " +
	        "AND ADDTIME(TIME(?), '00:15:00') <= ds.end_time " +
	        "ORDER BY ds.start_time ASC, ds.schedule_id ASC " +
	        "LIMIT 1";

	    try (Connection con = DBConnection.getConnection();
	         PreparedStatement ps = con.prepareStatement(sql)) {

	        java.sql.Date appointmentDate =
	                java.sql.Date.valueOf(appointmentDateTime.toLocalDate());

	        java.sql.Time appointmentTime =
	                java.sql.Time.valueOf(appointmentDateTime.toLocalTime());

	        ps.setInt(1, doctorId);
	        ps.setString(2, appointmentDateTime.getDayOfWeek().name());
	        ps.setDate(3, appointmentDate);
	        ps.setDate(4, appointmentDate);
	        ps.setTime(5, appointmentTime);
	        ps.setTime(6, appointmentTime);

	        try (ResultSet rs = ps.executeQuery()) {
	            if (rs.next()) {
	                return rs.getInt("schedule_id");
	            }
	        }
	    }

	    return null;
	}

/* =========================================================
   APPOINTMENT WORKFLOW
   Add these methods inside the existing AppointmentDAO class.
   ========================================================= */

public List<Appointment> getAppointmentsForRole(
        String role, Integer doctorId) throws SQLException {

    List<Appointment> appointments = new ArrayList<>();

    String sql =
        "SELECT a.*, p.full_name AS patient_name, " +
        "d.full_name AS doctor_name " +
        "FROM appointments a " +
        "JOIN patients p ON a.patient_id = p.patient_id " +
        "JOIN doctors d ON a.doctor_id = d.doctor_id ";

    if ("DOCTOR".equalsIgnoreCase(role)) {
        if (doctorId == null || doctorId <= 0) {
            throw new SQLException(
                "The logged-in doctor has no linked doctor ID."
            );
        }
        sql += "WHERE a.doctor_id = ? ";
    }

    sql +=
        "ORDER BY CASE a.appointment_status " +
        "WHEN 'REQUESTED' THEN 1 " +
        "WHEN 'CONFIRMED' THEN 2 " +
        "WHEN 'CHECKED_IN' THEN 3 " +
        "ELSE 4 END, a.appointment_datetime ASC";

    try (Connection con = DBConnection.getConnection();
         PreparedStatement ps = con.prepareStatement(sql)) {

        if ("DOCTOR".equalsIgnoreCase(role)) {
            ps.setInt(1, doctorId);
        }

        try (ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Appointment a = new Appointment();

                a.setAppointmentId(rs.getInt("appointment_id"));
                a.setPatientId(rs.getInt("patient_id"));
                a.setDoctorId(rs.getInt("doctor_id"));

                Object schedule = rs.getObject("schedule_id");
                a.setScheduleId(
                    schedule == null ? null : ((Number) schedule).intValue()
                );

                a.setPatientName(rs.getString("patient_name"));
                a.setDoctorName(rs.getString("doctor_name"));
                a.setAppointmentDatetime(
                    rs.getTimestamp("appointment_datetime")
                );
                a.setReason(rs.getString("reason"));
                a.setAppointmentStatus(
                    rs.getString("appointment_status")
                );
                a.setCreatedBy((Integer) rs.getObject("created_by"));
                a.setNotes(rs.getString("notes"));
                a.setCreatedAt(rs.getTimestamp("created_at"));
                a.setUpdatedAt(rs.getTimestamp("updated_at"));

                appointments.add(a);
            }
        }
    }

    return appointments;
}

/**
 * Updates an appointment only if both its current status and
 * the acting user's permission match the requested transition.
 *
 * Returns false if the appointment is missing, its status has
 * changed, or the user is not authorised for that action.
 */
public boolean updateAppointmentStatus(
        int appointmentId,
        String newStatus,
        String role,
        Integer doctorId) throws SQLException {

    if (appointmentId <= 0 || role == null || newStatus == null) {
        return false;
    }

    String currentStatus;
    String allowedRoles;

    switch (newStatus) {
        case "CONFIRMED":
            currentStatus = "REQUESTED";
            allowedRoles = "DOCTOR_RECEPTIONIST";
            break;

        case "CHECKED_IN":
            currentStatus = "CONFIRMED";
            allowedRoles = "RECEPTIONIST";
            break;

        case "COMPLETED":
            currentStatus = "CHECKED_IN";
            allowedRoles = "DOCTOR";
            break;

        case "CANCELLED":
            currentStatus = "REQUESTED_CONFIRMED";
            allowedRoles = "DOCTOR_RECEPTIONIST";
            break;

        case "NO_SHOW":
            currentStatus = "CONFIRMED";
            allowedRoles = "RECEPTIONIST_STAFF";
            break;

        default:
            return false;
    }

    boolean isDoctor = "DOCTOR".equalsIgnoreCase(role);
    boolean isReceptionist =
        "RECEPTIONIST".equalsIgnoreCase(role);
    boolean isStaff = "STAFF".equalsIgnoreCase(role);

    boolean roleAllowed =
        ("DOCTOR_RECEPTIONIST".equals(allowedRoles)
            && (isDoctor || isReceptionist))
        || ("RECEPTIONIST".equals(allowedRoles) && isReceptionist)
        || ("DOCTOR".equals(allowedRoles) && isDoctor)
        || ("RECEPTIONIST_STAFF".equals(allowedRoles)
            && (isReceptionist || isStaff));

    if (!roleAllowed) {
        return false;
    }

    if (isDoctor && (doctorId == null || doctorId <= 0)) {
        return false;
    }

    String sql =
        "UPDATE appointments SET appointment_status = ?, " +
        "updated_at = CURRENT_TIMESTAMP " +
        "WHERE appointment_id = ? ";

    if ("REQUESTED_CONFIRMED".equals(currentStatus)) {
        sql += "AND appointment_status IN ('REQUESTED','CONFIRMED') ";
    } else {
        sql += "AND appointment_status = ? ";
    }

    if (isDoctor) {
        sql += "AND doctor_id = ? ";
    }

    try (Connection con = DBConnection.getConnection();
         PreparedStatement ps = con.prepareStatement(sql)) {

        int index = 1;
        ps.setString(index++, newStatus);
        ps.setInt(index++, appointmentId);

        if (!"REQUESTED_CONFIRMED".equals(currentStatus)) {
            ps.setString(index++, currentStatus);
        }

        if (isDoctor) {
            ps.setInt(index++, doctorId);
        }

        return ps.executeUpdate() == 1;
    }
}

}
