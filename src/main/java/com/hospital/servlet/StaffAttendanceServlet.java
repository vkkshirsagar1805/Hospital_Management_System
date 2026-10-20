package com.hospital.servlet;

import com.hospital.dao.StaffAttendanceDAO;
import com.hospital.model.StaffAttendance;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.time.LocalDateTime;

@WebServlet("/staff-attendance")
public class StaffAttendanceServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final StaffAttendanceDAO attendanceDAO =
            new StaffAttendanceDAO();
    

    @Override
    protected void doGet(
    		HttpServletRequest request,
    		HttpServletResponse response)
    				throws ServletException, IOException {

    	HttpSession session = request.getSession(false);
    	
    	if (session == null || session.getAttribute("userId") == null) {
    		response.sendRedirect(request.getContextPath() + "/login");
    		return;
    	}
    	
    	Object roleValue = session.getAttribute("role");

    	String role = roleValue == null
    	        ? ""
    	        : roleValue.toString().trim().toUpperCase(
    	                java.util.Locale.ROOT);
    	System.out.println("=== STAFF ATTENDANCE DEBUG ===");
    	System.out.println("Session userId: " + session.getAttribute("userId"));
    	System.out.println("Session role (raw): [" + roleValue + "]");
    	System.out.println("Session role (normalized): [" + role + "]");
    	System.out.println("================================");
    	
    	try {
    		if ("ADMIN".equals(role)) {

    			java.time.LocalDate today =
    					java.time.LocalDate.now(
    							java.time.ZoneId.of("Asia/Kolkata"));

    			request.setAttribute(
    					"attendanceRecords",
    					attendanceDAO.getAttendanceByDate(today));

    			request.setAttribute("attendanceDate", today);
    			request.setAttribute("isAdmin", true);
    			
    		} else if ("STAFF".equals(role)) {

    			int userId = (Integer) session.getAttribute("userId");
    			
    			Integer staffId =
                    	attendanceDAO.getStaffIdByUserId(userId);

    			if (staffId == null) {
    				response.sendError(
    						HttpServletResponse.SC_FORBIDDEN,
    						"No active staff record is linked to this account.");
    				return;
    			}

    			request.setAttribute(
    					"attendance",
    					attendanceDAO.getTodayAttendance(staffId));

    			request.setAttribute("isAdmin", false);
            
    		} else {
    			response.sendError(
    					HttpServletResponse.SC_FORBIDDEN,
    					"You do not have permission to access this module.");
    			return;
    		}

    		request.getRequestDispatcher(
    				"/WEB-INF/views/staff-attendance.jsp")
                	.forward(request, response);

    	} catch (SQLException e) {
    		throw new ServletException(
    				"Unable to load attendance records.", e);
    	}
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String role = (String) session.getAttribute("role");

        if (!"STAFF".equals(role)) {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Staff attendance self-service is available to staff accounts only.");
            return;
        }

        int userId = (Integer) session.getAttribute("userId");
        String action = request.getParameter("action");

        try {
            Integer staffId = attendanceDAO.getStaffIdByUserId(userId);

            if (staffId == null) {
                response.sendError(
                        HttpServletResponse.SC_FORBIDDEN,
                        "No active staff record is linked to this account.");
                return;
            }

            LocalDateTime now = LocalDateTime.now(
            	    java.time.ZoneId.of("Asia/Kolkata")
            	);
            System.out.println("Java timezone: "
            	    + java.time.ZoneId.systemDefault());

            	System.out.println("Java IST time: "
            	    + java.time.LocalDateTime.now(
            	        java.time.ZoneId.of("Asia/Kolkata")));

            	System.out.println("Java system time: "
            	    + java.time.LocalDateTime.now());
            
            boolean success;

            if ("checkIn".equals(action)) {
                success = attendanceDAO.checkIn(staffId, now);

                session.setAttribute(
                        "attendanceMessage",
                        success
                                ? "Check-in recorded successfully."
                                : "Unable to record check-in.");

            } else if ("checkOut".equals(action)) {
                success = attendanceDAO.checkOut(staffId, now);

                session.setAttribute(
                        "attendanceMessage",
                        success
                                ? "Check-out recorded successfully."
                                : "No open check-in was found for today.");

            } else {
                response.sendError(
                        HttpServletResponse.SC_BAD_REQUEST,
                        "Invalid attendance action.");
                return;
            }

            response.sendRedirect(
                    request.getContextPath() + "/staff-attendance");

        } catch (SQLException e) {
            // Duplicate check-in is prevented by the unique
            // (staff_id, attendance_date) constraint.
            throw new ServletException(
                    "Unable to update staff attendance.", e);
        }
    }
}
