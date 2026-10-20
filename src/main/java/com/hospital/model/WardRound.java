
package com.hospital.model;

import java.sql.Date;
import java.sql.Time;
import java.sql.Timestamp;

public class WardRound {

    private int wardRoundId;
    private int doctorId;
    private Date roundDate;
    private Time startTime;
    private Time endTime;
    private String wardName;
    private String notes;
    private String roundStatus;
    private Timestamp createdAt;

    public WardRound() {
    }

    public int getWardRoundId() {
        return wardRoundId;
    }

    public void setWardRoundId(int wardRoundId) {
        this.wardRoundId = wardRoundId;
    }

    public int getDoctorId() {
        return doctorId;
    }

    public void setDoctorId(int doctorId) {
        this.doctorId = doctorId;
    }

    public Date getRoundDate() {
        return roundDate;
    }

    public void setRoundDate(Date roundDate) {
        this.roundDate = roundDate;
    }

    public Time getStartTime() {
        return startTime;
    }

    public void setStartTime(Time startTime) {
        this.startTime = startTime;
    }

    public Time getEndTime() {
        return endTime;
    }

    public void setEndTime(Time endTime) {
        this.endTime = endTime;
    }

    public String getWardName() {
        return wardName;
    }

    public void setWardName(String wardName) {
        this.wardName = wardName;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }

    public String getRoundStatus() {
        return roundStatus;
    }

    public void setRoundStatus(String roundStatus) {
        this.roundStatus = roundStatus;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
}
