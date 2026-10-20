
package com.hospital.servlet;

import com.hospital.dao.DashboardStatsDAO;
import com.hospital.dao.DashboardAnalyticsDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Map;

@WebServlet("/generate-report")
public class GenerateReportServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final DashboardStatsDAO statsDAO =
            new DashboardStatsDAO();

    private final DashboardAnalyticsDAO analyticsDAO =
            new DashboardAnalyticsDAO();

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        response.setHeader("Cache-Control",
                "no-store, no-cache, must-revalidate, max-age=0");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);

        HttpSession session = request.getSession(false);

        if (session == null
                || session.getAttribute("userId") == null) {
            response.sendRedirect(
                    request.getContextPath() + "/login");
            return;
        }

        Object role = session.getAttribute("role");

        if (!"ADMIN".equals(role)) {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Only administrators can generate reports.");
            return;
        }

        try {
            Map<String, Integer> stats =
                    statsDAO.getDashboardStats();

            Map<String, Integer> appointments =
                    analyticsDAO.getAppointmentSummary();

            Map<String, Integer> emergencies =
                    analyticsDAO.getEmergencySummary();

            response.setContentType("text/html;charset=UTF-8");

            var out = response.getWriter();

            out.println("""
                <!DOCTYPE html>
                <html lang="en">
                <head>
                <meta charset="UTF-8">
                <meta name="viewport"
                      content="width=device-width, initial-scale=1">
                <title>Hospital Management Report</title>
                <style>
                    body {
                        font-family: Arial, sans-serif;
                        margin: 35px auto;
                        max-width: 900px;
                        padding: 20px;
                        color: #243247;
                    }
                    h1 { color: #176b87; }
                    h2 {
                        margin-top: 28px;
                        border-bottom: 1px solid #ddd;
                        padding-bottom: 8px;
                    }
                    table {
                        width: 100%;
                        border-collapse: collapse;
                        margin-top: 12px;
                    }
                    th, td {
                        border: 1px solid #ddd;
                        padding: 11px;
                        text-align: left;
                    }
                    th { background: #edf4f8; }
                    .actions { margin-bottom: 24px; }
                    button {
                        padding: 10px 18px;
                        margin-right: 8px;
                        cursor: pointer;
                    }
                    .note {
                        color: #657386;
                        font-size: 13px;
                        margin-top: 30px;
                    }
                    @media print {
                        .actions { display: none; }
                        body { margin: 0; padding: 10px; }
                    }
                </style>
                </head>
                <body>
                <div class="actions">
                    <button onclick="window.print()">
                        Print / Save as PDF
                    </button>
                    <button onclick="window.close()">
                        Close
                    </button>
                </div>
                <h1>Hospital Management System</h1>
                <h2>Hospital Analytics Report</h2>
                """);

            out.println("<p><strong>Generated:</strong> "
                    + escape(LocalDateTime.now().format(
                    DateTimeFormatter.ofPattern(
                            "dd MMM yyyy, hh:mm a")))
                    + "</p>");

            printTable(out, "Hospital Statistics", stats);
            printTable(out, "Appointment Summary", appointments);
            printTable(out, "Emergency Summary", emergencies);

            out.println("""
                <p class="note">
                    This report was generated from the hospital
                    database at the time shown above.
                </p>
                </body>
                </html>
                """);

        } catch (SQLException e) {
            getServletContext().log(
                    "Unable to generate hospital report.", e);

            response.sendError(
                    HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Unable to generate the report. Please try again.");
        }
    }

    private void printTable(
            java.io.PrintWriter out,
            String title,
            Map<String, Integer> data) {

        out.println("<h2>" + escape(title) + "</h2>");
        out.println("<table><thead><tr>"
                + "<th>Metric</th><th>Value</th>"
                + "</tr></thead><tbody>");

        if (data == null || data.isEmpty()) {
            out.println("<tr><td colspan=\"2\">"
                    + "No data available</td></tr>");
        } else {
            for (Map.Entry<String, Integer> entry
                    : data.entrySet()) {

                out.println("<tr><td>"
                        + escape(entry.getKey())
                        + "</td><td>"
                        + (entry.getValue() == null
                        ? "N/A" : entry.getValue())
                        + "</td></tr>");
            }
        }

        out.println("</tbody></table>");
    }

    private String escape(String value) {
        if (value == null) {
            return "";
        }

        return value.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }
}
