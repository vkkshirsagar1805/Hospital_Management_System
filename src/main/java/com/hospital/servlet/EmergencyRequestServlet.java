
package com.hospital.servlet;

import com.hospital.dao.EmergencyRequestDAO;
import com.hospital.model.EmergencyRequest;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.util.Arrays;
import java.util.List;
import java.util.Set;

@WebServlet("/emergency-requests")
public class EmergencyRequestServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final EmergencyRequestDAO emergencyRequestDAO =
            new EmergencyRequestDAO();

    private static final Set<String> ALLOWED_TYPES = Set.of(
            "MEDICAL", "ACCIDENT", "CARDIAC",
            "RESPIRATORY", "TRAUMA", "OTHER");

    private static final Set<String> ALLOWED_SEVERITIES = Set.of(
            "LOW", "MEDIUM", "HIGH", "CRITICAL");

    private static final Set<String> ALLOWED_STATUSES = Set.of(
            "REPORTED", "ACKNOWLEDGED", "DISPATCHED",
            "IN_PROGRESS", "RESOLVED", "CANCELLED");

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        if (!isLoggedIn(request)) {
            response.sendRedirect(
                    request.getContextPath() + "/login");
            return;
        }

        try {
            request.setAttribute("emergencyRequests",
                    emergencyRequestDAO.getAllEmergencyRequests());

            request.setAttribute("patients",
                    emergencyRequestDAO.getAllPatients());

            request.setAttribute("availableAmbulances",
                    emergencyRequestDAO.getAvailableAmbulances());

            request.getRequestDispatcher(
                    "/WEB-INF/views/emergency-requests.jsp")
                    .forward(request, response);

        } catch (SQLException e) {
            throw new ServletException(
                    "Unable to load emergency requests.", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        if (!isLoggedIn(request)) {
            response.sendRedirect(
                    request.getContextPath() + "/login");
            return;
        }

        String action = trim(request.getParameter("action"));
        String role = getRole(request);

        try {
            if ("create".equals(action)) {

                if (!canManage(role)) {
                    response.sendError(
                            HttpServletResponse.SC_FORBIDDEN,
                            "You are not allowed to register requests.");
                    return;
                }

                createRequest(request);

            } else if ("updateStatus".equals(action)) {

                if (!canManage(role)) {
                    response.sendError(
                            HttpServletResponse.SC_FORBIDDEN,
                            "You are not allowed to update request status.");
                    return;
                }

                updateStatus(request);

            } else if ("assignAmbulance".equals(action)) {

                if (!canManage(role)) {
                    response.sendError(
                            HttpServletResponse.SC_FORBIDDEN,
                            "You are not allowed to assign ambulances.");
                    return;
                }

                assignAmbulance(request);

            } else {
                response.sendError(
                        HttpServletResponse.SC_BAD_REQUEST,
                        "Invalid emergency request action.");
                return;
            }

            response.sendRedirect(
                    request.getContextPath()
                    + "/emergency-requests?success=1");

        } catch (IllegalArgumentException e) {
            response.sendRedirect(
                    request.getContextPath()
                    + "/emergency-requests?error=invalid");

        } catch (SQLException e) {
            log("Emergency request database operation failed.", e);

            response.sendRedirect(
                    request.getContextPath()
                    + "/emergency-requests?error=database");
        }
    }

    private void createRequest(HttpServletRequest request)
            throws SQLException {

        String emergencyType =
                trim(request.getParameter("emergencyType"));

        String severity =
                trim(request.getParameter("severity"));

        String location =
                trim(request.getParameter("requestLocation"));

        String description =
                trim(request.getParameter("requestDescription"));

        if (!ALLOWED_TYPES.contains(emergencyType)
                || !ALLOWED_SEVERITIES.contains(severity)
                || location.isEmpty()
                || location.length() > 300
                || description.length() > 5000) {
            throw new IllegalArgumentException(
                    "Invalid emergency request details.");
        }

        EmergencyRequest emergency = new EmergencyRequest();

        emergency.setEmergencyType(emergencyType);
        emergency.setSeverity(severity);
        emergency.setRequestLocation(location);
        emergency.setRequestDescription(
                description.isEmpty() ? null : description);

        Integer patientId = parseOptionalId(
                request.getParameter("patientId"));

        emergency.setPatientId(patientId);

        HttpSession session = request.getSession(false);
        Object userId = session.getAttribute("userId");

        if (userId instanceof Number) {
            emergency.setReportedBy(((Number) userId).intValue());
        } else if (userId instanceof String) {
            try {
                emergency.setReportedBy(
                        Integer.parseInt((String) userId));
            } catch (NumberFormatException e) {
                throw new IllegalArgumentException(
                        "Invalid logged-in user.");
            }
        } else {
            throw new IllegalArgumentException(
                    "Logged-in user ID is missing.");
        }

        emergencyRequestDAO.createEmergencyRequest(emergency);
    }

    private void updateStatus(HttpServletRequest request)
            throws SQLException {

        int requestId = parseRequiredId(
                request.getParameter("requestId"));

        String status = trim(request.getParameter("requestStatus"));
        String notes = trim(request.getParameter("resolutionNotes"));

        if (!ALLOWED_STATUSES.contains(status)
                || notes.length() > 500) {
            throw new IllegalArgumentException(
                    "Invalid request status or notes.");
        }

        emergencyRequestDAO.updateEmergencyStatus(
                requestId, status, notes.isEmpty() ? null : notes);
    }

    private void assignAmbulance(HttpServletRequest request)
            throws SQLException {

        int requestId = parseRequiredId(
                request.getParameter("requestId"));

        int ambulanceId = parseRequiredId(
                request.getParameter("ambulanceId"));

        emergencyRequestDAO.assignAmbulance(
                requestId, ambulanceId);
    }

    private boolean isLoggedIn(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return session != null && session.getAttribute("userId") != null;
    }

    private String getRole(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        Object role = session == null
                ? null : session.getAttribute("role");

        return role == null
                ? "" : role.toString().trim().toUpperCase();
    }

    private boolean canManage(String role) {
        return Arrays.asList(
                "ADMIN", "DOCTOR", "RECEPTIONIST", "STAFF"
        ).contains(role);
    }

    private int parseRequiredId(String value) {
        try {
            int id = Integer.parseInt(trim(value));

            if (id <= 0) {
                throw new IllegalArgumentException("Invalid ID.");
            }

            return id;

        } catch (NumberFormatException e) {
            throw new IllegalArgumentException("Invalid ID.");
        }
    }

    private Integer parseOptionalId(String value) {
        if (value == null || value.trim().isEmpty()) {
            return null;
        }

        return parseRequiredId(value);
    }

    private String trim(String value) {
        return value == null ? "" : value.trim();
    }
}
