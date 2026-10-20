
package com.hospital.servlet;

import com.hospital.dao.StaffDAO;
import com.hospital.model.Staff;
import com.hospital.model.Department;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/staff")
public class StaffServlet extends HttpServlet {

    private StaffDAO staffDAO;

    @Override
    public void init() {
        staffDAO = new StaffDAO();
    }

    // Check whether the logged-in user has a specific role.
    private boolean hasRole(HttpServletRequest request, String role) {
        HttpSession session = request.getSession(false);

        return session != null
                && role.equals(session.getAttribute("role"));
    }

    private boolean isAdminOrReceptionist(
            HttpServletRequest request) {

        return hasRole(request, "ADMIN")
                || hasRole(request, "RECEPTIONIST");
    }

    // Display the staff list or an Admin-only form.
    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        if (!isAdminOrReceptionist(request)) {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "You do not have permission to access staff management."
            );
            return;
        }

        String action = request.getParameter("action");

        // Only Admin can open the registration form.
        if ("new".equals(action)) {
            if (!hasRole(request, "ADMIN")) {
                response.sendError(
                        HttpServletResponse.SC_FORBIDDEN,
                        "Only administrators can register staff."
                );
                return;
            }

            try {
                showStaffForm(request, response);
            } catch (SQLException e) {
                throw new ServletException(
                        "Unable to load the staff registration form.", e
                );
            }
            return;
        }

        // Only Admin can open the edit form.
        if ("edit".equals(action)) {
            if (!hasRole(request, "ADMIN")) {
                response.sendError(
                        HttpServletResponse.SC_FORBIDDEN,
                        "Only administrators can edit staff."
                );
                return;
            }

            try {
                int staffId = parseId(request.getParameter("id"));
                Staff staff = staffDAO.getStaffById(staffId);

                if (staff == null) {
                    response.sendError(
                            HttpServletResponse.SC_NOT_FOUND,
                            "Staff member not found."
                    );
                    return;
                }

                request.setAttribute("staff", staff);
                request.setAttribute(
                        "departments",
                        staffDAO.getActiveDepartments()
                );

                request.getRequestDispatcher(
                        "/WEB-INF/views/staff-edit.jsp"
                ).forward(request, response);

            } catch (IllegalArgumentException e) {
                response.sendError(
                        HttpServletResponse.SC_BAD_REQUEST,
                        "Invalid staff ID."
                );
            } catch (SQLException e) {
                throw new ServletException(
                        "Unable to retrieve staff information.", e
                );
            }
            return;
        }

        // Admin and Receptionist can view the staff list.
        try {
            request.setAttribute(
                    "staffList", staffDAO.getAllStaff()
            );

            request.getRequestDispatcher(
                    "/WEB-INF/views/staff.jsp"
            ).forward(request, response);

        } catch (SQLException e) {
            throw new ServletException(
                    "Unable to retrieve staff information.", e
            );
        }
    }

    // Process status changes and Admin-only CRUD operations.
    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String action = clean(request.getParameter("action"));

        // Admin and Receptionist may activate/deactivate staff.
        if ("status".equals(action)) {
            if (!isAdminOrReceptionist(request)) {
                response.sendError(
                        HttpServletResponse.SC_FORBIDDEN,
                        "You cannot change staff status."
                );
                return;
            }

            changeStaffStatus(request, response);
            return;
        }

        // All other POST operations are Admin-only.
        if (!hasRole(request, "ADMIN")) {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Only administrators can modify staff records."
            );
            return;
        }

        try {
            if ("delete".equals(action)) {
                deleteStaff(request, response);
                return;
            }

            boolean updating = "update".equals(action);
            boolean creating = "create".equals(action)
                    || "add".equals(action);

            if (!updating && !creating) {
                response.sendError(
                        HttpServletResponse.SC_BAD_REQUEST,
                        "Unknown staff operation. Received action: ["
                                + action + "]"
                );
                return;
            }

            int staffId = 0;

            if (updating) {
                staffId = parseId(
                        request.getParameter("staffId")
                );

                if (staffDAO.getStaffById(staffId) == null) {
                    response.sendError(
                            HttpServletResponse.SC_NOT_FOUND,
                            "Staff member not found."
                    );
                    return;
                }
            }

            String fullName =
                    clean(request.getParameter("fullName"));
            String designation =
                    clean(request.getParameter("designation"));
            String staffType =
                    clean(request.getParameter("staffType"));
            String phone =
                    clean(request.getParameter("phone"));
            String email =
                    clean(request.getParameter("email"));

            String status = updating
                    ? clean(request.getParameter("employmentStatus"))
                    : "ACTIVE";

            int departmentId = parseId(
                    request.getParameter("departmentId")
            );

            List<Department> departments =
                    staffDAO.getActiveDepartments();

            boolean activeDepartment = departments.stream()
                    .anyMatch(d ->
                            d.getDepartmentId() == departmentId);

            if (!activeDepartment
                    || fullName.isEmpty()
                    || fullName.length() > 120
                    || designation.isEmpty()
                    || designation.length() > 100
                    || !validStaffType(staffType)
                    || phone.length() > 20
                    || email.length() > 150
                    || (!email.isEmpty() && !validEmail(email))
                    || (updating && !validStatus(status))) {

                request.setAttribute(
                        "errorMessage",
                        "Please check all entered details and try again."
                );
                request.setAttribute("departments", departments);

                if (updating) {
                    Staff staff = staffDAO.getStaffById(staffId);

                    staff.setFullName(fullName);
                    staff.setDepartmentId(departmentId);
                    staff.setDesignation(designation);
                    staff.setStaffType(staffType);
                    staff.setPhone(phone);
                    staff.setEmail(email);
                    staff.setEmploymentStatus(status);

                    request.setAttribute("staff", staff);

                    request.getRequestDispatcher(
                            "/WEB-INF/views/staff-edit.jsp"
                    ).forward(request, response);

                } else {
                    request.getRequestDispatcher(
                            "/WEB-INF/views/staff-form.jsp"
                    ).forward(request, response);
                }

                return;
            }

            Staff staff = new Staff();
            staff.setStaffId(staffId);
            staff.setDepartmentId(departmentId);
            staff.setFullName(fullName);
            staff.setDesignation(designation);
            staff.setStaffType(staffType);
            staff.setPhone(phone.isEmpty() ? null : phone);
            staff.setEmail(email.isEmpty() ? null : email);
            staff.setEmploymentStatus(status);

            boolean success = updating
                    ? staffDAO.updateStaff(staff)
                    : staffDAO.addStaff(staff);

            if (success) {
                response.sendRedirect(
                        request.getContextPath() + "/staff?"
                        + (updating ? "updated=1" : "registered=1")
                );
            } else {
                response.sendError(
                        HttpServletResponse.SC_NOT_FOUND,
                        "No staff record was changed."
                );
            }

        } catch (IllegalArgumentException e) {
            request.setAttribute(
                    "errorMessage",
                    "Please provide a valid staff ID and form details."
            );
            showFormSafely(request, response);

        } catch (SQLException e) {
            throw new ServletException(
                    "Unable to save staff information. "
                    + "Check the server log.",
                    e
            );
        }
    }

    // Activate or deactivate a staff member.
    private void changeStaffStatus(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        try {
            int staffId = parseId(
                    request.getParameter("staffId")
            );

            String status = clean(
                    request.getParameter("employmentStatus")
            );

            // Receptionists may only choose ACTIVE or INACTIVE.
            if (!"ACTIVE".equals(status)
                    && !"INACTIVE".equals(status)) {

                response.sendError(
                        HttpServletResponse.SC_BAD_REQUEST,
                        "Status must be ACTIVE or INACTIVE."
                );
                return;
            }

            if (staffDAO.getStaffById(staffId) == null) {
                response.sendError(
                        HttpServletResponse.SC_NOT_FOUND,
                        "Staff member not found."
                );
                return;
            }

            if (staffDAO.updateStaffStatus(staffId, status)) {
                response.sendRedirect(
                        request.getContextPath()
                        + "/staff?statusUpdated=1"
                );
            } else {
                response.sendError(
                        HttpServletResponse.SC_NOT_FOUND,
                        "Staff status was not changed."
                );
            }

        } catch (IllegalArgumentException e) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Invalid staff ID."
            );

        } catch (SQLException e) {
            throw new ServletException(
                    "Unable to update staff status.", e
            );
        }
    }

    private void deleteStaff(HttpServletRequest request,
                             HttpServletResponse response)
            throws IOException, SQLException {

        int staffId = parseId(
                request.getParameter("staffId")
        );

        if (staffDAO.getStaffById(staffId) == null) {
            response.sendError(
                    HttpServletResponse.SC_NOT_FOUND,
                    "Staff member not found."
            );
            return;
        }

        if (staffDAO.deleteStaff(staffId)) {
            response.sendRedirect(
                    request.getContextPath() + "/staff?deleted=1"
            );
        } else {
            response.sendError(
                    HttpServletResponse.SC_NOT_FOUND,
                    "Staff member could not be deleted."
            );
        }
    }

    private void showStaffForm(HttpServletRequest request,
                               HttpServletResponse response)
            throws SQLException, ServletException, IOException {

        request.setAttribute(
                "departments", staffDAO.getActiveDepartments()
        );

        request.getRequestDispatcher(
                "/WEB-INF/views/staff-form.jsp"
        ).forward(request, response);
    }

    private void showFormSafely(HttpServletRequest request,
                                HttpServletResponse response)
            throws ServletException, IOException {

        try {
            request.setAttribute(
                    "departments", staffDAO.getActiveDepartments()
            );

            request.getRequestDispatcher(
                    "/WEB-INF/views/staff-form.jsp"
            ).forward(request, response);

        } catch (SQLException e) {
            throw new ServletException(
                    "Unable to load departments.", e
            );
        }
    }

    private int parseId(String value) {
        if (value == null || !value.matches("\\d+")) {
            throw new IllegalArgumentException("Invalid ID");
        }

        return Integer.parseInt(value);
    }

    private String clean(String value) {
        return value == null ? "" : value.trim();
    }

    private boolean validStaffType(String value) {
        return "NURSE".equals(value)
                || "RESIDENT".equals(value)
                || "CONSULTANT".equals(value)
                || "TECHNICIAN".equals(value)
                || "ADMINISTRATIVE".equals(value)
                || "OTHER".equals(value);
    }

    private boolean validStatus(String value) {
        return "ACTIVE".equals(value)
                || "ON_LEAVE".equals(value)
                || "INACTIVE".equals(value);
    }

    private boolean validEmail(String email) {
        return email.matches(
                "^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$"
        );
    }
}