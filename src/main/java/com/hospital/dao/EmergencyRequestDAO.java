package com.hospital.dao;

import com.hospital.model.EmergencyRequest;
import com.hospital.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class EmergencyRequestDAO {

    public List<EmergencyRequest> getAllEmergencyRequests()
            throws SQLException {

        List<EmergencyRequest> requests = new ArrayList<>();

        String sql =
            "SELECT er.*, " +
            "p.full_name AS joined_patient_name, " +
            "a.vehicle_number AS joined_ambulance_number, " +
            "u.username AS joined_reported_by " +
            "FROM emergency_requests er " +
            "LEFT JOIN patients p ON er.patient_id = p.patient_id " +
            "LEFT JOIN ambulances a ON er.ambulance_id = a.ambulance_id " +
            "LEFT JOIN users u ON er.reported_by = u.user_id " +
            "ORDER BY er.requested_at DESC, " +
            "er.emergency_request_id DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                EmergencyRequest request = mapRequest(rs);

                request.setPatientName(
                    rs.getString("joined_patient_name"));

                request.setAmbulanceNumber(
                    rs.getString("joined_ambulance_number"));

                request.setReportedByUsername(
                    rs.getString("joined_reported_by"));

                requests.add(request);
            }
        }

        return requests;
    }

    public List<EmergencyRequest> getAllPatients()
            throws SQLException {

        List<EmergencyRequest> patients = new ArrayList<>();

        String sql =
        	    "SELECT patient_id, full_name " +
        	    "FROM patients ORDER BY full_name";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                EmergencyRequest item = new EmergencyRequest();
                item.setPatientId(rs.getInt("patient_id"));
                item.setPatientName(rs.getString("full_name"));
                patients.add(item);
            }
        }

        return patients;
    }

    public List<EmergencyRequest> getAvailableAmbulances()
            throws SQLException {

        List<EmergencyRequest> ambulances = new ArrayList<>();

        String sql =
            "SELECT ambulance_id, vehicle_number " +
            "FROM ambulances " +
            "WHERE ambulance_status = 'AVAILABLE' " +
            "ORDER BY vehicle_number";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                EmergencyRequest item = new EmergencyRequest();
                item.setAmbulanceId(rs.getInt("ambulance_id"));
                item.setAmbulanceNumber(
                    rs.getString("vehicle_number"));
                ambulances.add(item);
            }
        }

        return ambulances;
    }

    public int createEmergencyRequest(EmergencyRequest request)
            throws SQLException {

        String sql =
            "INSERT INTO emergency_requests " +
            "(patient_id, reported_by, emergency_type, severity, " +
            "request_location, request_description, request_status) " +
            "VALUES (?, ?, ?, ?, ?, ?, 'REPORTED')";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(
                 sql, Statement.RETURN_GENERATED_KEYS)) {

            if (request.getPatientId() == null) {
                ps.setNull(1, java.sql.Types.INTEGER);
            } else {
                ps.setInt(1, request.getPatientId());
            }

            if (request.getReportedBy() == null) {
                ps.setNull(2, java.sql.Types.INTEGER);
            } else {
                ps.setInt(2, request.getReportedBy());
            }

            ps.setString(3, request.getEmergencyType());
            ps.setString(4, request.getSeverity());
            ps.setString(5, request.getRequestLocation());
            ps.setString(6, request.getRequestDescription());

            ps.executeUpdate();

            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) {
                    return keys.getInt(1);
                }
            }
        }

        return -1;
    }
    
    public void updateEmergencyStatus(
    	int requestId,
    	String newStatus,
    	String resolutionNotes) throws SQLException {

    	String findSql =
    			"SELECT ambulance_id FROM emergency_requests " +
    			"WHERE emergency_request_id = ? FOR UPDATE";

    	String updateSql =
    			"UPDATE emergency_requests " +
    			"SET request_status = ?, " +
    			"dispatched_at = CASE " +
    			"WHEN ? = 'DISPATCHED' AND dispatched_at IS NULL " +
    			"THEN CURRENT_TIMESTAMP ELSE dispatched_at END, " +
    			"resolved_at = CASE " +
    			"WHEN ? IN ('RESOLVED', 'CANCELLED') " +
    			"THEN CURRENT_TIMESTAMP " +
    			"WHEN ? IN ('REPORTED', 'ACKNOWLEDGED', " +
    			"'DISPATCHED', 'IN_PROGRESS') THEN NULL " +
    			"ELSE resolved_at END, " +
    			"resolution_notes = ? " +
    			"WHERE emergency_request_id = ?";

    	String releaseSql =
    			"UPDATE ambulances " +
    			"SET ambulance_status = 'AVAILABLE' " +
    			"WHERE ambulance_id = ? " +
    			"AND ambulance_status = 'ASSIGNED'";

    	try (Connection con = DBConnection.getConnection()) {
    		boolean originalAutoCommit = con.getAutoCommit();
    		con.setAutoCommit(false);

    		try {
    			Integer ambulanceId = null;

    			try (PreparedStatement ps =
    				con.prepareStatement(findSql)) {

    				ps.setInt(1, requestId);
    				
    				try (ResultSet rs = ps.executeQuery()) {
    					if (!rs.next()) {
    						throw new SQLException(
    								"Emergency request not found: " + requestId);
    					}

    					ambulanceId = rs.getObject(
    							"ambulance_id", Integer.class);
    				}
    			}

            try (PreparedStatement ps =
                     con.prepareStatement(updateSql)) {

                ps.setString(1, newStatus);
                ps.setString(2, newStatus);
                ps.setString(3, newStatus);
                ps.setString(4, newStatus);
                ps.setString(5, resolutionNotes);
                ps.setInt(6, requestId);

                ps.executeUpdate();
            }

            if (ambulanceId != null
                    && ("RESOLVED".equals(newStatus)
                    || "CANCELLED".equals(newStatus))) {

                try (PreparedStatement ps =
                         con.prepareStatement(releaseSql)) {
                    ps.setInt(1, ambulanceId);
                    ps.executeUpdate();
                }
            }

            	con.commit();

    		} catch (SQLException e) {
            	con.rollback();
            	throw e;

        	} finally {
            	con.setAutoCommit(originalAutoCommit);
        	}
    	}
    }
    
    public void assignAmbulance(
            int requestId, int ambulanceId) throws SQLException {

        String updateRequest =
            "UPDATE emergency_requests " +
            "SET ambulance_id = ?, request_status = 'DISPATCHED', " +
            "dispatched_at = CURRENT_TIMESTAMP " +
            "WHERE emergency_request_id = ? " +
            "AND request_status NOT IN ('RESOLVED', 'CANCELLED')";

        String updateAmbulance =
            "UPDATE ambulances SET ambulance_status = 'ASSIGNED' " +
            "WHERE ambulance_id = ? " +
            "AND ambulance_status = 'AVAILABLE'";

        String releasePrevious =
            "UPDATE ambulances SET ambulance_status = 'AVAILABLE' " +
            "WHERE ambulance_id = ? " +
            "AND ambulance_status = 'ASSIGNED'";

        try (Connection con = DBConnection.getConnection()) {
            con.setAutoCommit(false);

            try {
                Integer previousAmbulanceId = null;

                String findPrevious =
                    "SELECT ambulance_id FROM emergency_requests " +
                    "WHERE emergency_request_id = ? FOR UPDATE";

                try (PreparedStatement ps =
                         con.prepareStatement(findPrevious)) {
                    ps.setInt(1, requestId);

                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) {
                            throw new SQLException(
                                "Emergency request not found.");
                        }

                        previousAmbulanceId = rs.getObject(
                            "ambulance_id", Integer.class);
                    }
                }

                if (previousAmbulanceId != null
                        && previousAmbulanceId == ambulanceId) {
                    con.commit();
                    return;
                }

                try (PreparedStatement ps =
                         con.prepareStatement(updateAmbulance)) {
                    ps.setInt(1, ambulanceId);

                    if (ps.executeUpdate() != 1) {
                        throw new SQLException(
                            "Ambulance is no longer available.");
                    }
                }

                try (PreparedStatement ps =
                         con.prepareStatement(updateRequest)) {
                    ps.setInt(1, ambulanceId);
                    ps.setInt(2, requestId);

                    if (ps.executeUpdate() != 1) {
                        throw new SQLException(
                            "Request cannot be dispatched.");
                    }
                }

                if (previousAmbulanceId != null) {
                    try (PreparedStatement ps =
                             con.prepareStatement(releasePrevious)) {
                        ps.setInt(1, previousAmbulanceId);
                        ps.executeUpdate();
                    }
                }

                con.commit();

            } catch (SQLException e) {
                con.rollback();
                throw e;
            } finally {
                con.setAutoCommit(true);
            }
        }
    }

    private EmergencyRequest mapRequest(ResultSet rs)
            throws SQLException {

        EmergencyRequest request = new EmergencyRequest();

        request.setEmergencyRequestId(
            rs.getInt("emergency_request_id"));

        int patientId = rs.getInt("patient_id");
        request.setPatientId(
            rs.wasNull() ? null : patientId);

        int ambulanceId = rs.getInt("ambulance_id");
        request.setAmbulanceId(
            rs.wasNull() ? null : ambulanceId);

        int reportedBy = rs.getInt("reported_by");
        request.setReportedBy(
            rs.wasNull() ? null : reportedBy);

        request.setEmergencyType(rs.getString("emergency_type"));
        request.setSeverity(rs.getString("severity"));
        request.setRequestLocation(rs.getString("request_location"));
        request.setRequestDescription(
            rs.getString("request_description"));
        request.setRequestStatus(rs.getString("request_status"));

        Timestamp requestedAt = rs.getTimestamp("requested_at");
        request.setRequestedAt(requestedAt);

        request.setDispatchedAt(rs.getTimestamp("dispatched_at"));
        request.setResolvedAt(rs.getTimestamp("resolved_at"));
        request.setResolutionNotes(rs.getString("resolution_notes"));

        return request;
    }
}
