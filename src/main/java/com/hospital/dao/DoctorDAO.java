
package com.hospital.dao;

import com.hospital.model.Doctor;
import com.hospital.util.DBConnection;
import com.hospital.model.Department;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class DoctorDAO {

    // Get all doctors
	public List<Doctor> getAllDoctors() throws SQLException {
		List<Doctor> doctors = new ArrayList<>();

		String sql = """
            SELECT d.*, dep.department_name
            FROM doctors d
            INNER JOIN departments dep
                ON d.department_id = dep.department_id
            ORDER BY d.doctor_id
            """;

		try (Connection con = DBConnection.getConnection();
				PreparedStatement ps = con.prepareStatement(sql);
				ResultSet rs = ps.executeQuery()) {

        while (rs.next()) {
            doctors.add(mapDoctor(rs));
        }
    }

    return doctors;
}

	
	// Get one doctor by ID

	public Doctor getDoctorById(int doctorId) throws SQLException {
		String sql = """
            SELECT d.*, dep.department_name
            FROM doctors d
            LEFT JOIN departments dep
                ON d.department_id = dep.department_id
            WHERE d.doctor_id = ?
            """;

		try (Connection con = DBConnection.getConnection();
				PreparedStatement ps = con.prepareStatement(sql)) {

			ps.setInt(1, doctorId);

			try (ResultSet rs = ps.executeQuery()) {
				if (rs.next()) {
					return mapDoctor(rs);
				}
			}
		}

		return null;
	}


    // Convert a database row into a Doctor object
    private Doctor mapDoctor(ResultSet resultSet) throws SQLException {

        Doctor doctor = new Doctor();

        doctor.setDoctorId(resultSet.getInt("doctor_id"));

        int userId = resultSet.getInt("user_id");
        doctor.setUserId(
                resultSet.wasNull() ? null : userId
        );

        doctor.setDepartmentId(
                resultSet.getInt("department_id")
        );
        
        doctor.setDepartmentName(
        		resultSet.getString("department_name")
        );

        doctor.setFullName(
                resultSet.getString("full_name")
        );

        doctor.setSpecialization(
                resultSet.getString("specialization")
        );

        doctor.setQualification(
                resultSet.getString("qualification")
        );

        doctor.setPhone(
                resultSet.getString("phone")
        );

        doctor.setEmail(
                resultSet.getString("email")
        );

        doctor.setEmploymentStatus(
                resultSet.getString("employment_status")
        );

        doctor.setCreatedAt(
                resultSet.getTimestamp("created_at")
        );

        return doctor;
    }

    // Get active departments for the doctor registration dropdown
    public List<Department> getActiveDepartments() throws SQLException {

        List<Department> departments = new ArrayList<>();

        String sql = """
                SELECT department_id, department_name, description,
                       location, status, created_at
                FROM departments
                WHERE status = 'ACTIVE'
                ORDER BY department_name
                """;

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(sql);
             ResultSet resultSet = statement.executeQuery()) {

            while (resultSet.next()) {
                Department department = new Department();

                department.setDepartmentId(
                        resultSet.getInt("department_id"));
                department.setDepartmentName(
                        resultSet.getString("department_name"));
                department.setDescription(
                        resultSet.getString("description"));
                department.setLocation(
                        resultSet.getString("location"));
                department.setStatus(
                        resultSet.getString("status"));
                department.setCreatedAt(
                        resultSet.getTimestamp("created_at"));

                departments.add(department);
            }
        }

        return departments;
    }

    // Register a new doctor in the database
    public boolean addDoctor(Doctor doctor) throws SQLException {

        String sql = """
                INSERT INTO doctors
                    (department_id, full_name, specialization,
                     qualification, phone, email, employment_status)
                VALUES (?, ?, ?, ?, ?, ?, ?)
                """;

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            statement.setInt(1, doctor.getDepartmentId());
            statement.setString(2, doctor.getFullName());
            statement.setString(3, doctor.getSpecialization());
            statement.setString(4, doctor.getQualification());
            statement.setString(5, doctor.getPhone());
            statement.setString(6, doctor.getEmail());
            statement.setString(7, doctor.getEmploymentStatus());

            return statement.executeUpdate() == 1;
        }
    }

    // Update an existing doctor's details
    public boolean updateDoctor(Doctor doctor) throws SQLException {

        String sql = """
                UPDATE doctors
                SET department_id = ?,
                    full_name = ?,
                    specialization = ?,
                    qualification = ?,
                    phone = ?,
                    email = ?,
                    employment_status = ?
                WHERE doctor_id = ?
                """;

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            statement.setInt(1, doctor.getDepartmentId());
            statement.setString(2, doctor.getFullName());
            statement.setString(3, doctor.getSpecialization());
            statement.setString(4, doctor.getQualification());
            statement.setString(5, doctor.getPhone());
            statement.setString(6, doctor.getEmail());
            statement.setString(7, doctor.getEmploymentStatus());
            statement.setInt(8, doctor.getDoctorId());

            return statement.executeUpdate() == 1;
        }
    }

    // Delete a doctor by ID
    public boolean deleteDoctor(int doctorId) throws SQLException {

        String sql = """
                DELETE FROM doctors
                WHERE doctor_id = ?
                """;

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            statement.setInt(1, doctorId);

            return statement.executeUpdate() == 1;
        }
    }

    // Activate or deactivate a doctor
    public boolean updateDoctorStatus(int doctorId, String status)
            throws SQLException {

        String sql = """
                UPDATE doctors
                SET employment_status = ?
                WHERE doctor_id = ?
                """;

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            statement.setString(1, status);
            statement.setInt(2, doctorId);

            return statement.executeUpdate() == 1;
        }
    }
}
