
package com.hospital.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Date;
import java.util.ArrayList;
import java.util.List;

import com.hospital.model.Patient;
import com.hospital.util.DBConnection;

public class PatientDAO {

    // READ: Retrieve all patients from the database
    public List<Patient> getAllPatients() throws SQLException {

        List<Patient> patients = new ArrayList<>();

        String sql = """
                SELECT patient_id, user_id, full_name, date_of_birth,
                       gender, phone, email, address,
                       registration_date, record_status
                FROM patients
                ORDER BY patient_id DESC
                """;

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(sql);
             ResultSet resultSet = statement.executeQuery()) {

            while (resultSet.next()) {

                Patient patient = new Patient();

                patient.setPatientId(
                    resultSet.getInt("patient_id")
                );

                int userId = resultSet.getInt("user_id");
                if (resultSet.wasNull()) {
                    patient.setUserId(null);
                } else {
                    patient.setUserId(userId);
                }

                patient.setFullName(
                    resultSet.getString("full_name")
                );

                patient.setDateOfBirth(
                    resultSet.getDate("date_of_birth")
                );

                patient.setGender(
                    resultSet.getString("gender")
                );

                patient.setPhone(
                    resultSet.getString("phone")
                );

                patient.setEmail(
                    resultSet.getString("email")
                );

                patient.setAddress(
                    resultSet.getString("address")
                );

                patient.setRegistrationDate(
                    resultSet.getTimestamp("registration_date")
                );

                patient.setRecordStatus(
                    resultSet.getString("record_status")
                );

                patients.add(patient);
            }
        }

        return patients;
    }

    // READ: Retrieve one patient using the patient ID
    public Patient getPatientById(int patientId)
            throws SQLException {

        String sql = """
                SELECT patient_id, user_id, full_name, date_of_birth,
                       gender, phone, email, address,
                       registration_date, record_status
                FROM patients
                WHERE patient_id = ?
                """;

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            statement.setInt(1, patientId);

            try (ResultSet resultSet = statement.executeQuery()) {

                if (resultSet.next()) {

                    Patient patient = new Patient();

                    patient.setPatientId(
                        resultSet.getInt("patient_id")
                    );

                    int userId = resultSet.getInt("user_id");
                    patient.setUserId(
                        resultSet.wasNull() ? null : userId
                    );

                    patient.setFullName(
                        resultSet.getString("full_name")
                    );

                    patient.setDateOfBirth(
                        resultSet.getDate("date_of_birth")
                    );

                    patient.setGender(
                        resultSet.getString("gender")
                    );

                    patient.setPhone(
                        resultSet.getString("phone")
                    );

                    patient.setEmail(
                        resultSet.getString("email")
                    );

                    patient.setAddress(
                        resultSet.getString("address")
                    );

                    patient.setRegistrationDate(
                        resultSet.getTimestamp("registration_date")
                    );

                    patient.setRecordStatus(
                        resultSet.getString("record_status")
                    );

                    return patient;
                }
            }
        }

        return null;
    }
    
    public int addPatient(Patient patient) throws SQLException {

        String sql = """
            INSERT INTO patients
                (full_name, date_of_birth, gender, phone,
                 email, address, record_status)
            VALUES (?, ?, ?, ?, ?, ?, ?)
            """;

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(
                 sql, java.sql.Statement.RETURN_GENERATED_KEYS)) {

            statement.setString(1, patient.getFullName());

            if (patient.getDateOfBirth() != null) {
                statement.setDate(2, patient.getDateOfBirth());
            } else {
                statement.setNull(2, java.sql.Types.DATE);
            }

            statement.setString(3, patient.getGender());
            statement.setString(4, patient.getPhone());
            statement.setString(5, patient.getEmail());
            statement.setString(6, patient.getAddress());
            statement.setString(7, patient.getRecordStatus());

            int rowsInserted = statement.executeUpdate();

            if (rowsInserted != 1) {
                return -1;
            }

            try (java.sql.ResultSet keys = statement.getGeneratedKeys()) {
                if (keys.next()) {
                    return keys.getInt(1);
                }
            }

            return -1;
        }
    }
    
    public boolean updatePatient(Patient patient) throws SQLException {

    String sql = """
            UPDATE patients
            SET full_name = ?,
                date_of_birth = ?,
                gender = ?,
                phone = ?,
                email = ?,
                address = ?,
                record_status = ?
            WHERE patient_id = ?
            """;

    try (Connection connection = DBConnection.getConnection();
         PreparedStatement statement =
                 connection.prepareStatement(sql)) {

        statement.setString(1, patient.getFullName());

        if (patient.getDateOfBirth() != null) {
            statement.setDate(2, patient.getDateOfBirth());
        } else {
            statement.setNull(2, java.sql.Types.DATE);
        }

        statement.setString(3, patient.getGender());
        statement.setString(4, patient.getPhone());
        statement.setString(5, patient.getEmail());
        statement.setString(6, patient.getAddress());
        statement.setString(7, patient.getRecordStatus());
        statement.setInt(8, patient.getPatientId());

        return statement.executeUpdate() == 1;
    }
    }

	public boolean deletePatient(int patientId) throws SQLException {

		String sql = """
            DELETE FROM patients
            WHERE patient_id = ?
            """;

		try (Connection connection = DBConnection.getConnection();
				PreparedStatement statement =
                 connection.prepareStatement(sql)) {

        statement.setInt(1, patientId);

        	return statement.executeUpdate() == 1;
		}
	}
	
	public boolean updatePatientStatus(int patientId, String status)
	        throws SQLException {

	    String sql =
	        "UPDATE patients SET record_status = ? WHERE patient_id = ?";

	    try (Connection connection = DBConnection.getConnection();
	         PreparedStatement statement = connection.prepareStatement(sql)) {

	        statement.setString(1, status);
	        statement.setInt(2, patientId);

	        return statement.executeUpdate() > 0;
	    }
	}

}
