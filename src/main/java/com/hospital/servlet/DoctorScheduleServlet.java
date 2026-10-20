
package com.hospital.servlet;

import com.hospital.dao.DoctorScheduleDAO;
import com.hospital.model.Doctor;
import com.hospital.model.DoctorSchedule;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Date;
import java.sql.SQLException;
import java.sql.Time;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.Arrays;

@WebServlet("/doctor-schedules")
public class DoctorScheduleServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final DoctorScheduleDAO scheduleDAO =
            new DoctorScheduleDAO();

    private static final String LIST_PAGE =
            "/WEB-INF/views/doctor-schedules.jsp";

    private static final String FORM_PAGE =
            "/WEB-INF/views/doctor-schedule-form.jsp";

    // ---------------------------------------------------------
    // GET: List schedules, display add form, display edit form
    // ---------------------------------------------------------

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("role") == null) {
            response.sendRedirect(
                    request.getContextPath() + "/login");
            return;
        }

        String role = session.getAttribute("role").toString();

        if (!isAllowedRole(role)) {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "You are not allowed to access doctor schedules.");
            return;
        }

        String action = clean(request.getParameter("action"));

        try {
            // Display the form for a new schedule.
            if ("new".equals(action)) {

                if (!requireAdmin(role, response)) {
                    return;
                }

                loadFormData(request);

                request.getRequestDispatcher(FORM_PAGE)
                        .forward(request, response);
                return;
            }

            // Display an existing schedule for editing.
            if ("edit".equals(action)) {

                if (!requireAdmin(role, response)) {
                    return;
                }

                int scheduleId = parseId(
                        request.getParameter("scheduleId"));

                DoctorSchedule schedule =
                        scheduleDAO.getScheduleById(scheduleId);

                if (schedule == null) {
                    response.sendError(
                            HttpServletResponse.SC_NOT_FOUND,
                            "Doctor schedule not found.");
                    return;
                }

                request.setAttribute("schedule", schedule);
                loadFormData(request);

                request.getRequestDispatcher(FORM_PAGE)
                        .forward(request, response);
                return;
            }

            // Default action: display the schedule list.
            List<DoctorSchedule> schedules =
                    scheduleDAO.getAllSchedules();

            request.setAttribute("schedules", schedules);

            request.getRequestDispatcher(LIST_PAGE)
                    .forward(request, response);

        } catch (IllegalArgumentException e) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    e.getMessage());

        } catch (SQLException e) {
            throw new ServletException(
                    "Unable to load doctor schedules.", e);
        }
    }

    // ---------------------------------------------------------
    // POST: Create, update, delete, activate/deactivate
    // ---------------------------------------------------------

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("role") == null) {
            response.sendRedirect(
                    request.getContextPath() + "/login");
            return;
        }

        String role = session.getAttribute("role").toString();

        if (!isAllowedRole(role)) {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "You are not allowed to access doctor schedules.");
            return;
        }

        String action = clean(request.getParameter("action"));

        try {
            // ADMIN and RECEPTIONIST may change schedule status.
            if ("status".equals(action)) {

                if (!"ADMIN".equals(role)
                        && !"RECEPTIONIST".equals(role)) {

                    response.sendError(
                            HttpServletResponse.SC_FORBIDDEN,
                            "You cannot change schedule status.");
                    return;
                }

                int scheduleId = parseId(
                        request.getParameter("scheduleId"));

                String status =
                        clean(request.getParameter("scheduleStatus"));

                if (!"ACTIVE".equals(status)
                        && !"INACTIVE".equals(status)) {

                    response.sendError(
                            HttpServletResponse.SC_BAD_REQUEST,
                            "Invalid schedule status.");
                    return;
                }

                if (scheduleDAO.getScheduleById(scheduleId) == null) {
                    response.sendError(
                            HttpServletResponse.SC_NOT_FOUND,
                            "Doctor schedule not found.");
                    return;
                }

                scheduleDAO.updateScheduleStatus(scheduleId, status);

                response.sendRedirect(
                        request.getContextPath()
                                + "/doctor-schedules?statusUpdated=1");
                return;
            }

            // All other modifications require ADMIN.
            if (!"ADMIN".equals(role)) {
                response.sendError(
                        HttpServletResponse.SC_FORBIDDEN,
                        "Only ADMIN can manage doctor schedules.");
                return;
            }

            // Delete an existing schedule.
            if ("delete".equals(action)) {

                int scheduleId = parseId(
                        request.getParameter("scheduleId"));

                if (scheduleDAO.getScheduleById(scheduleId) == null) {
                    response.sendError(
                            HttpServletResponse.SC_NOT_FOUND,
                            "Doctor schedule not found.");
                    return;
                }

                scheduleDAO.deleteSchedule(scheduleId);

                response.sendRedirect(
                        request.getContextPath()
                                + "/doctor-schedules?deleted=1");
                return;
            }

            boolean creating = "create".equals(action);
            boolean updating = "update".equals(action);

            if (!creating && !updating) {
                response.sendError(
                        HttpServletResponse.SC_BAD_REQUEST,
                        "Unknown schedule operation.");
                return;
            }

            DoctorSchedule schedule = readSchedule(request);

            if (updating) {
                // Editing still updates exactly one schedule row.
                schedule.setScheduleId(
                        parseId(request.getParameter("scheduleId")));

                validateSchedule(schedule);

                if (!isActiveDoctor(schedule.getDoctorId())) {
                    throw new IllegalArgumentException(
                            "Select an active doctor.");
                }

                boolean saved =
                        scheduleDAO.updateSchedule(schedule);

                if (!saved) {
                    response.sendError(
                            HttpServletResponse.SC_NOT_FOUND,
                            "The schedule could not be updated.");
                    return;
                }

            } else {
                // Creating allows multiple selected weekdays.
                String[] selectedDays =
                        request.getParameterValues("dayOfWeek");

                if (selectedDays == null || selectedDays.length == 0) {
                    throw new IllegalArgumentException(
                            "Select at least one weekday.");
                }

                // Validate common schedule details first.
                validateSchedule(schedule);

                if (!isActiveDoctor(schedule.getDoctorId())) {
                    throw new IllegalArgumentException(
                            "Select an active doctor.");
                }

                List<DoctorSchedule> schedulesToSave =
                        new java.util.ArrayList<>();

                for (String day : selectedDays) {
                    String selectedDay = clean(day).toUpperCase();

                    schedule.setDayOfWeek(selectedDay);
                    validateSchedule(schedule);

                    // Make a separate model object for each weekday.
                    DoctorSchedule daySchedule =
                            new DoctorSchedule();

                    daySchedule.setDoctorId(schedule.getDoctorId());
                    daySchedule.setDayOfWeek(selectedDay);
                    daySchedule.setStartTime(schedule.getStartTime());
                    daySchedule.setEndTime(schedule.getEndTime());
                    daySchedule.setValidFrom(schedule.getValidFrom());
                    daySchedule.setValidUntil(schedule.getValidUntil());
                    daySchedule.setScheduleStatus(
                            schedule.getScheduleStatus());

                    schedulesToSave.add(daySchedule);
                }

                // Save all weekdays in one transaction.
                boolean saved =
                        scheduleDAO.addSchedules(schedulesToSave);

                if (!saved) {
                    response.sendError(
                            HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                            "The schedules could not be saved.");
                    return;
                }
            }

            response.sendRedirect(
                    request.getContextPath()
                            + "/doctor-schedules?saved=1");

        } catch (IllegalArgumentException e) {

            // Preserve form values and show the validation message.
            request.setAttribute("error", e.getMessage());

            try {
                loadFormData(request);

                String currentAction = clean(
                        request.getParameter("action"));

                if ("update".equals(currentAction)) {
                    String idValue =
                            clean(request.getParameter("scheduleId"));

                    int scheduleId = parseId(idValue);
                    request.setAttribute("formAction", "update");
                    request.setAttribute("submittedScheduleId",
                            scheduleId);
                } else {
                    request.setAttribute("formAction", "create");
                }

                // Preserve submitted fields, even if invalid.
                request.setAttribute("submittedDoctorId",
                        clean(request.getParameter("doctorId")));
                request.setAttribute("submittedDayOfWeek",
                        clean(request.getParameter("dayOfWeek")));
                String[] days = request.getParameterValues("dayOfWeek");

                request.setAttribute(
                        "submittedDays",
                        days == null ? List.of() : Arrays.asList(days)
                );
                request.setAttribute("submittedStartTime",
                        clean(request.getParameter("startTime")));
                request.setAttribute("submittedEndTime",
                        clean(request.getParameter("endTime")));
                request.setAttribute("submittedValidFrom",
                        clean(request.getParameter("validFrom")));
                request.setAttribute("submittedValidUntil",
                        clean(request.getParameter("validUntil")));
                request.setAttribute("submittedScheduleStatus",
                        clean(request.getParameter("scheduleStatus")));

                request.getRequestDispatcher(FORM_PAGE)
                        .forward(request, response);

            } catch (SQLException sqlException) {
                throw new ServletException(
                        "Unable to reload the schedule form.",
                        sqlException);
            }

        } catch (SQLException e) {
            throw new ServletException(
                    "Unable to save doctor schedule.", e);
        }
    }

    // ---------------------------------------------------------
    // Load dropdown data
    // ---------------------------------------------------------

    private boolean isSubmittedDay(String day, String[] submittedDays) {
        if (submittedDays == null) {
            return false;
        }

        for (String submittedDay : submittedDays) {
            if (day.equals(submittedDay)) {
                return true;
            }
        }

        return false;
    }
    
    private void loadFormData(HttpServletRequest request)
            throws SQLException {

        List<Doctor> doctors = scheduleDAO.getActiveDoctors();
        request.setAttribute("doctors", doctors);

        request.setAttribute("weekdays", List.of(
                "MONDAY", "TUESDAY", "WEDNESDAY",
                "THURSDAY", "FRIDAY", "SATURDAY", "SUNDAY"
        ));
    }

    private boolean isActiveDoctor(int doctorId)
            throws SQLException {

        List<Doctor> doctors = scheduleDAO.getActiveDoctors();

        for (Doctor doctor : doctors) {
            if (doctor.getDoctorId() == doctorId) {
                return true;
            }
        }

        return false;
    }

    // ---------------------------------------------------------
    // Read submitted form values
    // ---------------------------------------------------------

    private DoctorSchedule readSchedule(
            HttpServletRequest request) {

        DoctorSchedule schedule = new DoctorSchedule();

        schedule.setDoctorId(
                parseId(request.getParameter("doctorId")));

        schedule.setDayOfWeek(
                clean(request.getParameter("dayOfWeek")));

        schedule.setStartTime(
                parseTime(request.getParameter("startTime"),
                        "start time"));

        schedule.setEndTime(
                parseTime(request.getParameter("endTime"),
                        "end time"));

        schedule.setValidFrom(
                parseDate(request.getParameter("validFrom"),
                        "valid from"));

        String validUntil =
                clean(request.getParameter("validUntil"));

        schedule.setValidUntil(
                validUntil.isEmpty()
                        ? null
                        : parseDate(validUntil, "valid until"));

        String status =
                clean(request.getParameter("scheduleStatus"));

        schedule.setScheduleStatus(
                status.isEmpty() ? "ACTIVE" : status);

        return schedule;
    }

    // ---------------------------------------------------------
    // Validate schedule values
    // ---------------------------------------------------------

    private void validateSchedule(DoctorSchedule schedule) {

        String[] validDays = {
                "MONDAY", "TUESDAY", "WEDNESDAY",
                "THURSDAY", "FRIDAY", "SATURDAY", "SUNDAY"
        };

        boolean validDay = false;

        for (String day : validDays) {
            if (day.equals(schedule.getDayOfWeek())) {
                validDay = true;
                break;
            }
        }

        if (!validDay) {
            throw new IllegalArgumentException(
                    "Select a valid day of the week.");
        }

        if (schedule.getStartTime() == null
                || schedule.getEndTime() == null
                || !schedule.getEndTime().after(
                        schedule.getStartTime())) {

            throw new IllegalArgumentException(
                    "End time must be later than start time.");
        }

        if (schedule.getValidFrom() == null) {
            throw new IllegalArgumentException(
                    "Select a valid start date.");
        }

        if (schedule.getValidUntil() != null
                && schedule.getValidUntil().before(
                        schedule.getValidFrom())) {

            throw new IllegalArgumentException(
                    "Valid until cannot be earlier than valid from.");
        }

        if (!"ACTIVE".equals(schedule.getScheduleStatus())
                && !"INACTIVE".equals(schedule.getScheduleStatus())) {

            throw new IllegalArgumentException(
                    "Select a valid schedule status.");
        }

        if (schedule.getDoctorId() <= 0) {
            throw new IllegalArgumentException(
                    "Select a doctor.");
        }
    }

    // ---------------------------------------------------------
    // Parse times, dates and IDs safely
    // ---------------------------------------------------------

    private Time parseTime(String value, String fieldName) {
        try {
            return Time.valueOf(LocalTime.parse(clean(value)));
        } catch (IllegalArgumentException e) {
            throw new IllegalArgumentException(
                    "Enter a valid " + fieldName + ".");
        }
    }

    private Date parseDate(String value, String fieldName) {
        try {
            return Date.valueOf(LocalDate.parse(clean(value)));
        } catch (IllegalArgumentException e) {
            throw new IllegalArgumentException(
                    "Enter a valid " + fieldName + " date.");
        }
    }

    private int parseId(String value) {
        try {
            int id = Integer.parseInt(clean(value));

            if (id <= 0) {
                throw new NumberFormatException();
            }

            return id;

        } catch (NumberFormatException e) {
            throw new IllegalArgumentException(
                    "A valid ID is required.");
        }
    }

    private String clean(String value) {
        return value == null ? "" : value.trim();
    }

    // ---------------------------------------------------------
    // Role-based access
    // ---------------------------------------------------------

    private boolean isAllowedRole(String role) {
        return "ADMIN".equals(role)
                || "DOCTOR".equals(role)
                || "STAFF".equals(role)
                || "RECEPTIONIST".equals(role);
    }

    private boolean requireAdmin(String role,
                                 HttpServletResponse response)
            throws IOException {

        if (!"ADMIN".equals(role)) {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Only ADMIN can create or edit schedules.");
            return false;
        }

        return true;
    }
}
