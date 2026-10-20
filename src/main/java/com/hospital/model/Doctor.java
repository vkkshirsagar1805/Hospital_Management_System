
package com.hospital.model;

import java.sql.Timestamp;

public class Doctor {

    private int doctorId;
    private Integer userId;
    private int departmentId;
    private String fullName;
    private String specialization;
    private String qualification;
    private String phone;
    private String email;
    private String employmentStatus;
    private Timestamp createdAt;
    private String departmentName;
    
    // Default constructor
    public Doctor() {
    }

    // Parameterized constructor
    public Doctor(int doctorId, Integer userId, int departmentId,
                  String fullName, String specialization,
                  String qualification, String phone, String email,
                  String employmentStatus, Timestamp createdAt) {

        this.doctorId = doctorId;
        this.userId = userId;
        this.departmentId = departmentId;
        this.fullName = fullName;
        this.specialization = specialization;
        this.qualification = qualification;
        this.phone = phone;
        this.email = email;
        this.employmentStatus = employmentStatus;
        this.createdAt = createdAt;
    }

    public int getDoctorId() {
        return doctorId;
    }

    public void setDoctorId(int doctorId) {
        this.doctorId = doctorId;
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
    
    public String getDepartmentName() {
        return departmentName;
    }

    public void setDepartmentName(String departmentName) {
        this.departmentName = departmentName;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getSpecialization() {
        return specialization;
    }

    public void setSpecialization(String specialization) {
        this.specialization = specialization;
    }

    public String getQualification() {
        return qualification;
    }

    public void setQualification(String qualification) {
        this.qualification = qualification;
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
