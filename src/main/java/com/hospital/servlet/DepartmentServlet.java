
package com.hospital.servlet;

import java.io.IOException;
import java.sql.SQLException;

import com.hospital.dao.DepartmentDAO;
import com.hospital.model.Department;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/departments/*")
public class DepartmentServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final DepartmentDAO departmentDAO = new DepartmentDAO();

    // READ: List departments and open forms
    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        String path = request.getPathInfo();

        try {
            // Open the Create Department form
            if ("/new".equals(path)) {
                request.getRequestDispatcher(
                    "/WEB-INF/views/department-form.jsp"
                ).forward(request, response);
                return;
            }

            // Open the Edit Department form
            if ("/edit".equals(path)) {
                int departmentId = parseDepartmentId(
                    request.getParameter("id")
                );

                if (departmentId <= 0) {
                    response.sendError(
                        HttpServletResponse.SC_BAD_REQUEST,
                        "Invalid department ID."
                    );
                    return;
                }

                Department department =
                    departmentDAO.getDepartmentById(departmentId);

                if (department == null) {
                    response.sendError(
                        HttpServletResponse.SC_NOT_FOUND,
                        "Department not found."
                    );
                    return;
                }

                request.setAttribute("department", department);

                request.getRequestDispatcher(
                    "/WEB-INF/views/department-edit.jsp"
                ).forward(request, response);
                return;
            }

            // Read: Display all departments
            if (path == null || "/".equals(path)) {
                request.setAttribute(
                    "departments",
                    departmentDAO.getAllDepartments()
                );

                request.getRequestDispatcher(
                    "/WEB-INF/views/departments.jsp"
                ).forward(request, response);
                return;
            }

            response.sendError(
                HttpServletResponse.SC_NOT_FOUND,
                "Page not found."
            );

        } catch (SQLException e) {
            log("Database error while processing departments.", e);
            response.sendError(
                HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                "A database error occurred."
            );
        }
    }

    // CREATE, UPDATE and DELETE
    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String path = request.getPathInfo();

        try {
            // UPDATE: Save edited department
            if ("/update".equals(path)) {
                updateDepartment(request, response);
                return;
            }

            // DELETE: Remove a department
            if ("/delete".equals(path)) {
                deleteDepartment(request, response);
                return;
            }

            // CREATE: Preserve existing department registration
            if (path == null || "/".equals(path)) {
                createDepartment(request, response);
                return;
            }

            response.sendError(
                HttpServletResponse.SC_NOT_FOUND,
                "Action not found."
            );

        } catch (SQLException e) {
            log("Database error while saving department.", e);

            if ("23000".equals(e.getSQLState())) {
                response.sendError(
                    HttpServletResponse.SC_CONFLICT,
                    "The department name may already exist, or related "
                    + "records prevent this operation."
                );
            } else {
                response.sendError(
                    HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "A database error occurred."
                );
            }
        }
    }

    // CREATE
    private void createDepartment(HttpServletRequest request,
                                 HttpServletResponse response)
            throws SQLException, IOException {

        String departmentName =
            request.getParameter("departmentName");
        String description = request.getParameter("description");
        String location = request.getParameter("location");
        String status = request.getParameter("status");

        if (!isValidDepartment(
                departmentName, description, location, status)) {
            response.sendError(
                HttpServletResponse.SC_BAD_REQUEST,
                "Invalid department details."
            );
            return;
        }

        departmentDAO.addDepartment(
            departmentName.trim(),
            cleanOptional(description),
            cleanOptional(location),
            status
        );

        response.sendRedirect(
            request.getContextPath() + "/departments"
        );
    }

    // UPDATE
    private void updateDepartment(HttpServletRequest request,
                                 HttpServletResponse response)
            throws SQLException, IOException {

        int departmentId = parseDepartmentId(
            request.getParameter("departmentId")
        );

        if (departmentId <= 0) {
            response.sendError(
                HttpServletResponse.SC_BAD_REQUEST,
                "Invalid department ID."
            );
            return;
        }

        String departmentName =
            request.getParameter("departmentName");
        String description = request.getParameter("description");
        String location = request.getParameter("location");
        String status = request.getParameter("status");

        if (!isValidDepartment(
                departmentName, description, location, status)) {
            response.sendError(
                HttpServletResponse.SC_BAD_REQUEST,
                "Invalid department details."
            );
            return;
        }

        boolean updated = departmentDAO.updateDepartment(
            departmentId,
            departmentName.trim(),
            cleanOptional(description),
            cleanOptional(location),
            status
        );

        // An unchanged record can return false in MySQL.
        // Check whether the department still exists.
        if (!updated &&
            departmentDAO.getDepartmentById(departmentId) == null) {
            response.sendError(
                HttpServletResponse.SC_NOT_FOUND,
                "Department not found."
            );
            return;
        }

        response.sendRedirect(
            request.getContextPath() + "/departments?updated=1"
        );
    }

    // DELETE
    private void deleteDepartment(HttpServletRequest request,
                                  HttpServletResponse response)
            throws SQLException, IOException {

        int departmentId = parseDepartmentId(
            request.getParameter("departmentId")
        );

        if (departmentId <= 0) {
            response.sendError(
                HttpServletResponse.SC_BAD_REQUEST,
                "Invalid department ID."
            );
            return;
        }

        boolean deleted =
            departmentDAO.deleteDepartment(departmentId);

        if (!deleted) {
            response.sendError(
                HttpServletResponse.SC_NOT_FOUND,
                "Department not found."
            );
            return;
        }

        response.sendRedirect(
            request.getContextPath() + "/departments?deleted=1"
        );
    }

    // Validate the department fields
    private boolean isValidDepartment(
            String name,
            String description,
            String location,
            String status) {

        return name != null
            && !name.trim().isEmpty()
            && name.trim().length() <= 100
            && (description == null || description.length() <= 500)
            && (location == null || location.length() <= 150)
            && ("ACTIVE".equals(status) || "INACTIVE".equals(status));
    }

    private String cleanOptional(String value) {
        if (value == null || value.trim().isEmpty()) {
            return null;
        }
        return value.trim();
    }

    private int parseDepartmentId(String value) {
        try {
            int id = Integer.parseInt(value);
            return id > 0 ? id : -1;
        } catch (NumberFormatException | NullPointerException e) {
            return -1;
        }
    }
}
