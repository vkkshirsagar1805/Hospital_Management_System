
package com.hospital.servlet;

import com.hospital.dao.UserDAO;
import com.hospital.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.util.Set;

@WebServlet("/users")
public class UserManagementServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final UserDAO userDAO = new UserDAO();

    private static final Set<String> VALID_ROLES = Set.of(
            "ADMIN", "DOCTOR", "STAFF", "RECEPTIONIST"
    );

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        if (!requireAdmin(request, response)) {
            return;
        }

        request.getRequestDispatcher(
                "/WEB-INF/views/user-form.jsp"
        ).forward(request, response);
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        if (!requireAdmin(request, response)) {
            return;
        }

        request.setCharacterEncoding("UTF-8");

        String username = clean(request.getParameter("username"));
        String password = request.getParameter("password");
        String role = clean(request.getParameter("role"));

        String error = null;

        if (username == null || username.length() < 3
                || username.length() > 60
                || !username.matches("[A-Za-z0-9._-]+")) {
            error = "Username must be 3–60 characters and contain "
                    + "only letters, numbers, dots, underscores, "
                    + "or hyphens.";
        } else if (password == null || password.length() < 12
                || password.length() > 72) {
            error = "Password must contain 12–72 characters.";
        } else if (role == null || !VALID_ROLES.contains(role)) {
            error = "Select a valid user role.";
        }

        if (error != null) {
            request.setAttribute("errorMessage", error);
            request.setAttribute("enteredUsername", username);
            request.getRequestDispatcher(
                    "/WEB-INF/views/user-form.jsp"
            ).forward(request, response);
            return;
        }

        try {
            boolean created = userDAO.createUser(
                    username, password, role
            );

            if (created) {
                response.sendRedirect(
                        request.getContextPath()
                        + "/users?created=1"
                );
            } else {
                request.setAttribute(
                        "errorMessage",
                        "The account could not be created."
                );
                request.setAttribute("enteredUsername", username);
                request.getRequestDispatcher(
                        "/WEB-INF/views/user-form.jsp"
                ).forward(request, response);
            }

        } catch (SQLException e) {
            // MySQL duplicate-key error
            if ("23000".equals(e.getSQLState())) {
                request.setAttribute(
                        "errorMessage",
                        "That username already exists. Choose another."
                );
                request.setAttribute("enteredUsername", username);
                request.getRequestDispatcher(
                        "/WEB-INF/views/user-form.jsp"
                ).forward(request, response);
            } else {
                throw new ServletException(
                        "Unable to create user account.", e
                );
            }
        }
    }

    private boolean requireAdmin(
            HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

        HttpSession session = request.getSession(false);

        if (session == null
                || session.getAttribute("userId") == null) {
            response.sendRedirect(
                    request.getContextPath() + "/login"
            );
            return false;
        }

        if (!"ADMIN".equals(session.getAttribute("role"))) {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Only administrators can manage user accounts."
            );
            return false;
        }

        return true;
    }

    private String clean(String value) {
        if (value == null) {
            return null;
        }

        String cleaned = value.trim();
        return cleaned.isEmpty() ? null : cleaned;
    }
}
