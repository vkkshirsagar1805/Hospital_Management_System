
package com.hospital.dao;

import com.hospital.model.Ambulance;
import com.hospital.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class AmbulanceDAO {

    public List<Ambulance> getAllAmbulances() throws SQLException {
        List<Ambulance> ambulances = new ArrayList<>();

        String sql = "SELECT * FROM ambulances ORDER BY ambulance_status ASC, vehicle_number ASC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                ambulances.add(mapAmbulance(rs));
            }
        }

        return ambulances;
    }

    public List<Ambulance> getAvailableAmbulances() throws SQLException {
        List<Ambulance> ambulances = new ArrayList<>();

        String sql = "SELECT * FROM ambulances WHERE ambulance_status = 'AVAILABLE' "
                   + "ORDER BY vehicle_number ASC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                ambulances.add(mapAmbulance(rs));
            }
        }

        return ambulances;
    }

    public Ambulance getAmbulanceById(int ambulanceId) throws SQLException {
        String sql = "SELECT * FROM ambulances WHERE ambulance_id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, ambulanceId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapAmbulance(rs);
                }
            }
        }

        return null;
    }

    public boolean addAmbulance(Ambulance ambulance) throws SQLException {
        String sql = "INSERT INTO ambulances "
                   + "(vehicle_number, ambulance_type, driver_name, driver_phone, "
                   + "current_location, ambulance_status, notes) "
                   + "VALUES (?, ?, ?, ?, ?, 'AVAILABLE', ?)";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, ambulance.getVehicleNumber());
            ps.setString(2, ambulance.getAmbulanceType());
            ps.setString(3, ambulance.getDriverName());
            ps.setString(4, ambulance.getDriverPhone());
            ps.setString(5, ambulance.getCurrentLocation());
            ps.setString(6, ambulance.getNotes());

            return ps.executeUpdate() == 1;
        }
    }

    public boolean updateAmbulance(Ambulance ambulance) throws SQLException {
        String sql = "UPDATE ambulances SET vehicle_number = ?, ambulance_type = ?, "
                   + "driver_name = ?, driver_phone = ?, current_location = ?, notes = ? "
                   + "WHERE ambulance_id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, ambulance.getVehicleNumber());
            ps.setString(2, ambulance.getAmbulanceType());
            ps.setString(3, ambulance.getDriverName());
            ps.setString(4, ambulance.getDriverPhone());
            ps.setString(5, ambulance.getCurrentLocation());
            ps.setString(6, ambulance.getNotes());
            ps.setInt(7, ambulance.getAmbulanceId());

            return ps.executeUpdate() == 1;
        }
    }

    public boolean updateAmbulanceStatus(int ambulanceId, String status)
            throws SQLException {

        if (!isValidStatus(status)) {
            throw new IllegalArgumentException("Invalid ambulance status.");
        }

        String sql = "UPDATE ambulances SET ambulance_status = ? "
                   + "WHERE ambulance_id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, status);
            ps.setInt(2, ambulanceId);

            return ps.executeUpdate() == 1;
        }
    }

    private boolean isValidStatus(String status) {
        return status != null && (
                status.equals("AVAILABLE")
                || status.equals("ASSIGNED")
                || status.equals("ON_TRIP")
                || status.equals("MAINTENANCE")
                || status.equals("OUT_OF_SERVICE")
        );
    }

    private Ambulance mapAmbulance(ResultSet rs) throws SQLException {
        Ambulance ambulance = new Ambulance();

        ambulance.setAmbulanceId(rs.getInt("ambulance_id"));
        ambulance.setVehicleNumber(rs.getString("vehicle_number"));
        ambulance.setAmbulanceType(rs.getString("ambulance_type"));
        ambulance.setDriverName(rs.getString("driver_name"));
        ambulance.setDriverPhone(rs.getString("driver_phone"));
        ambulance.setCurrentLocation(rs.getString("current_location"));
        ambulance.setAmbulanceStatus(rs.getString("ambulance_status"));
        ambulance.setLastStatusUpdate(rs.getTimestamp("last_status_update"));
        ambulance.setNotes(rs.getString("notes"));
        ambulance.setCreatedAt(rs.getTimestamp("created_at"));

        return ambulance;
    }
}
