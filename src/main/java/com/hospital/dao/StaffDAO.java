
package com.hospital.dao;

import com.hospital.model.Staff;
import com.hospital.model.Department;
import com.hospital.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class StaffDAO {

    // Retrieve all staff records
    public List<Staff> getAllStaff() throws SQLException {

        List<Staff> staffList = new ArrayList<>();

        String sql = "SELECT * FROM staff ORDER BY staff_id DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                staffList.add(mapStaff(rs));
            }
        }

        return staffList;
    }

    // Retrieve one staff member by ID
    public Staff getStaffById(int staffId) throws SQLException {

        String sql = "SELECT * FROM staff WHERE staff_id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, staffId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapStaff(rs);
                }
            }
        }

        return null;
    }

    // Convert a database row into a Staff object
    private Staff mapStaff(ResultSet rs) throws SQLException {

        Staff staff = new Staff();

        staff.setStaffId(rs.getInt("staff_id"));

        int userId = rs.getInt("user_id");
        staff.setUserId(rs.wasNull() ? null : userId);

        staff.setDepartmentId(rs.getInt("department_id"));

        int supervisorStaffId = rs.getInt("supervisor_staff_id");
        staff.setSupervisorStaffId(
            rs.wasNull() ? null : supervisorStaffId
        );

        int supervisorDoctorId = rs.getInt("supervisor_doctor_id");
        staff.setSupervisorDoctorId(
            rs.wasNull() ? null : supervisorDoctorId
        );

        staff.setFullName(rs.getString("full_name"));
        staff.setDesignation(rs.getString("designation"));
        staff.setStaffType(rs.getString("staff_type"));
        staff.setPhone(rs.getString("phone"));
        staff.setEmail(rs.getString("email"));
        staff.setEmploymentStatus(rs.getString("employment_status"));
        staff.setCreatedAt(rs.getTimestamp("created_at"));

        return staff;
    }

    // Retrieve active departments for the staff form dropdown
    public List<Department> getActiveDepartments() throws SQLException {

        List<Department> departments = new ArrayList<>();

        String sql = "SELECT department_id, department_name, "
                   + "description, location, status, created_at "
                   + "FROM departments "
                   + "WHERE status = 'ACTIVE' "
                   + "ORDER BY department_name";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {

                Department department = new Department();

                department.setDepartmentId(
                    rs.getInt("department_id")
                );

                department.setDepartmentName(
                    rs.getString("department_name")
                );

                department.setDescription(
                    rs.getString("description")
                );

                department.setLocation(
                    rs.getString("location")
                );

                department.setStatus(
                    rs.getString("status")
                );

                department.setCreatedAt(
                    rs.getTimestamp("created_at")
                );

                departments.add(department);
            }
        }

        return departments;
    }

    // Register a new staff member
    public boolean addStaff(Staff staff) throws SQLException {

        String sql = "INSERT INTO staff "
                   + "(department_id, full_name, designation, "
                   + "staff_type, phone, email, employment_status) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?)";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, staff.getDepartmentId());
            ps.setString(2, staff.getFullName());
            ps.setString(3, staff.getDesignation());
            ps.setString(4, staff.getStaffType());
            ps.setString(5, staff.getPhone());
            ps.setString(6, staff.getEmail());
            ps.setString(7, "ACTIVE");

            return ps.executeUpdate() == 1;
        }
    }

    // Update an existing staff member
    public boolean updateStaff(Staff staff) throws SQLException {

        String sql = "UPDATE staff SET department_id = ?, "
                   + "full_name = ?, designation = ?, staff_type = ?, "
                   + "phone = ?, email = ?, employment_status = ? "
                   + "WHERE staff_id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, staff.getDepartmentId());
            ps.setString(2, staff.getFullName());
            ps.setString(3, staff.getDesignation());
            ps.setString(4, staff.getStaffType());
            ps.setString(5, staff.getPhone());
            ps.setString(6, staff.getEmail());
            ps.setString(7, staff.getEmploymentStatus());
            ps.setInt(8, staff.getStaffId());

            return ps.executeUpdate() == 1;
        }
    }

    // Delete a staff member by ID
    public boolean deleteStaff(int staffId) throws SQLException {

        String sql = "DELETE FROM staff WHERE staff_id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, staffId);

            return ps.executeUpdate() == 1;
        }
    }
    // Activate or deactivate a staff member
    public boolean updateStaffStatus(int staffId, String status) throws SQLException {

    	String sql = """
             UPDATE staff
             SET employment_status = ?
             WHERE staff_id = ?
             """;

    	try (Connection con = DBConnection.getConnection();
    			PreparedStatement ps = con.prepareStatement(sql)) {

    		ps.setString(1, status);
    		ps.setInt(2, staffId);

    		return ps.executeUpdate() == 1;
    	}
    }
}
