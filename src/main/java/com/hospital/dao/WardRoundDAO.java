
package com.hospital.dao;

import com.hospital.model.WardRound;
import com.hospital.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class WardRoundDAO {

    public List<WardRound> getAllWardRounds() throws SQLException {
        List<WardRound> rounds = new ArrayList<>();

        String sql = "SELECT * FROM ward_rounds "
                   + "ORDER BY round_date DESC, start_time DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                rounds.add(mapWardRound(rs));
            }
        }

        return rounds;
    }

    public WardRound getWardRoundById(int wardRoundId)
            throws SQLException {

        String sql = "SELECT * FROM ward_rounds WHERE ward_round_id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, wardRoundId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapWardRound(rs);
                }
            }
        }

        return null;
    }

    public boolean addWardRound(WardRound round) throws SQLException {
        String sql = "INSERT INTO ward_rounds "
                   + "(doctor_id, round_date, start_time, end_time, "
                   + "ward_name, notes, round_status) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?)";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, round.getDoctorId());
            ps.setDate(2, round.getRoundDate());
            ps.setTime(3, round.getStartTime());
            ps.setTime(4, round.getEndTime());
            ps.setString(5, round.getWardName());
            ps.setString(6, round.getNotes());
            ps.setString(7, "PLANNED");

            return ps.executeUpdate() == 1;
        }
    }

    public boolean updateStatus(int wardRoundId, String status)
            throws SQLException {

        String sql = "UPDATE ward_rounds "
                   + "SET round_status = ? WHERE ward_round_id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, status);
            ps.setInt(2, wardRoundId);

            return ps.executeUpdate() == 1;
        }
    }

    private WardRound mapWardRound(ResultSet rs) throws SQLException {
        WardRound round = new WardRound();

        round.setWardRoundId(rs.getInt("ward_round_id"));
        round.setDoctorId(rs.getInt("doctor_id"));
        round.setRoundDate(rs.getDate("round_date"));
        round.setStartTime(rs.getTime("start_time"));
        round.setEndTime(rs.getTime("end_time"));
        round.setWardName(rs.getString("ward_name"));
        round.setNotes(rs.getString("notes"));
        round.setRoundStatus(rs.getString("round_status"));
        round.setCreatedAt(rs.getTimestamp("created_at"));

        return round;
    }
}
