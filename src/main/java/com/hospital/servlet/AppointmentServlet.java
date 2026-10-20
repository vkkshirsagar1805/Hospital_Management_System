
package com.hospital.servlet;

import com.hospital.dao.AppointmentDAO;
import com.hospital.model.Appointment;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.TreeSet;

@WebServlet({
    "/appointments",
    "/appointment-doctors",
    "/appointment-slots"
})
public class AppointmentServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private AppointmentDAO appointmentDAO;

    @Override
    public void init() throws ServletException {
        appointmentDAO = new AppointmentDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        String path = request.getServletPath();

        // 1. Load appointments for the dashboard widget.
        if ("/appointments".equals(path)
                && "dashboard".equals(request.getParameter("view"))) {

            HttpSession session = request.getSession(false);

            if (session == null
                    || session.getAttribute("role") == null) {
                response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
                return;
            }

            String role = (String) session.getAttribute("role");

            if (!hasAnyRole(request, "ADMIN", "DOCTOR",
                    "STAFF", "RECEPTIONIST")) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }

            Integer doctorId = null;
            Object doctorIdValue = session.getAttribute("doctorId");

            if (doctorIdValue instanceof Number) {
                doctorId = ((Number) doctorIdValue).intValue();
            }

            try {
                request.setAttribute(
                        "workflowAppointments",
                        appointmentDAO.getAppointmentsForRole(role, doctorId)
                );

                request.getRequestDispatcher(
                        "/WEB-INF/views/appointment-dashboard-widget.jsp"
                ).forward(request, response);

            } catch (SQLException e) {
                throw new ServletException(
                        "Unable to load dashboard appointments.", e
                );
            }

            return;
        }

        // 2. Load doctors for the selected department.
        if ("/appointment-doctors".equals(path)) {

            if (!hasAnyRole(request, "ADMIN", "RECEPTIONIST")) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }

            loadDoctorsByDepartment(request, response);
            return;
        }

        // 3. Load available appointment slots.
        if ("/appointment-slots".equals(path)) {

            if (!hasAnyRole(request, "ADMIN", "RECEPTIONIST")) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }

            loadAppointmentSlots(request, response);
            return;
        }

        try {
            String action = request.getParameter("action");

            // 4. Open the appointment creation form.
            if ("new".equals(action)) {

                if (!hasAnyRole(request, "ADMIN", "RECEPTIONIST")) {
                    response.sendError(
                            HttpServletResponse.SC_FORBIDDEN,
                            "Only Administrators and Receptionists can create appointments."
                    );
                    return;
                }

                loadAppointmentForm(request, response);
                return;
            }

            // 5. Display appointments for the logged-in user.
            HttpSession session = request.getSession(false);

            if (session == null
                    || session.getAttribute("role") == null) {
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }

            String role = (String) session.getAttribute("role");

            if (!hasAnyRole(request, "ADMIN", "DOCTOR",
                    "STAFF", "RECEPTIONIST")) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }

            Integer doctorId = null;
            Object doctorIdValue = session.getAttribute("doctorId");

            if (doctorIdValue instanceof Number) {
                doctorId = ((Number) doctorIdValue).intValue();
            }

            request.setAttribute("currentRole", role);

            List<Appointment> appointments =
                    appointmentDAO.getAppointmentsForRole(role, doctorId);

            request.setAttribute("appointments", appointments);

            request.getRequestDispatcher(
                    "/WEB-INF/views/appointments.jsp"
            ).forward(request, response);

        } catch (SQLException e) {
            throw new ServletException(
                    "Unable to load appointments.", e
            );
        }
    }
    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

String action = request.getParameter("action");

if ("updateStatus".equals(action)) {
    HttpSession session = request.getSession(false);

    if (session == null
            || session.getAttribute("role") == null) {
        response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
        return;
    }

    String role = (String) session.getAttribute("role");
    Integer doctorId = null;

    Object doctorIdValue = session.getAttribute("doctorId");
    if (doctorIdValue instanceof Number) {
        doctorId = ((Number) doctorIdValue).intValue();
    }

    try {
        int appointmentId = Integer.parseInt(
            request.getParameter("appointmentId")
        );

        String newStatus = request.getParameter("newStatus");

        boolean updated = appointmentDAO.updateAppointmentStatus(
            appointmentId, newStatus, role, doctorId
        );

        if (updated) {
            response.sendRedirect(
                request.getContextPath()
                + "/appointments?workflowMessage=updated"
            );
        } else {
            response.sendRedirect(
                request.getContextPath()
                + "/appointments?workflowMessage=not-updated"
            );
        }

    } catch (NumberFormatException e) {
        response.sendError(
            HttpServletResponse.SC_BAD_REQUEST,
            "Invalid appointment ID."
        );
    } catch (SQLException e) {
        throw new ServletException(
            "Unable to update appointment status.", e
        );
    }

    return;
}


        if (!hasAnyRole(request, "ADMIN", "RECEPTIONIST")) {
            response.sendError(
                HttpServletResponse.SC_FORBIDDEN,
                "Only Administrators and Receptionists can create appointments."
            );
            return;
        }

        try {
            String patientValue = request.getParameter("patientId");
            String doctorValue = request.getParameter("doctorId");
            String dateValue = request.getParameter("appointmentDatetime");

            if (patientValue == null || patientValue.isBlank()
                    || doctorValue == null || doctorValue.isBlank()
                    || dateValue == null || dateValue.isBlank()) {

                request.setAttribute(
                    "errorMessage",
                    "Please select a patient, doctor, and appointment date."
                );

                loadAppointmentForm(request, response);
                return;
            }

            int patientId = Integer.parseInt(patientValue);
            int doctorId = Integer.parseInt(doctorValue);

            LocalDateTime dateTime =
                    LocalDateTime.parse(dateValue);

         // Validate doctor status and scheduled working hours.
            Integer scheduleId =
                    appointmentDAO.getScheduleIdForAppointment(doctorId, dateTime);

            if (scheduleId == null) {
                request.setAttribute("errorMessage",
                    "The selected doctor is inactive or unavailable "
                    + "at the selected appointment time. "
                    + "Please select an active doctor and a valid 15-minute slot.");
                loadAppointmentForm(request, response);
                return;
            }
            
            Appointment appointment = new Appointment();

            appointment.setPatientId(patientId);
            appointment.setDoctorId(doctorId);

            // Schedule validation will be added in the next steps.
            appointment.setScheduleId(scheduleId);

            appointment.setAppointmentDatetime(
                Timestamp.valueOf(dateTime)
            );

            appointment.setReason(request.getParameter("reason"));
            appointment.setNotes(request.getParameter("notes"));
            appointment.setAppointmentStatus("REQUESTED");

            boolean saved = appointmentDAO.addAppointment(appointment);

            if (saved) {
                response.sendRedirect(
                    request.getContextPath() + "/appointments?success=created");
            } else {
                request.setAttribute("errorMessage",
                    "This doctor or appointment slot is no longer available. "
                    + "Please select another time slot.");
                loadAppointmentForm(request, response);
            }

        } catch (SQLException e) {
            throw new ServletException(
                "Unable to process appointment.", e
            );

        } catch (IllegalArgumentException e) {
            request.setAttribute(
                "errorMessage",
                "Invalid patient, doctor, or appointment date."
            );

            loadAppointmentForm(request, response);
        }
    }


    private void loadAppointmentForm(
    		HttpServletRequest request,
    		HttpServletResponse response)
    				throws ServletException, IOException {
    	
    	// Pass the selected patient ID to the JSP.
    	String patientIdParam = request.getParameter("patientId");

    	Integer selectedPatientId = null;
    	
    	if (patientIdParam != null && !patientIdParam.isBlank()) {
    		try {
    			int id = Integer.parseInt(patientIdParam);
    			
    			if (id > 0) {
    				selectedPatientId = id;
    			}
    		} catch (NumberFormatException e) {
    			response.sendError(
    					HttpServletResponse.SC_BAD_REQUEST,
    					"Invalid patient ID."
    					);
    			return;
    		}
    	}
    	
    	request.setAttribute("selectedPatientId", selectedPatientId);
    	
    	try {
    		request.setAttribute(
    				"patients",
    				appointmentDAO.getPatientsForDropdown()
    				);
    		
    		request.setAttribute(
    				"departments",
    				appointmentDAO.getDepartmentsForDropdown()
    				);
    		
    		// Retained for compatibility with existing JSP code.
    		request.setAttribute(
    				"doctors",
    				appointmentDAO.getDoctorsForDropdown()
    				);
    		
    	} catch (SQLException e) {
    		throw new ServletException(
    				"Unable to load patient, department, and doctor lists.",
    				e
    				);
    	}
    	
    	request.getRequestDispatcher(
    			"/WEB-INF/views/appointment-form.jsp"
    			).forward(request, response);
    }
     
    private void loadDoctorsByDepartment(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        String departmentIdParam =
                request.getParameter("departmentId");

        if (departmentIdParam == null
                || departmentIdParam.isBlank()) {

            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("[]");
            return;
        }

        try {
            int departmentId = Integer.parseInt(departmentIdParam);

            List<String[]> doctors =
                    appointmentDAO.getDoctorsByDepartment(departmentId);

            StringBuilder json = new StringBuilder("[");

            for (int i = 0; i < doctors.size(); i++) {
                String[] doctor = doctors.get(i);

                if (i > 0) {
                    json.append(",");
                }

                json.append("{")
                    .append("\"id\":").append(doctor[0]).append(",")
                    .append("\"name\":\"")
                    .append(escapeJson(doctor[1])).append("\",")
                    .append("\"specialization\":\"")
                    .append(escapeJson(doctor[2])).append("\"")
                    .append("}");
            }

            json.append("]");

            response.getWriter().write(json.toString());

        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("[]");

        } catch (SQLException e) {
            throw new ServletException(
                "Unable to load doctors for department.", e
            );
        }
    }

    private void loadAppointmentSlots(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        String doctorValue = request.getParameter("doctorId");
        String dateValue = request.getParameter("date");

        if (doctorValue == null || doctorValue.isBlank()
                || dateValue == null || dateValue.isBlank()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("[]");
            return;
        }

        try {
            int doctorId = Integer.parseInt(doctorValue);
            LocalDate date = LocalDate.parse(dateValue);

            List<String[]> schedules =
                    appointmentDAO.getScheduleTimesForDoctorOnDate(
                            doctorId, date);

            if (schedules == null || schedules.isEmpty()) {
                response.getWriter().write("[]");
                return;
            }

            // Collect slots from every schedule period.
            Set<String> allSlots = new TreeSet<>();

            for (String[] schedule : schedules) {
                if (schedule == null || schedule.length < 2
                        || schedule[0] == null || schedule[1] == null) {
                    continue;
                }

                LocalTime startTime = LocalTime.parse(schedule[0]);
                LocalTime endTime = LocalTime.parse(schedule[1]);

                if (startTime.isBefore(endTime)) {
                    allSlots.addAll(
                            appointmentDAO.generate15MinuteSlots(
                                    startTime, endTime));
                }
            }

            // Retrieve existing bookings for this doctor and date.
            List<String> bookedTimes =
                    appointmentDAO.getBookedAppointmentTimesForDoctorOnDate(
                            doctorId, date);

            Set<String> bookedSlots = new HashSet<>(bookedTimes);

            // Remove times that are already booked.
            allSlots.removeIf(slot ->
                    bookedSlots.contains(slot.substring(0, 5)));

            StringBuilder json = new StringBuilder("[");
            boolean first = true;

            for (String slot : allSlots) {
                if (!first) {
                    json.append(",");
                }

                json.append("\"")
                    .append(escapeJson(slot))
                    .append("\"");

                first = false;
            }

            json.append("]");
            response.getWriter().write(json.toString());

        } catch (NumberFormatException
                | java.time.format.DateTimeParseException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("[]");

        } catch (SQLException e) {
            throw new ServletException(
                    "Unable to retrieve the doctor's available slots.", e);
        }
    }

    private String escapeJson(String value) {
        if (value == null) {
            return "";
        }

        return value.replace("\\", "\\\\")
                    .replace("\"", "\\\"")
                    .replace("\n", "\\n")
                    .replace("\r", "\\r")
                    .replace("\t", "\\t");
    }

    private boolean hasRole(
            HttpServletRequest request,
            String requiredRole) {

        HttpSession session = request.getSession(false);

        if (session == null) {
            return false;
        }

        String role = (String) session.getAttribute("role");

        return role != null
                && requiredRole.equalsIgnoreCase(role);
    }

    private boolean hasAnyRole(
            HttpServletRequest request,
            String... allowedRoles) {

        HttpSession session = request.getSession(false);

        if (session == null) {
            return false;
        }

        String role = (String) session.getAttribute("role");

        if (role == null) {
            return false;
        }

        for (String allowedRole : allowedRoles) {
            if (allowedRole.equalsIgnoreCase(role)) {
                return true;
            }
        }

        return false;
    }
}
