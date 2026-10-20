
package com.hospital.servlet;

import com.hospital.dao.DoctorDAO;
import com.hospital.model.Department;
import com.hospital.model.Doctor;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/doctors")
public class DoctorServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private DoctorDAO doctorDAO;

    @Override
    public void init() {
        doctorDAO = new DoctorDAO();
    }

    private boolean hasRole(HttpServletRequest request, String role) {
        HttpSession session = request.getSession(false);
        return session != null && role.equals(session.getAttribute("role"));
    }

    private boolean isAdminOrReceptionist(HttpServletRequest request) {
        return hasRole(request, "ADMIN")
                || hasRole(request, "RECEPTIONIST");
    }

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        // Only administrators can open registration and editing forms.
        if ("new".equals(action) || "edit".equals(action)) {
            if (!hasRole(request, "ADMIN")) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN,
                        "Only administrators can register or edit doctors.");
                return;
            }
        }

        try {
            if ("new".equals(action)) {
                loadDepartments(request);
                request.getRequestDispatcher(
                        "/WEB-INF/views/doctor-form.jsp"
                ).forward(request, response);
                return;
            }

            if ("edit".equals(action)) {
                int doctorId = parseId(request.getParameter("id"));
                Doctor doctor = doctorDAO.getDoctorById(doctorId);

                if (doctor == null) {
                    response.sendError(HttpServletResponse.SC_NOT_FOUND,
                            "Doctor not found.");
                    return;
                }

                request.setAttribute("doctor", doctor);
                loadDepartments(request);
                request.getRequestDispatcher(
                        "/WEB-INF/views/doctor-edit.jsp"
                ).forward(request, response);
                return;
            }

            request.setAttribute("doctors", doctorDAO.getAllDoctors());

            request.getRequestDispatcher(
                    "/WEB-INF/views/doctors.jsp"
            ).forward(request, response);

        } catch (IllegalArgumentException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST,
                    "Invalid doctor ID.");
        } catch (SQLException e) {
            throw new ServletException(
                    "Unable to load doctor information.", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");

        // ADMIN and RECEPTIONIST may change a doctor's status only.
        if ("status".equals(action)) {
            if (!isAdminOrReceptionist(request)) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN,
                        "You cannot change doctor status.");
                return;
            }

            try {
                changeDoctorStatus(request, response);
            } catch (IllegalArgumentException e) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST,
                        "Invalid doctor ID or employment status.");
            } catch (SQLException e) {
                throw new ServletException(
                        "Unable to change doctor status.", e);
            }
            return;
        }

        // All other POST operations require ADMIN.
        if (!hasRole(request, "ADMIN")) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "Only administrators can add, edit or delete doctors.");
            return;
        }

        try {
            if ("delete".equals(action)) {
                deleteDoctor(request, response);
                return;
            }

            boolean editing = "update".equals(action);

            if (!editing && !"create".equals(action)) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST,
                        "Unknown doctor operation.");
                return;
            }

            int doctorId = editing
                    ? parseId(request.getParameter("doctorId")) : 0;

            String fullName = clean(request.getParameter("fullName"));
            String specialization =
                    clean(request.getParameter("specialization"));
            String qualification =
                    clean(request.getParameter("qualification"));
            String phone = clean(request.getParameter("phone"));
            String email = clean(request.getParameter("email"));

            int departmentId = parseId(
                    request.getParameter("departmentId"));

            String employmentStatus = editing
                    ? request.getParameter("employmentStatus")
                    : "ACTIVE";

            if (fullName == null || fullName.length() > 120
                    || specialization == null
                    || specialization.length() > 120
                    || exceeds(qualification, 200)
                    || exceeds(phone, 20)
                    || exceeds(email, 150)
                    || !validEmail(email)
                    || !validStatus(employmentStatus)) {

                response.sendError(HttpServletResponse.SC_BAD_REQUEST,
                        "Please check all doctor details.");
                return;
            }

            boolean validDepartment = doctorDAO.getActiveDepartments()
                    .stream()
                    .anyMatch(d -> d.getDepartmentId() == departmentId);

            if (!validDepartment) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST,
                        "Please select an active department.");
                return;
            }

            Doctor doctor = new Doctor();
            doctor.setDoctorId(doctorId);
            doctor.setDepartmentId(departmentId);
            doctor.setFullName(fullName);
            doctor.setSpecialization(specialization);
            doctor.setQualification(qualification);
            doctor.setPhone(phone);
            doctor.setEmail(email);
            doctor.setEmploymentStatus(employmentStatus);

            boolean saved;

            if (editing) {
                if (doctorDAO.getDoctorById(doctorId) == null) {
                    response.sendError(HttpServletResponse.SC_NOT_FOUND,
                            "Doctor not found.");
                    return;
                }
                saved = doctorDAO.updateDoctor(doctor);
            } else {
                saved = doctorDAO.addDoctor(doctor);
            }

            if (saved) {
                String result = editing ? "updated" : "registered";
                response.sendRedirect(request.getContextPath()
                        + "/doctors?" + result + "=1");
            } else {
                response.sendError(
                        HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                        "The doctor record could not be saved.");
            }

        } catch (IllegalArgumentException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST,
                    "Invalid doctor ID or department ID.");
        } catch (SQLException e) {
            // MySQL constraint violations, including foreign-key conflicts.
            if (e.getSQLState() != null
                    && e.getSQLState().startsWith("23")) {
                response.sendError(HttpServletResponse.SC_CONFLICT,
                        "The operation conflicts with existing hospital records.");
            } else {
                throw new ServletException(
                        "Unable to save doctor information.", e);
            }
        }
    }

    private void changeDoctorStatus(HttpServletRequest request,
                                    HttpServletResponse response)
            throws SQLException, IOException {

        int doctorId = parseId(request.getParameter("doctorId"));
        String status = request.getParameter("employmentStatus");

        // Receptionists may only activate/deactivate, not set ON_LEAVE.
        if (!"ACTIVE".equals(status) && !"INACTIVE".equals(status)) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST,
                    "Status must be ACTIVE or INACTIVE.");
            return;
        }

        if (doctorDAO.getDoctorById(doctorId) == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND,
                    "Doctor not found.");
            return;
        }

        if (doctorDAO.updateDoctorStatus(doctorId, status)) {
            response.sendRedirect(request.getContextPath()
                    + "/doctors?statusUpdated=1");
        } else {
            response.sendError(HttpServletResponse.SC_CONFLICT,
                    "Doctor status could not be updated.");
        }
    }

    private void deleteDoctor(HttpServletRequest request,
                              HttpServletResponse response)
            throws SQLException, IOException {

        int doctorId = parseId(request.getParameter("doctorId"));

        if (doctorDAO.getDoctorById(doctorId) == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND,
                    "Doctor not found.");
            return;
        }

        if (doctorDAO.deleteDoctor(doctorId)) {
            response.sendRedirect(
                    request.getContextPath() + "/doctors?deleted=1");
        } else {
            response.sendError(HttpServletResponse.SC_CONFLICT,
                    "Doctor could not be deleted.");
        }
    }

    private void loadDepartments(HttpServletRequest request)
            throws SQLException {
        List<Department> departments = doctorDAO.getActiveDepartments();
        request.setAttribute("departments", departments);
    }

    private int parseId(String value) {
        try {
            int id = Integer.parseInt(value);
            if (id <= 0) {
                throw new NumberFormatException();
            }
            return id;
        } catch (NumberFormatException | NullPointerException e) {
            throw new IllegalArgumentException("Invalid ID.", e);
        }
    }

    private String clean(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        return value.trim();
    }

    private boolean exceeds(String value, int max) {
        return value != null && value.length() > max;
    }

    private boolean validEmail(String email) {
        return email == null
                || email.matches("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$");
    }

    private boolean validStatus(String status) {
        return "ACTIVE".equals(status)
                || "ON_LEAVE".equals(status)
                || "INACTIVE".equals(status);
    }
}
