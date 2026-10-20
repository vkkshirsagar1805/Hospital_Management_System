
package com.hospital.dao;

import com.hospital.model.EmergencyContact;
import com.hospital.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class EmergencyContactDAO {

    public List<EmergencyContact> getAllContacts()
            throws SQLException {

        List<EmergencyContact> contacts = new ArrayList<>();

        String sql = "SELECT * FROM emergency_contacts "
                   + "ORDER BY contact_status ASC, contact_type ASC, "
                   + "contact_name ASC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                contacts.add(mapContact(rs));
            }
        }

        return contacts;
    }

    public List<EmergencyContact> getActiveContacts()
            throws SQLException {

        List<EmergencyContact> contacts = new ArrayList<>();

        String sql = "SELECT * FROM emergency_contacts "
                   + "WHERE contact_status = 'ACTIVE' "
                   + "ORDER BY contact_type ASC, contact_name ASC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                contacts.add(mapContact(rs));
            }
        }

        return contacts;
    }

    public EmergencyContact getContactById(int contactId)
            throws SQLException {

        String sql = "SELECT * FROM emergency_contacts "
                   + "WHERE contact_id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, contactId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapContact(rs);
                }
            }
        }

        return null;
    }

    public boolean addContact(EmergencyContact contact)
            throws SQLException {

        String sql = "INSERT INTO emergency_contacts "
                   + "(contact_name, contact_type, phone, "
                   + "alternate_phone, address, operating_hours, "
                   + "contact_status, notes) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, contact.getContactName());
            ps.setString(2, contact.getContactType());
            ps.setString(3, contact.getPhone());
            ps.setString(4, contact.getAlternatePhone());
            ps.setString(5, contact.getAddress());
            ps.setString(6, contact.getOperatingHours());
            ps.setString(7, "ACTIVE");
            ps.setString(8, contact.getNotes());

            return ps.executeUpdate() == 1;
        }
    }

    public boolean updateContact(EmergencyContact contact)
            throws SQLException {

        String sql = "UPDATE emergency_contacts SET "
                   + "contact_name = ?, contact_type = ?, phone = ?, "
                   + "alternate_phone = ?, address = ?, "
                   + "operating_hours = ?, notes = ? "
                   + "WHERE contact_id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, contact.getContactName());
            ps.setString(2, contact.getContactType());
            ps.setString(3, contact.getPhone());
            ps.setString(4, contact.getAlternatePhone());
            ps.setString(5, contact.getAddress());
            ps.setString(6, contact.getOperatingHours());
            ps.setString(7, contact.getNotes());
            ps.setInt(8, contact.getContactId());

            return ps.executeUpdate() == 1;
        }
    }

    public boolean updateContactStatus(int contactId, String status)
            throws SQLException {

        String sql = "UPDATE emergency_contacts "
                   + "SET contact_status = ? WHERE contact_id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, status);
            ps.setInt(2, contactId);

            return ps.executeUpdate() == 1;
        }
    }

    private EmergencyContact mapContact(ResultSet rs)
            throws SQLException {

        EmergencyContact contact = new EmergencyContact();

        contact.setContactId(rs.getInt("contact_id"));
        contact.setContactName(rs.getString("contact_name"));
        contact.setContactType(rs.getString("contact_type"));
        contact.setPhone(rs.getString("phone"));
        contact.setAlternatePhone(rs.getString("alternate_phone"));
        contact.setAddress(rs.getString("address"));
        contact.setOperatingHours(rs.getString("operating_hours"));
        contact.setContactStatus(rs.getString("contact_status"));
        contact.setNotes(rs.getString("notes"));
        contact.setCreatedAt(rs.getTimestamp("created_at"));

        return contact;
    }
}
