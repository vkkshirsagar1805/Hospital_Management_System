
package com.hospital.servlet;

import java.io.IOException;
import java.sql.Date;
import java.sql.SQLException;
import java.util.List;

import com.hospital.dao.PatientDAO;
import com.hospital.model.Patient;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/patients")
public class PatientServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final PatientDAO patientDAO = new PatientDAO();

    // READ: Patient list, registration form and edit form
    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        // Only ADMIN can open registration and edit forms.
        if ("new".equals(action) || "edit".equals(action)) {
            if (!hasRole(request, "ADMIN")) {
                response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Only administrators can register or edit patient details."
                );
                return;
            }
        }

        try {
            if ("new".equals(action)) {
                request.getRequestDispatcher(
                    "/WEB-INF/views/patient-form.jsp"
                ).forward(request, response);
                return;
            }

            if ("edit".equals(action)) {
                int patientId = parseId(request.getParameter("id"));

                if (patientId <= 0) {
                    response.sendError(
                        HttpServletResponse.SC_BAD_REQUEST,
                        "Invalid patient ID."
                    );
                    return;
                }

                Patient patient = patientDAO.getPatientById(patientId);

                if (patient == null) {
                    response.sendError(
                        HttpServletResponse.SC_NOT_FOUND,
                        "Patient not found."
                    );
                    return;
                }

                request.setAttribute("patient", patient);

                request.getRequestDispatcher(
                    "/WEB-INF/views/patient-edit.jsp"
                ).forward(request, response);
                return;
            }

            List<Patient> patients = patientDAO.getAllPatients();
            request.setAttribute("patients", patients);

            request.getRequestDispatcher(
                "/WEB-INF/views/patients.jsp"
            ).forward(request, response);

        } catch (SQLException e) {
            log("Unable to retrieve patient records.", e);
            throw new ServletException(
                "Unable to load patient records.", e
            );
        }
    }

    // CREATE, UPDATE, DELETE and STATUS CHANGE
    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");

        // ADMIN and RECEPTIONIST can change patient status only.
        if ("status".equals(action)) {
            if (!hasAnyRole(request, "ADMIN", "RECEPTIONIST")) {
                response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "You cannot change patient status."
                );
                return;
            }

            try {
                changePatientStatus(request, response);
            } catch (SQLException e) {
                log("Unable to change patient status.", e);
                throw new ServletException(
                    "Unable to change patient status.", e
                );
            }
            return;
        }

        // All other POST operations are ADMIN-only.
        if (!hasRole(request, "ADMIN")) {
            response.sendError(
                HttpServletResponse.SC_FORBIDDEN,
                "Only administrators can perform this operation."
            );
            return;
        }

        try {
            if ("update".equals(action)) {
                updatePatient(request, response);
                return;
            }

            if ("delete".equals(action)) {
                deletePatient(request, response);
                return;
            }

            if (action == null || "create".equals(action)) {
                createPatient(request, response);
                return;
            }

            response.sendError(
                HttpServletResponse.SC_BAD_REQUEST,
                "Unknown patient operation."
            );

        } catch (SQLException e) {
            log("Database operation failed for a patient record.", e);

            String sqlState = e.getSQLState();

            if (sqlState != null && sqlState.startsWith("23")) {
                if ("delete".equals(action)) {
                    response.sendError(
                        HttpServletResponse.SC_CONFLICT,
                        "This patient cannot be deleted because related records exist. Deactivate the patient instead."
                    );
                } else {
                    response.sendError(
                        HttpServletResponse.SC_CONFLICT,
                        "The operation conflicts with a database constraint."
                    );
                }
            } else {
                throw new ServletException(
                    "Unable to process the patient record.", e
                );
            }
        }
    }
    
    //CREATE
    private void createPatient(HttpServletRequest request,
            		HttpServletResponse response)
            				throws SQLException, IOException {

    	Patient patient = readPatientFields(request);

    	if (patient == null) {
    		response.sendError(
    				HttpServletResponse.SC_BAD_REQUEST,
    				"Invalid patient details."
    				);
    		return;
    	}
    	
    	patient.setRecordStatus("ACTIVE");
    	
    	int patientId = patientDAO.addPatient(patient);
    	
    	if (patientId > 0) {
    		response.sendRedirect(
    				request.getContextPath()
    				+ "/appointments?action=new&patientId=" + patientId
    				+ "&registered=1"
    				);
    	} else {
    		response.sendError(
    				HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
    				"Patient registration failed."
    				);
    	}
    }
    
    // UPDATE PATIENT DETAILS: ADMIN only
    private void updatePatient(HttpServletRequest request,
                               HttpServletResponse response)
            throws SQLException, IOException {

        int patientId = parseId(request.getParameter("patientId"));

        if (patientId <= 0) {
            response.sendError(
                HttpServletResponse.SC_BAD_REQUEST,
                "Invalid patient ID."
            );
            return;
        }

        Patient patient = readPatientFields(request);

        if (patient == null) {
            response.sendError(
                HttpServletResponse.SC_BAD_REQUEST,
                "Invalid patient details."
            );
            return;
        }

        String status = request.getParameter("recordStatus");

        if (!"ACTIVE".equals(status) && !"INACTIVE".equals(status)) {
            response.sendError(
                HttpServletResponse.SC_BAD_REQUEST,
                "Invalid patient record status."
            );
            return;
        }

        patient.setPatientId(patientId);
        patient.setRecordStatus(status);

        boolean updated = patientDAO.updatePatient(patient);

        if (!updated && patientDAO.getPatientById(patientId) == null) {
            response.sendError(
                HttpServletResponse.SC_NOT_FOUND,
                "Patient not found."
            );
            return;
        }

        response.sendRedirect(
            request.getContextPath() + "/patients?updated=1"
        );
    }

    // DELETE: ADMIN only
    private void deletePatient(HttpServletRequest request,
                               HttpServletResponse response)
            throws SQLException, IOException {

        int patientId = parseId(request.getParameter("patientId"));

        if (patientId <= 0) {
            response.sendError(
                HttpServletResponse.SC_BAD_REQUEST,
                "Invalid patient ID."
            );
            return;
        }

        boolean deleted = patientDAO.deletePatient(patientId);

        if (!deleted) {
            response.sendError(
                HttpServletResponse.SC_NOT_FOUND,
                "Patient not found."
            );
            return;
        }

        response.sendRedirect(
            request.getContextPath() + "/patients?deleted=1"
        );
    }

    // CHANGE STATUS: ADMIN or RECEPTIONIST
    private void changePatientStatus(HttpServletRequest request,
                                     HttpServletResponse response)
            throws SQLException, IOException {

        int patientId = parseId(request.getParameter("patientId"));
        String status = request.getParameter("recordStatus");

        if (patientId <= 0
                || !("ACTIVE".equals(status)
                || "INACTIVE".equals(status))) {
            response.sendError(
                HttpServletResponse.SC_BAD_REQUEST,
                "Invalid patient ID or status."
            );
            return;
        }

        boolean updated =
            patientDAO.updatePatientStatus(patientId, status);

        // A false result can also mean the status was already unchanged.
        if (!updated && patientDAO.getPatientById(patientId) == null) {
            response.sendError(
                HttpServletResponse.SC_NOT_FOUND,
                "Patient not found."
            );
            return;
        }

        response.sendRedirect(
            request.getContextPath() + "/patients?statusUpdated=1"
        );
    }

    // READ AND VALIDATE PATIENT DETAILS
    private Patient readPatientFields(HttpServletRequest request) {

        String fullName = request.getParameter("fullName");
        String dobValue = request.getParameter("dateOfBirth");
        String gender = request.getParameter("gender");
        String phone = request.getParameter("phone");
        String email = request.getParameter("email");
        String address = request.getParameter("address");

        if (fullName == null || fullName.trim().isEmpty()
                || fullName.trim().length() > 120) {
            return null;
        }

        if (!("MALE".equals(gender)
                || "FEMALE".equals(gender)
                || "OTHER".equals(gender)
                || "UNSPECIFIED".equals(gender))) {
            return null;
        }

        if ((phone != null && phone.length() > 20)
                || (email != null && email.length() > 150)
                || (address != null && address.length() > 500)) {
            return null;
        }

        Date dateOfBirth = null;

        if (dobValue != null && !dobValue.isBlank()) {
            try {
                dateOfBirth = Date.valueOf(dobValue);
            } catch (IllegalArgumentException e) {
                return null;
            }
        }

        Patient patient = new Patient();
        patient.setFullName(fullName.trim());
        patient.setDateOfBirth(dateOfBirth);
        patient.setGender(gender);
        patient.setPhone(cleanOptional(phone));
        patient.setEmail(cleanOptional(email));
        patient.setAddress(cleanOptional(address));

        return patient;
    }

    private String cleanOptional(String value) {
        if (value == null || value.trim().isEmpty()) {
            return null;
        }
        return value.trim();
    }

    private int parseId(String value) {
        try {
            int id = Integer.parseInt(value);
            return id > 0 ? id : -1;
        } catch (NumberFormatException | NullPointerException e) {
            return -1;
        }
    }

    // ROLE CHECKS
    private boolean hasRole(HttpServletRequest request,
                            String requiredRole) {

        HttpSession session = request.getSession(false);

        return session != null
            && requiredRole.equals(session.getAttribute("role"));
    }

    private boolean hasAnyRole(HttpServletRequest request,
                               String... roles) {

        for (String role : roles) {
            if (hasRole(request, role)) {
                return true;
            }
        }

        return false;
    }
}
