
package com.hospital.dao;

import java.sql.Connection;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import com.hospital.model.Department;
import com.hospital.util.DBConnection;


public class DepartmentDAO {

	public boolean addDepartment(String departmentName,
							String description,
                             String location,
                             String status) throws SQLException {

		String sql = """
            INSERT INTO departments
                (department_name, description, location, status)
            VALUES (?, ?, ?, ?)
            """;

		try (Connection connection = DBConnection.getConnection();
				PreparedStatement statement = connection.prepareStatement(sql)) {

			statement.setString(1, departmentName);
			statement.setString(2, description);
			statement.setString(3, location);
			statement.setString(4, status);

		return statement.executeUpdate() == 1;
    }
}


    public List<Department> getAllDepartments() throws SQLException {

        List<Department> departments = new ArrayList<>();

        String sql = """
                SELECT department_id, department_name, description,
                       location, status, created_at
                FROM departments
                ORDER BY department_id
                """;

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
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

public Department getDepartmentById(int departmentId)
        throws SQLException {

    String sql = """
            SELECT department_id, department_name, description,
                   location, status, created_at
            FROM departments
            WHERE department_id = ?
            """;

    try (Connection connection = DBConnection.getConnection();
         PreparedStatement statement = connection.prepareStatement(sql)) {

        statement.setInt(1, departmentId);

        try (ResultSet resultSet = statement.executeQuery()) {

            if (resultSet.next()) {
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

                return department;
            }
        }
    }

    return null;
}


	public boolean updateDepartment(int departmentId,
                               String departmentName,
                               String description,
                               String location,
                               String status) throws SQLException {

    String sql = """
            UPDATE departments
            SET department_name = ?,
                description = ?,
                location = ?,
                status = ?
            WHERE department_id = ?
            """;

    try (Connection connection = DBConnection.getConnection();
         PreparedStatement statement = connection.prepareStatement(sql)) {

        statement.setString(1, departmentName);
        statement.setString(2, description);
        statement.setString(3, location);
        statement.setString(4, status);
        statement.setInt(5, departmentId);

        return statement.executeUpdate() == 1;
    }
}


	public boolean deleteDepartment(int departmentId) throws SQLException {

			String sql = """
					DELETE FROM departments
					WHERE department_id = ?
					""";

			try (Connection connection = DBConnection.getConnection();
					PreparedStatement statement = connection.prepareStatement(sql)) {

			statement.setInt(1, departmentId);

        		return statement.executeUpdate() == 1;
		}
	}
}
