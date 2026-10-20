package com.hospital.servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.SQLException;

import com.hospital.util.DBConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/database-test")
public class DatabaseTestServlet extends HttpServlet {

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html;charset=UTF-8");

        try (PrintWriter out = response.getWriter()) {

            out.println("<!DOCTYPE html>");
            out.println("<html><head><title>Database Test</title></head>");
            out.println("<body style='font-family:Arial;padding:30px'>");
            out.println("<h1>Hospital Management System</h1>");

            try (Connection connection = DBConnection.getConnection()) {

                if (connection.isValid(5)) {
                    out.println("<h2 style='color:green'>");
                    out.println("Database connection successful!");
                    out.println("</h2>");
                    out.println("<p>Database: hospital_db</p>");
                } else {
                    out.println("<h2>Database connection could not be verified.</h2>");
                }

            } catch (SQLException e) {
                getServletContext().log(
                    "Database connection test failed.", e);

                out.println("<h2 style='color:red'>");
                out.println("Database connection failed.</h2>");
                out.println("<p>Check the server log for the technical details.</p>");
            }

            out.println("</body></html>");
        }
    }
}
