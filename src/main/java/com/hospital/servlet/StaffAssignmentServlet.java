
package com.hospital.servlet;

import com.hospital.dao.StaffAssignmentDAO;
import com.hospital.dao.StaffDAO;
import com.hospital.model.Department;
import com.hospital.model.Staff;
import com.hospital.model.StaffAssignment;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.List;

@WebServlet("/staff-assignments")
public class StaffAssignmentServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final StaffAssignmentDAO assignmentDAO =
            new StaffAssignmentDAO();

    private final StaffDAO staffDAO = new StaffDAO();

    private boolean hasRole(HttpSession session, String... roles) {
        Object roleObject = session.getAttribute("role");

        if (roleObject == null) {
            return false;
        }

        for (String allowed : roles) {
            if (allowed.equalsIgnoreCase(roleObject.toString())) {
                return true;
            }
        }

        return false;
    }

    private int positiveInt(String value, String field) {
        if (value == null || value.trim().isEmpty()) {
            throw new IllegalArgumentException(
                    field + " is required.");
        }

        try {
            int number = Integer.parseInt(value);

            if (number <= 0) {
                throw new IllegalArgumentException(
                        field + " must be greater than zero.");
            }

            return number;

        } catch (NumberFormatException e) {
            throw new IllegalArgumentException(
                    "Invalid " + field + ".");
        }
    }

    private void redirectWithMessage(
            HttpServletRequest request,
            HttpServletResponse response,
            String message) throws IOException {

        request.getSession().setAttribute(
                "assignmentMessage", message);

        response.sendRedirect(
                request.getContextPath() + "/staff-assignments");
    }

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null ||
                session.getAttribute("userId") == null) {

            response.sendRedirect(
                    request.getContextPath() + "/login");
            return;
        }

        if (!hasRole(session, "ADMIN", "DOCTOR",
                "RECEPTIONIST", "STAFF")) {

            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        try {
            List<StaffAssignment> assignments =
                    assignmentDAO.getAllAssignments();

            request.setAttribute("assignments", assignments);

            boolean canManage =
                    hasRole(session, "ADMIN", "RECEPTIONIST");

            request.setAttribute("canManage", canManage);

            if (canManage) {
                List<Staff> staffList = staffDAO.getAllStaff();

                // Only active staff can receive new assignments.
                staffList.removeIf(staff ->
                        !"ACTIVE".equalsIgnoreCase(
                                staff.getEmploymentStatus()));

                List<Department> departments =
                        staffDAO.getActiveDepartments();

                request.setAttribute("staffList", staffList);
                request.setAttribute("departments", departments);
            }

            request.getRequestDispatcher(
                    "/WEB-INF/views/staff-assignments.jsp")
                    .forward(request, response);

        } catch (SQLException e) {
            throw new ServletException(
                    "Unable to load staff assignments.", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);

        if (session == null ||
                session.getAttribute("userId") == null) {

            response.sendRedirect(
                    request.getContextPath() + "/login");
            return;
        }

        if (!hasRole(session, "ADMIN", "RECEPTIONIST")) {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        try {
            String action = request.getParameter("action");

            if ("add".equals(action)) {

                int staffId = positiveInt(
                        request.getParameter("staffId"), "Staff");

                int departmentId = positiveInt(
                        request.getParameter("departmentId"),
                        "Department");

                // Verify that the selected staff member exists
                // and is currently active.
                Staff staff = staffDAO.getStaffById(staffId);

                if (staff == null ||
                        !"ACTIVE".equalsIgnoreCase(
                                staff.getEmploymentStatus())) {

                    throw new IllegalArgumentException(
                            "Select an existing active staff member.");
                }

                // Verify that the department is active.
                List<Department> activeDepartments =
                        staffDAO.getActiveDepartments();

                boolean departmentActive =
                        activeDepartments.stream().anyMatch(
                                d -> d.getDepartmentId() == departmentId);

                if (!departmentActive) {
                    throw new IllegalArgumentException(
                            "Select an active department.");
                }

                String title =
                        request.getParameter("assignmentTitle");

                if (title == null ||
                        title.trim().isEmpty() ||
                        title.trim().length() > 150) {

                    throw new IllegalArgumentException(
                            "Assignment title is required (maximum 150 characters).");
                }

                String location =
                        request.getParameter("dutyLocation");

                String notes = request.getParameter("notes");

                String startValue =
                        request.getParameter("shiftStart");

                String endValue =
                        request.getParameter("shiftEnd");

                if (startValue == null || endValue == null ||
                        startValue.isBlank() || endValue.isBlank()) {

                    throw new IllegalArgumentException(
                            "Both shift start and shift end are required.");
                }

                LocalDateTime start;
                LocalDateTime end;

                try {
                    start = LocalDateTime.parse(startValue);
                    end = LocalDateTime.parse(endValue);
                } catch (Exception e) {
                    throw new IllegalArgumentException(
                            "Enter valid shift dates and times.");
                }

                if (!end.isAfter(start)) {
                    throw new IllegalArgumentException(
                            "Shift end must be after shift start.");
                }

                if (location != null && location.trim().length() > 150) {
                    throw new IllegalArgumentException(
                            "Duty location cannot exceed 150 characters.");
                }

                if (notes != null && notes.trim().length() > 500) {
                    throw new IllegalArgumentException(
                            "Notes cannot exceed 500 characters.");
                }

                int userId = positiveInt(
                        String.valueOf(
                                session.getAttribute("userId")),
                        "User");

                StaffAssignment assignment =
                        new StaffAssignment();

                assignment.setStaffId(staffId);
                assignment.setDepartmentId(departmentId);
                assignment.setAssignedBy(userId);
                assignment.setAssignmentTitle(title.trim());

                assignment.setDutyLocation(
                        location == null || location.isBlank()
                                ? null : location.trim());

                assignment.setShiftStart(
                        Timestamp.valueOf(start));

                assignment.setShiftEnd(
                        Timestamp.valueOf(end));

                assignment.setAssignmentStatus("SCHEDULED");

                assignment.setNotes(
                        notes == null || notes.isBlank()
                                ? null : notes.trim());

                if (assignmentDAO.addAssignment(assignment)) {
                    redirectWithMessage(
                            request, response,
                            "Staff assignment created successfully.");
                } else {
                    redirectWithMessage(
                            request, response,
                            "Assignment was not created.");
                }

            } else if ("updateStatus".equals(action)) {

                int assignmentId = positiveInt(
                        request.getParameter("assignmentId"),
                        "Assignment");

                String status = request.getParameter("status");

                if (status == null ||
                        !status.matches(
                                "SCHEDULED|IN_PROGRESS|COMPLETED|CANCELLED")) {

                    throw new IllegalArgumentException(
                            "Invalid assignment status.");
                }

                if (assignmentDAO.updateStatus(
                        assignmentId, status)) {

                    redirectWithMessage(
                            request, response,
                            "Assignment status updated successfully.");
                } else {
                    redirectWithMessage(
                            request, response,
                            "Assignment not found.");
                }

            } else {
                response.sendError(
                        HttpServletResponse.SC_BAD_REQUEST,
                        "Invalid assignment action.");
            }

        } catch (IllegalArgumentException e) {
            redirectWithMessage(
                    request, response, e.getMessage());

        } catch (SQLException e) {
            throw new ServletException(
                    "Database error while processing assignment.", e);
        }
    }
}
