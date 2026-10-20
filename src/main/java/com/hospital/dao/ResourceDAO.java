
package com.hospital.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import com.hospital.util.DBConnection;

public class ResourceDAO {

    // Retrieve all beds
    public List<Map<String, Object>> getAllBeds()
            throws SQLException {

        String sql = """
                SELECT bed_id, bed_number, ward_name, bed_type,
                       bed_status, floor_number, daily_charge, notes
                FROM beds
                ORDER BY ward_name, bed_number
                """;

        return executeQuery(sql);
    }

    // Retrieve all equipment and available quantities
    public List<Map<String, Object>> getAllResources()
            throws SQLException {

        String sql = """
                SELECT resource_id, resource_name,
                       resource_category, tracking_mode,
                       total_quantity, available_quantity,
                       resource_location, resource_status, notes
                FROM resource_units
                ORDER BY resource_category, resource_name
                """;

        return executeQuery(sql);
    }

    // Retrieve all operation theatres
    public List<Map<String, Object>> getAllOperationTheatres()
            throws SQLException {

        String sql = """
                SELECT ot_id, ot_name, location, ot_type,
                       ot_status, notes
                FROM operation_theatres
                ORDER BY ot_name
                """;

        return executeQuery(sql);
    }

    // Retrieve current active allocations
    public List<Map<String, Object>> getActiveAllocations()
            throws SQLException {

        String sql = """
                SELECT
                    a.allocation_id,
                    a.patient_id,
                    p.full_name AS patient_name,
                    a.bed_id,
                    b.bed_number,
                    a.resource_id,
                    r.resource_name,
                    a.allocated_quantity,
                    a.allocated_by,
                    a.allocation_start,
                    a.allocation_status,
                    a.notes
                FROM resource_allocations a
                LEFT JOIN patients p
                    ON a.patient_id = p.patient_id
                LEFT JOIN beds b
                    ON a.bed_id = b.bed_id
                LEFT JOIN resource_units r
                    ON a.resource_id = r.resource_id
                WHERE a.allocation_status = 'ACTIVE'
                ORDER BY a.allocation_start DESC
                """;

        return executeQuery(sql);
    }

    // Shared SELECT helper
    private List<Map<String, Object>> executeQuery(String sql)
            throws SQLException {

        List<Map<String, Object>> records = new ArrayList<>();

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(sql);
             ResultSet resultSet = statement.executeQuery()) {

            int columnCount =
                    resultSet.getMetaData().getColumnCount();

            while (resultSet.next()) {

                Map<String, Object> record =
                        new LinkedHashMap<>();

                for (int i = 1; i <= columnCount; i++) {
                    String columnName =
                            resultSet.getMetaData()
                                     .getColumnLabel(i);

                    record.put(
                            columnName,
                            resultSet.getObject(i)
                    );
                }

                records.add(record);
            }
        }

        return records;
    }

    // Allocate an available bed to a patient.
    public int allocateBed(int patientId, int bedId,
                           int allocatedBy, String notes)
            throws SQLException {

        String lockSql = """
                SELECT bed_status
                FROM beds
                WHERE bed_id = ?
                FOR UPDATE
                """;

        String insertSql = """
                INSERT INTO resource_allocations
                    (patient_id, bed_id, resource_id,
                     allocated_quantity, allocated_by,
                     allocation_status, notes)
                VALUES (?, ?, NULL, 1, ?, 'ACTIVE', ?)
                """;

        String updateSql = """
                UPDATE beds
                SET bed_status = 'OCCUPIED'
                WHERE bed_id = ?
                  AND bed_status = 'AVAILABLE'
                """;

        try (Connection con = DBConnection.getConnection()) {
            con.setAutoCommit(false);

            try {
                String status;

                try (PreparedStatement ps =
                         con.prepareStatement(lockSql)) {
                    ps.setInt(1, bedId);

                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) {
                            throw new SQLException("Bed not found.");
                        }
                        status = rs.getString("bed_status");
                    }
                }

                if (!"AVAILABLE".equals(status)) {
                    throw new SQLException(
                        "Bed is not available."
                    );
                }

                try (PreparedStatement ps =
                         con.prepareStatement(insertSql)) {
                    ps.setInt(1, patientId);
                    ps.setInt(2, bedId);
                    ps.setInt(3, allocatedBy);
                    ps.setString(4, notes);
                    ps.executeUpdate();
                }

                try (PreparedStatement ps =
                         con.prepareStatement(updateSql)) {
                    ps.setInt(1, bedId);

                    if (ps.executeUpdate() != 1) {
                        throw new SQLException(
                            "Unable to update bed status."
                        );
                    }
                }

                con.commit();
                return bedId;

            } catch (SQLException | RuntimeException e) {
                con.rollback();
                throw e;
            } finally {
                con.setAutoCommit(true);
            }
        }
    }

    // Allocate equipment by quantity.
    public int allocateResource(int patientId, int resourceId,
                                int quantity, int allocatedBy,
                                String notes)
            throws SQLException {

        if (quantity <= 0) {
            throw new SQLException(
                "Quantity must be greater than zero."
            );
        }

        String updateSql = """
                UPDATE resource_units
                SET available_quantity = available_quantity - ?
                WHERE resource_id = ?
                  AND resource_status = 'ACTIVE'
                  AND available_quantity >= ?
                """;

        String insertSql = """
                INSERT INTO resource_allocations
                    (patient_id, bed_id, resource_id,
                     allocated_quantity, allocated_by,
                     allocation_status, notes)
                VALUES (?, NULL, ?, ?, ?, 'ACTIVE', ?)
                """;

        try (Connection con = DBConnection.getConnection()) {
            con.setAutoCommit(false);

            try {
                int changed;

                try (PreparedStatement ps =
                         con.prepareStatement(updateSql)) {
                    ps.setInt(1, quantity);
                    ps.setInt(2, resourceId);
                    ps.setInt(3, quantity);
                    changed = ps.executeUpdate();
                }

                if (changed != 1) {
                    throw new SQLException(
                        "Resource unavailable or insufficient quantity."
                    );
                }

                int allocationId;

                try (PreparedStatement ps =
                         con.prepareStatement(
                             insertSql,
                             java.sql.Statement.RETURN_GENERATED_KEYS
                         )) {
                    ps.setInt(1, patientId);
                    ps.setInt(2, resourceId);
                    ps.setInt(3, quantity);
                    ps.setInt(4, allocatedBy);
                    ps.setString(5, notes);
                    ps.executeUpdate();

                    try (ResultSet keys = ps.getGeneratedKeys()) {
                        if (!keys.next()) {
                            throw new SQLException(
                                "Allocation ID was not generated."
                            );
                        }
                        allocationId = keys.getInt(1);
                    }
                }

                con.commit();
                return allocationId;

            } catch (SQLException | RuntimeException e) {
                con.rollback();
                throw e;
            } finally {
                con.setAutoCommit(true);
            }
        }
    }

    // Release an active bed allocation.
    public void releaseBed(int allocationId)
            throws SQLException {

        String lockSql = """
                SELECT bed_id
                FROM resource_allocations
                WHERE allocation_id = ?
                  AND allocation_status = 'ACTIVE'
                  AND bed_id IS NOT NULL
                FOR UPDATE
                """;

        String releaseSql = """
                UPDATE resource_allocations
                SET allocation_status = 'RELEASED',
                    allocation_end = CURRENT_TIMESTAMP
                WHERE allocation_id = ?
                  AND allocation_status = 'ACTIVE'
                """;

        String bedSql = """
                UPDATE beds
                SET bed_status = 'AVAILABLE'
                WHERE bed_id = ?
                  AND bed_status = 'OCCUPIED'
                """;

        try (Connection con = DBConnection.getConnection()) {
            con.setAutoCommit(false);

            try {
                int bedId;

                try (PreparedStatement ps =
                         con.prepareStatement(lockSql)) {
                    ps.setInt(1, allocationId);

                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) {
                            throw new SQLException(
                                "Active bed allocation not found."
                            );
                        }
                        bedId = rs.getInt("bed_id");
                    }
                }

                try (PreparedStatement ps =
                         con.prepareStatement(releaseSql)) {
                    ps.setInt(1, allocationId);
                    if (ps.executeUpdate() != 1) {
                        throw new SQLException(
                            "Unable to release allocation."
                        );
                    }
                }

                try (PreparedStatement ps =
                         con.prepareStatement(bedSql)) {
                    ps.setInt(1, bedId);
                    if (ps.executeUpdate() != 1) {
                        throw new SQLException(
                            "Bed status was not updated."
                        );
                    }
                }

                con.commit();

            } catch (SQLException | RuntimeException e) {
                con.rollback();
                throw e;
            } finally {
                con.setAutoCommit(true);
            }
        }
    }

    // Release an active equipment allocation.
    public void releaseResource(int allocationId)
            throws SQLException {

        String lockSql = """
                SELECT resource_id, allocated_quantity
                FROM resource_allocations
                WHERE allocation_id = ?
                  AND allocation_status = 'ACTIVE'
                  AND resource_id IS NOT NULL
                FOR UPDATE
                """;

        String releaseSql = """
                UPDATE resource_allocations
                SET allocation_status = 'RELEASED',
                    allocation_end = CURRENT_TIMESTAMP
                WHERE allocation_id = ?
                  AND allocation_status = 'ACTIVE'
                """;

        String restoreSql = """
                UPDATE resource_units
                SET available_quantity =
                    available_quantity + ?
                WHERE resource_id = ?
                  AND available_quantity + ? <= total_quantity
                """;

        try (Connection con = DBConnection.getConnection()) {
            con.setAutoCommit(false);

            try {
                int resourceId;
                int quantity;

                try (PreparedStatement ps =
                         con.prepareStatement(lockSql)) {
                    ps.setInt(1, allocationId);

                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) {
                            throw new SQLException(
                                "Active equipment allocation not found."
                            );
                        }
                        resourceId = rs.getInt("resource_id");
                        quantity = rs.getInt("allocated_quantity");
                    }
                }

                try (PreparedStatement ps =
                         con.prepareStatement(releaseSql)) {
                    ps.setInt(1, allocationId);
                    if (ps.executeUpdate() != 1) {
                        throw new SQLException(
                            "Unable to release allocation."
                        );
                    }
                }

                try (PreparedStatement ps =
                         con.prepareStatement(restoreSql)) {
                    ps.setInt(1, quantity);
                    ps.setInt(2, resourceId);
                    ps.setInt(3, quantity);

                    if (ps.executeUpdate() != 1) {
                        throw new SQLException(
                            "Equipment quantity could not be restored."
                        );
                    }
                }

                con.commit();

            } catch (SQLException | RuntimeException e) {
                con.rollback();
                throw e;
            } finally {
                con.setAutoCommit(true);
            }
        }
    }

}
