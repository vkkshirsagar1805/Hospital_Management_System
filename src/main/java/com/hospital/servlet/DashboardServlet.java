
package com.hospital.servlet;

import com.hospital.dao.DashboardAnalyticsDAO;
import com.hospital.dao.DashboardStatsDAO;
import com.hospital.dao.AppointmentDAO;
import com.hospital.model.Appointment;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.util.Collections;
import java.util.List;
import java.util.Map;

@WebServlet("/dashboard")
public class DashboardServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final DashboardStatsDAO dashboardStatsDAO =
            new DashboardStatsDAO();

    private final DashboardAnalyticsDAO dashboardAnalyticsDAO =
            new DashboardAnalyticsDAO();

    private final AppointmentDAO appointmentDAO = new AppointmentDAO();

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        // Prevent the browser from caching protected dashboard data.
        response.setHeader("Cache-Control",
                "no-store, no-cache, must-revalidate, max-age=0");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);

        HttpSession session = request.getSession(false);

        // Require an existing authenticated session.
        if (session == null ||
                session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String role = (String) session.getAttribute("role");

        Integer doctorId = null;
        Object doctorIdValue = session.getAttribute("doctorId");

        if (doctorIdValue instanceof Number) {
            doctorId = ((Number) doctorIdValue).intValue();
        }

        try {
            List<Appointment> workflowAppointments =
                    appointmentDAO.getAppointmentsForRole(role, doctorId);

            request.setAttribute(
                    "workflowAppointments",
                    workflowAppointments
            );

        } catch (SQLException e) {
            throw new ServletException(
                    "Unable to load dashboard appointments.", e
            );
        }

        String period = request.getParameter("period");

        if (period == null ||
                !(period.equalsIgnoreCase("daily")
                || period.equalsIgnoreCase("weekly")
                || period.equalsIgnoreCase("monthly")
                || period.equalsIgnoreCase("yearly"))) {
            period = "weekly";
        }

        request.setAttribute("selectedPeriod", period);

        try {
            Map<String, Integer> stats =
                    dashboardStatsDAO.getDashboardStats();

            request.setAttribute("dashboardStats", stats);

        } catch (SQLException e) {
            getServletContext().log(
                    "Failed to load dashboard statistics.", e);

            request.setAttribute(
                    "dashboardStats",
                    Collections.<String, Integer>emptyMap());

            request.setAttribute(
                    "dashboardStatsError",
                    "Live statistics are temporarily unavailable.");
        }

        try {
            Map<String, Integer> appointmentSummary =
                    dashboardAnalyticsDAO.getAppointmentSummary();

            request.setAttribute(
                    "appointmentSummary", appointmentSummary);

            Map<String, Integer> emergencySummary =
                    dashboardAnalyticsDAO.getEmergencySummary();

            request.setAttribute(
                    "emergencySummary", emergencySummary);

            List<Map<String, Object>> patientTrend =
                    dashboardAnalyticsDAO.getPatientRegistrationTrend(period);

            request.setAttribute("patientRegistrationTrend", patientTrend);

        } catch (SQLException e) {
            getServletContext().log(
                    "Failed to load dashboard analytics.", e);

            request.setAttribute(
                    "dashboardAnalyticsError",
                    "Some analytics are temporarily unavailable.");
        }

        request.getRequestDispatcher(
                "/WEB-INF/views/dashboard.jsp")
                .forward(request, response);
    }
}
