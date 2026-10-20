package com.hospital.model;

import java.sql.Timestamp;

public class StaffAssignment {

    private int assignmentId;
    private int staffId;
    private int departmentId;
    private Integer assignedBy;

    private String assignmentTitle;
    private String dutyLocation;

    private Timestamp shiftStart;
    private Timestamp shiftEnd;

    private String assignmentStatus;
    private String notes;
    private Timestamp createdAt;

    // Default constructor
    public StaffAssignment() {
    }

    // Getters and setters
    public int getAssignmentId() {
        return assignmentId;
    }

    public void setAssignmentId(int assignmentId) {
        this.assignmentId = assignmentId;
    }

    public int getStaffId() {
        return staffId;
    }

    public void setStaffId(int staffId) {
        this.staffId = staffId;
    }

    public int getDepartmentId() {
        return departmentId;
    }

    public void setDepartmentId(int departmentId) {
        this.departmentId = departmentId;
    }

    public Integer getAssignedBy() {
        return assignedBy;
    }

    public void setAssignedBy(Integer assignedBy) {
        this.assignedBy = assignedBy;
    }

    public String getAssignmentTitle() {
        return assignmentTitle;
    }

    public void setAssignmentTitle(String assignmentTitle) {
        this.assignmentTitle = assignmentTitle;
    }

    public String getDutyLocation() {
        return dutyLocation;
    }

    public void setDutyLocation(String dutyLocation) {
        this.dutyLocation = dutyLocation;
    }

    public Timestamp getShiftStart() {
        return shiftStart;
    }

    public void setShiftStart(Timestamp shiftStart) {
        this.shiftStart = shiftStart;
    }

    public Timestamp getShiftEnd() {
        return shiftEnd;
    }

    public void setShiftEnd(Timestamp shiftEnd) {
        this.shiftEnd = shiftEnd;
    }

    public String getAssignmentStatus() {
        return assignmentStatus;
    }

    public void setAssignmentStatus(String assignmentStatus) {
        this.assignmentStatus = assignmentStatus;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
}
