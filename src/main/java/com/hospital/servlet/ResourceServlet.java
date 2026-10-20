package com.hospital.servlet;

import com.hospital.dao.PatientDAO;
import com.hospital.dao.ResourceDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.util.Locale;

@WebServlet("/resources")
public class ResourceServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final ResourceDAO resourceDAO = new ResourceDAO();
    private final PatientDAO patientDAO = new PatientDAO();

    private boolean isAllowedToView(String role) {
        return "ADMIN".equals(role)
                || "DOCTOR".equals(role)
                || "RECEPTIONIST".equals(role)
                || "STAFF".equals(role);
    }

    private boolean isAllowedToAllocate(String role) {
        return "ADMIN".equals(role)
                || "DOCTOR".equals(role)
                || "RECEPTIONIST".equals(role);
    }

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("role") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String role = String.valueOf(session.getAttribute("role"))
                .toUpperCase(Locale.ROOT);

        if (!isAllowedToView(role)) {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "You are not authorized to view hospital resources."
            );
            return;
        }

        try {
            request.setAttribute("beds", resourceDAO.getAllBeds());
            request.setAttribute("resources", resourceDAO.getAllResources());
            request.setAttribute(
                    "operationTheatres",
                    resourceDAO.getAllOperationTheatres()
            );
            request.setAttribute(
                    "activeAllocations",
                    resourceDAO.getActiveAllocations()
            );
            request.setAttribute(
                    "patients",
                    patientDAO.getAllPatients()
            );

            request.getRequestDispatcher(
                    "/WEB-INF/views/resources.jsp"
            ).forward(request, response);

        } catch (SQLException e) {
            throw new ServletException(
                    "Unable to load hospital resources.", e
            );
        }
    }

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("role") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String role = String.valueOf(session.getAttribute("role"))
                .toUpperCase(Locale.ROOT);

        if (!isAllowedToAllocate(role)) {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "You are not authorized to allocate hospital resources."
            );
            return;
        }

        Object sessionUserId = session.getAttribute("userId");

        if (!(sessionUserId instanceof Number)) {
            response.sendError(
                    HttpServletResponse.SC_UNAUTHORIZED,
                    "Your login session is invalid. Please log in again."
            );
            return;
        }

        int allocatedBy = ((Number) sessionUserId).intValue();

        if (allocatedBy <= 0) {
            response.sendError(
                    HttpServletResponse.SC_UNAUTHORIZED,
                    "Invalid user session. Please log in again."
            );
            return;
        }

        String action = request.getParameter("action");
        String message;

        try {
            if ("allocateBed".equals(action)) {

                int patientId = parsePositiveInt(
                        request.getParameter("patientId"), "patient"
                );

                int bedId = parsePositiveInt(
                        request.getParameter("bedId"), "bed"
                );

                String notes = request.getParameter("notes");
                notes = notes == null ? "" : notes.trim();

                if (notes.length() > 500) {
                    throw new IllegalArgumentException(
                            "Notes cannot exceed 500 characters."
                    );
                }

                resourceDAO.allocateBed(
                        patientId,
                        bedId,
                        allocatedBy,
                        notes.isEmpty() ? null : notes
                );

                message = "Bed allocated successfully.";

            } else if ("allocateResource".equals(action)) {

                int patientId = parsePositiveInt(
                        request.getParameter("patientId"), "patient"
                );

                int resourceId = parsePositiveInt(
                        request.getParameter("resourceId"), "equipment"
                );

                int quantity = parsePositiveInt(
                        request.getParameter("quantity"), "quantity"
                );

                String notes = request.getParameter("notes");
                notes = notes == null ? "" : notes.trim();

                if (notes.length() > 500) {
                    throw new IllegalArgumentException(
                            "Notes cannot exceed 500 characters."
                    );
                }

                resourceDAO.allocateResource(
                        patientId,
                        resourceId,
                        quantity,
                        allocatedBy,
                        notes.isEmpty() ? null : notes
                );

                message = "Medical equipment allocated successfully.";

            } else if ("releaseBed".equals(action)) {

                int allocationId = parsePositiveInt(
                    request.getParameter("allocationId"), "allocation"
                );

                resourceDAO.releaseBed(allocationId);
                message = "Bed released successfully and marked available.";

            } else if ("releaseResource".equals(action)) {

                int allocationId = parsePositiveInt(
                    request.getParameter("allocationId"), "allocation"
                );

                resourceDAO.releaseResource(allocationId);
                message = "Equipment released successfully and stock updated.";

            } else {
                response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Invalid resource action."
                );
                return;

            }

        } catch (IllegalArgumentException e) {
            message = e.getMessage();

        } catch (SQLException e) {
            getServletContext().log(
                    "Resource allocation failed.", e
            );

            String sqlMessage = e.getMessage();

            if (sqlMessage != null
                    && sqlMessage.contains("Bed is not available")) {
                message = "This bed is no longer available. Refresh and select another bed.";
            } else if (sqlMessage != null
                    && sqlMessage.contains("Bed not found")) {
                message = "The selected bed does not exist.";
            } else if (sqlMessage != null
                    && sqlMessage.contains("Resource unavailable")) {
                message = "The equipment is unavailable or the requested quantity exceeds stock.";
            } else if ("releaseBed".equals(action)) {
                message = "Unable to release the bed. Please refresh and try again.";
            } else if ("releaseResource".equals(action)) {
                message = "Unable to release the equipment. Please refresh and try again.";
            } else {
                message = "Allocation failed. Please check the selected records and try again.";
            }
        }

        // Use the session to carry feedback across the redirect.
        session.setAttribute("resourceMessage", message);

        response.sendRedirect(
                request.getContextPath() + "/resources"
        );
    }

    private int parsePositiveInt(String value, String fieldName) {
        if (value == null || value.trim().isEmpty()) {
            throw new IllegalArgumentException(
                    "Please select a valid " + fieldName + "."
            );
        }

        try {
            int number = Integer.parseInt(value.trim());

            if (number <= 0) {
                throw new IllegalArgumentException(
                        "Please select a valid " + fieldName + "."
                );
            }

            return number;

        } catch (NumberFormatException e) {
            throw new IllegalArgumentException(
                    "Invalid " + fieldName + " value."
            );
        }
    }
}
