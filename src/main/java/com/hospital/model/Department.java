package com.hospital.model;

import java.sql.Timestamp;

public class Department {

    private int departmentId;
    private String departmentName;
    private String description;
    private String location;
    private String status;
    private Timestamp createdAt;

    // Default constructor
    public Department() {
    }

    // Parameterized constructor
    public Department(int departmentId, String departmentName,
                      String description, String location,
                      String status, Timestamp createdAt) {
        this.departmentId = departmentId;
        this.departmentName = departmentName;
        this.description = description;
        this.location = location;
        this.status = status;
        this.createdAt = createdAt;
    }

    public int getDepartmentId() {
        return departmentId;
    }

    public void setDepartmentId(int departmentId) {
        this.departmentId = departmentId;
    }

    public String getDepartmentName() {
        return departmentName;
    }

    public void setDepartmentName(String departmentName) {
        this.departmentName = departmentName;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getLocation() {
        return location;
    }

    public void setLocation(String location) {
        this.location = location;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
}
