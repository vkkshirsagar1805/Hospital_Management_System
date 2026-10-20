
package com.hospital.servlet;

import com.hospital.dao.DoctorDAO;
import com.hospital.dao.WardRoundDAO;
import com.hospital.model.Doctor;
import com.hospital.model.WardRound;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Date;
import java.sql.SQLException;
import java.sql.Time;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeParseException;
import java.util.List;

@WebServlet("/ward-rounds")
public class WardRoundServlet extends HttpServlet {

    private final WardRoundDAO wardRoundDAO = new WardRoundDAO();
    private final DoctorDAO doctorDAO = new DoctorDAO();

    private boolean canManage(String role) {
        return "ADMIN".equals(role)
                || "DOCTOR".equals(role)
                || "RECEPTIONIST".equals(role);
    }

    private String getRole(HttpSession session) {
        Object role = session.getAttribute("role");
        return role == null ? "" : role.toString().toUpperCase();
    }

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(
                request.getContextPath() + "/login"
            );
            return;
        }

        String role = getRole(session);

        if (!canManage(role) && !"STAFF".equals(role)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        try {
            List<WardRound> rounds =
                    wardRoundDAO.getAllWardRounds();

            List<Doctor> doctors = doctorDAO.getAllDoctors();

            request.setAttribute("rounds", rounds);
            request.setAttribute("doctors", doctors);
            request.setAttribute("canManage", canManage(role));

            request.getRequestDispatcher(
                "/WEB-INF/views/ward-rounds.jsp"
            ).forward(request, response);

        } catch (SQLException e) {
            throw new ServletException(
                "Unable to load ward rounds.", e
            );
        }
    }

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(
                request.getContextPath() + "/login"
            );
            return;
        }

        String role = getRole(session);

        if (!canManage(role)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String action = request.getParameter("action");
        String message;

        try {
            if ("add".equals(action)) {
                addWardRound(request);
                message = "Ward round scheduled successfully.";

            } else if ("updateStatus".equals(action)) {
                updateWardRoundStatus(request);
                message = "Ward round status updated successfully.";

            } else {
                throw new IllegalArgumentException(
                    "Invalid ward round action."
                );
            }

        } catch (IllegalArgumentException e) {
            message = e.getMessage();

        } catch (SQLException e) {
            throw new ServletException(
                "Unable to save ward round.", e
            );
        }

        request.getSession().setAttribute(
            "wardRoundMessage", message
        );

        response.sendRedirect(
            request.getContextPath() + "/ward-rounds"
        );
    }

    private void addWardRound(HttpServletRequest request)
            throws SQLException {

        int doctorId = parsePositiveInt(
            request.getParameter("doctorId"), "doctor"
        );

        String dateText = request.getParameter("roundDate");
        String startText = request.getParameter("startTime");
        String endText = request.getParameter("endTime");
        String wardName = trim(request.getParameter("wardName"));
        String notes = trim(request.getParameter("notes"));

        if (dateText == null || dateText.isBlank()
                || startText == null || startText.isBlank()
                || endText == null || endText.isBlank()) {
            throw new IllegalArgumentException(
                "Date, start time, and end time are required."
            );
        }

        if (wardName.isEmpty() || wardName.length() > 100) {
            throw new IllegalArgumentException(
                "Ward name is required and must not exceed 100 characters."
            );
        }

        if (notes.length() > 5000) {
            throw new IllegalArgumentException(
                "Notes must not exceed 5000 characters."
            );
        }

        try {
            LocalDate date = LocalDate.parse(dateText);
            LocalTime start = LocalTime.parse(startText);
            LocalTime end = LocalTime.parse(endText);

            if (date.isBefore(LocalDate.now())) {
                throw new IllegalArgumentException(
                    "Choose today or a future date."
                );
            }

            if (!end.isAfter(start)) {
                throw new IllegalArgumentException(
                    "End time must be later than start time."
                );
            }

            Doctor doctor = new DoctorDAO().getDoctorById(doctorId);

            if (doctor == null) {
                throw new IllegalArgumentException(
                    "Selected doctor was not found."
                );
            }

            WardRound round = new WardRound();
            round.setDoctorId(doctorId);
            round.setRoundDate(Date.valueOf(date));
            round.setStartTime(Time.valueOf(start));
            round.setEndTime(Time.valueOf(end));
            round.setWardName(wardName);
            round.setNotes(notes.isEmpty() ? null : notes);
            round.setRoundStatus("PLANNED");

            if (!wardRoundDAO.addWardRound(round)) {
                throw new IllegalArgumentException(
                    "Ward round could not be scheduled."
                );
            }

        } catch (DateTimeParseException e) {
            throw new IllegalArgumentException(
                "Enter a valid date and time."
            );
        }
    }

    private void updateWardRoundStatus(HttpServletRequest request)
            throws SQLException {

        int roundId = parsePositiveInt(
            request.getParameter("wardRoundId"), "ward round"
        );

        String status = trim(request.getParameter("roundStatus"));

        if (!status.matches(
                "PLANNED|IN_PROGRESS|COMPLETED|CANCELLED")) {
            throw new IllegalArgumentException(
                "Invalid ward round status."
            );
        }

        if (wardRoundDAO.getWardRoundById(roundId) == null) {
            throw new IllegalArgumentException(
                "Ward round was not found."
            );
        }

        if (!wardRoundDAO.updateStatus(roundId, status)) {
            throw new IllegalArgumentException(
                "Ward round status could not be updated."
            );
        }
    }

    private int parsePositiveInt(String value, String field) {
        try {
            int number = Integer.parseInt(value);

            if (number <= 0) {
                throw new NumberFormatException();
            }

            return number;

        } catch (NumberFormatException e) {
            throw new IllegalArgumentException(
                "Select a valid " + field + "."
            );
        }
    }

    private String trim(String value) {
        return value == null ? "" : value.trim();
    }
}
