
package com.hospital.servlet;

import com.hospital.dao.AmbulanceDAO;
import com.hospital.model.Ambulance;

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

@WebServlet("/ambulances")
public class AmbulanceServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final AmbulanceDAO ambulanceDAO = new AmbulanceDAO();

    private static final List<String> ALLOWED_ROLES =
            Arrays.asList("ADMIN", "DOCTOR", "STAFF", "RECEPTIONIST");

    private static final List<String> MANAGER_ROLES =
            Arrays.asList("ADMIN", "RECEPTIONIST");

    private static final List<String> AMBULANCE_TYPES =
            Arrays.asList("BASIC", "ADVANCED_LIFE_SUPPORT",
                    "PATIENT_TRANSPORT", "OTHER");

    private static final List<String> AMBULANCE_STATUSES =
            Arrays.asList("AVAILABLE", "ASSIGNED", "ON_TRIP",
                    "MAINTENANCE", "OUT_OF_SERVICE");

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        String role = getRole(request.getSession(false));

        if (role == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        if (!ALLOWED_ROLES.contains(role)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "You are not authorized to view ambulances.");
            return;
        }

        try {
            request.setAttribute("ambulances",
                    ambulanceDAO.getAllAmbulances());

            request.setAttribute("canManage",
                    MANAGER_ROLES.contains(role));

            String editId = request.getParameter("editId");

            if (editId != null && !editId.trim().isEmpty()) {
                int id = Integer.parseInt(editId);

                if (id <= 0) {
                    throw new IllegalArgumentException();
                }

                Ambulance ambulance = ambulanceDAO.getAmbulanceById(id);

                if (ambulance == null) {
                    request.getSession().setAttribute(
                            "ambulanceMessage", "Ambulance not found.");
                    response.sendRedirect(
                            request.getContextPath() + "/ambulances");
                    return;
                }

                if (MANAGER_ROLES.contains(role)) {
                    request.setAttribute("editAmbulance", ambulance);
                }
            }

            request.getRequestDispatcher(
                    "/WEB-INF/views/ambulances.jsp")
                    .forward(request, response);

        } catch (IllegalArgumentException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST,
                    "Invalid ambulance ID.");
        } catch (SQLException e) {
            throw new ServletException(
                    "Unable to load ambulance records.", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        String role = getRole(request.getSession(false));

        if (role == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        if (!MANAGER_ROLES.contains(role)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "You are not authorized to manage ambulances.");
            return;
        }

        request.setCharacterEncoding("UTF-8");

        String action = trim(request.getParameter("action"));
        HttpSession session = request.getSession();

        try {
            if ("add".equals(action)) {
                Ambulance ambulance = readAmbulance(request);
                ambulanceDAO.addAmbulance(ambulance);
                session.setAttribute("ambulanceMessage",
                        "Ambulance added successfully.");

            } else if ("update".equals(action)) {
                int id = parseId(request.getParameter("ambulanceId"));
                Ambulance ambulance = readAmbulance(request);
                ambulance.setAmbulanceId(id);

                if (!ambulanceDAO.updateAmbulance(ambulance)) {
                    throw new IllegalArgumentException(
                            "Ambulance not found.");
                }

                session.setAttribute("ambulanceMessage",
                        "Ambulance details updated successfully.");

            } else if ("updateStatus".equals(action)) {
                int id = parseId(request.getParameter("ambulanceId"));
                String status = trim(request.getParameter("ambulanceStatus"));

                if (!AMBULANCE_STATUSES.contains(status)) {
                    throw new IllegalArgumentException(
                            "Please select a valid status.");
                }

                if (!ambulanceDAO.updateAmbulanceStatus(id, status)) {
                    throw new IllegalArgumentException(
                            "Ambulance not found.");
                }

                session.setAttribute("ambulanceMessage",
                        "Ambulance status updated successfully.");

            } else {
                throw new IllegalArgumentException("Invalid action.");
            }

        } catch (IllegalArgumentException e) {
            session.setAttribute("ambulanceMessage", e.getMessage());

        } catch (SQLException e) {
            if ("23000".equals(e.getSQLState())) {
                session.setAttribute("ambulanceMessage",
                        "That vehicle number already exists. "
                        + "Please use a unique vehicle number.");
            } else {
                throw new ServletException(
                        "Unable to save ambulance details.", e);
            }
        }

        response.sendRedirect(request.getContextPath() + "/ambulances");
    }

    private Ambulance readAmbulance(HttpServletRequest request) {
        Ambulance ambulance = new Ambulance();

        String vehicleNumber =
                trim(request.getParameter("vehicleNumber"));
        String type = trim(request.getParameter("ambulanceType"));
        String driverName = trim(request.getParameter("driverName"));
        String driverPhone = trim(request.getParameter("driverPhone"));
        String location = trim(request.getParameter("currentLocation"));
        String notes = trim(request.getParameter("notes"));

        if (vehicleNumber.isEmpty() || vehicleNumber.length() > 30) {
            throw new IllegalArgumentException(
                    "Vehicle number is required (maximum 30 characters).");
        }

        if (!AMBULANCE_TYPES.contains(type)) {
            throw new IllegalArgumentException(
                    "Please select a valid ambulance type.");
        }

        if (driverName.length() > 150) {
            throw new IllegalArgumentException(
                    "Driver name must not exceed 150 characters.");
        }

        if (driverPhone.length() > 25
                || (!driverPhone.isEmpty()
                && !driverPhone.matches("[0-9+() .-]{5,25}"))) {
            throw new IllegalArgumentException(
                    "Enter a valid driver phone number.");
        }

        if (location.length() > 255) {
            throw new IllegalArgumentException(
                    "Current location must not exceed 255 characters.");
        }

        if (notes.length() > 500) {
            throw new IllegalArgumentException(
                    "Notes must not exceed 500 characters.");
        }

        ambulance.setVehicleNumber(vehicleNumber);
        ambulance.setAmbulanceType(type);
        ambulance.setDriverName(emptyToNull(driverName));
        ambulance.setDriverPhone(emptyToNull(driverPhone));
        ambulance.setCurrentLocation(emptyToNull(location));
        ambulance.setNotes(emptyToNull(notes));

        return ambulance;
    }

    private int parseId(String value) {
        try {
            int id = Integer.parseInt(value);

            if (id <= 0) {
                throw new IllegalArgumentException(
                        "Invalid ambulance ID.");
            }

            return id;

        } catch (NumberFormatException e) {
            throw new IllegalArgumentException("Invalid ambulance ID.");
        }
    }

    private String getRole(HttpSession session) {
        if (session == null || session.getAttribute("userId") == null) {
            return null;
        }

        Object value = session.getAttribute("role");

        return value == null
                ? null
                : value.toString().trim().toUpperCase();
    }

    private String trim(String value) {
        return value == null ? "" : value.trim();
    }

    private String emptyToNull(String value) {
        return value == null || value.isEmpty() ? null : value;
    }
}
