
package com.hospital.servlet;

import com.hospital.dao.UserDAO;
import com.hospital.model.User;
import com.hospital.util.PasswordUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate");
        response.setHeader("Pragma", "no-cache");

        // If already authenticated, go to the dashboard.
        HttpSession session = request.getSession(false);

        if (session != null && session.getAttribute("userId") != null) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }

        request.getRequestDispatcher(
                "/WEB-INF/views/login.jsp"
        ).forward(request, response);
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate");
        response.setHeader("Pragma", "no-cache");

        String username = request.getParameter("username");
        String password = request.getParameter("password");

        if (username == null || password == null
                || username.isBlank() || password.isEmpty()) {
            response.sendRedirect(
                    request.getContextPath() + "/login?error=1");
            return;
        }

        try {
            User user = userDAO.getUserByUsername(username.trim());

            if (user == null) {
                response.sendRedirect(
                        request.getContextPath() + "/login?error=1");
                return;
            }

            if (!"ACTIVE".equalsIgnoreCase(user.getAccountStatus())) {
                response.sendRedirect(
                        request.getContextPath() + "/login?error=disabled");
                return;
            }

            if (!PasswordUtil.verifyPassword(
                    password, user.getPasswordHash())) {
                response.sendRedirect(
                        request.getContextPath() + "/login?error=1");
                return;
            }

            // Resolve the doctor's linked record before authentication
            // is completed and before sending any redirect.
            Integer doctorId = null;

            if ("DOCTOR".equalsIgnoreCase(user.getRole())) {
                doctorId = userDAO.getDoctorIdByUserId(user.getUserId());

                if (doctorId == null) {
                    response.sendRedirect(
                            request.getContextPath()
                                    + "/login?error=doctor-not-linked");
                    return;
                }
            }

            // Invalidate any existing session to prevent session fixation.
            HttpSession oldSession = request.getSession(false);

            if (oldSession != null) {
                oldSession.invalidate();
            }

            // Create a fresh authenticated session.
            HttpSession session = request.getSession(true);
            session.setMaxInactiveInterval(20 * 60);

            session.setAttribute("userId", user.getUserId());
            session.setAttribute("username", user.getUsername());
            session.setAttribute("role", user.getRole());

            if (doctorId != null) {
                session.setAttribute("doctorId", doctorId);
            }

            // Redirect only after all required session attributes are set.
            response.sendRedirect(
                    request.getContextPath() + "/dashboard");

        } catch (SQLException e) {
            getServletContext().log("Login database operation failed.", e);
            throw new ServletException(
                    "Unable to authenticate user.", e);
        }
    }
}
