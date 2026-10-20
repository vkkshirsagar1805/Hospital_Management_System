
package com.hospital.model;

import java.sql.Timestamp;

public class Staff {

    private int staffId;
    private Integer userId;
    private int departmentId;
    private Integer supervisorStaffId;
    private Integer supervisorDoctorId;
    private String fullName;
    private String designation;
    private String staffType;
    private String phone;
    private String email;
    private String employmentStatus;
    private Timestamp createdAt;

    public Staff() {
    }

    public int getStaffId() {
        return staffId;
    }

    public void setStaffId(int staffId) {
        this.staffId = staffId;
    }

    public Integer getUserId() {
        return userId;
    }

    public void setUserId(Integer userId) {
        this.userId = userId;
    }

    public int getDepartmentId() {
        return departmentId;
    }

    public void setDepartmentId(int departmentId) {
        this.departmentId = departmentId;
    }

    public Integer getSupervisorStaffId() {
        return supervisorStaffId;
    }

    public void setSupervisorStaffId(Integer supervisorStaffId) {
        this.supervisorStaffId = supervisorStaffId;
    }

    public Integer getSupervisorDoctorId() {
        return supervisorDoctorId;
    }

    public void setSupervisorDoctorId(Integer supervisorDoctorId) {
        this.supervisorDoctorId = supervisorDoctorId;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getDesignation() {
        return designation;
    }

    public void setDesignation(String designation) {
        this.designation = designation;
    }

    public String getStaffType() {
        return staffType;
    }

    public void setStaffType(String staffType) {
        this.staffType = staffType;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getEmploymentStatus() {
        return employmentStatus;
    }

    public void setEmploymentStatus(String employmentStatus) {
        this.employmentStatus = employmentStatus;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
}
