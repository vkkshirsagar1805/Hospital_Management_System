
package com.hospital.dao;

import com.hospital.model.StaffAssignment;
import com.hospital.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class StaffAssignmentDAO {

    // Get all staff assignments with staff and department names
	public List<StaffAssignment> getAllAssignments() throws SQLException {

	    List<StaffAssignment> assignments = new ArrayList<>();

	    String sql =
	        "SELECT sa.* " +
	        "FROM staff_assignments sa " +
	        "ORDER BY sa.shift_start DESC";

	    try (Connection con = DBConnection.getConnection();
	         PreparedStatement ps = con.prepareStatement(sql);
	         ResultSet rs = ps.executeQuery()) {

	        while (rs.next()) {
	            assignments.add(mapAssignment(rs));
	        }
	    }

	    return assignments;
	}
    // Create a new staff assignment
    public boolean addAssignment(StaffAssignment a) throws SQLException {

        String sql =
            "INSERT INTO staff_assignments " +
            "(staff_id, department_id, assigned_by, assignment_title, " +
            "duty_location, shift_start, shift_end, assignment_status, notes) " +
            "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, a.getStaffId());
            ps.setInt(2, a.getDepartmentId());

            if (a.getAssignedBy() == null) {
                ps.setNull(3, Types.INTEGER);
            } else {
                ps.setInt(3, a.getAssignedBy());
            }

            ps.setString(4, a.getAssignmentTitle());
            ps.setString(5, a.getDutyLocation());
            ps.setTimestamp(6, a.getShiftStart());
            ps.setTimestamp(7, a.getShiftEnd());
            ps.setString(8, a.getAssignmentStatus());
            ps.setString(9, a.getNotes());

            return ps.executeUpdate() == 1;
        }
    }

    // Update assignment status
    public boolean updateStatus(int assignmentId, String status)
            throws SQLException {

        String sql =
            "UPDATE staff_assignments " +
            "SET assignment_status = ? " +
            "WHERE assignment_id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, status);
            ps.setInt(2, assignmentId);

            return ps.executeUpdate() == 1;
        }
    }

    // Map database columns to the Java model
    private StaffAssignment mapAssignment(ResultSet rs)
            throws SQLException {

        StaffAssignment a = new StaffAssignment();

        a.setAssignmentId(rs.getInt("assignment_id"));
        a.setStaffId(rs.getInt("staff_id"));
        a.setDepartmentId(rs.getInt("department_id"));

        int assignedBy = rs.getInt("assigned_by");
        a.setAssignedBy(rs.wasNull() ? null : assignedBy);

        a.setAssignmentTitle(rs.getString("assignment_title"));
        a.setDutyLocation(rs.getString("duty_location"));
        a.setShiftStart(rs.getTimestamp("shift_start"));
        a.setShiftEnd(rs.getTimestamp("shift_end"));
        a.setAssignmentStatus(rs.getString("assignment_status"));
        a.setNotes(rs.getString("notes"));
        a.setCreatedAt(rs.getTimestamp("created_at"));

        return a;
    }
}
