
package com.hospital.servlet;

import com.hospital.dao.StaffShiftScheduleDAO;
import com.hospital.dao.StaffShiftScheduleDAO.ShiftRecord;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.Set;

@WebServlet("/staff-shifts")
public class StaffShiftScheduleServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final StaffShiftScheduleDAO dao =
            new StaffShiftScheduleDAO();

    private static final Set<String> ROLES =
            Set.of("ADMIN", "DOCTOR", "STAFF", "RECEPTIONIST");

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        if (!checkAccess(request, response, false)) {
            return;
        }

        String action = request.getParameter("action");

        try {
            if ("new".equals(action)) {
                showForm(request, response, null);
                return;
            }

            if ("edit".equals(action)) {
                int id = Integer.parseInt(
                        request.getParameter("id"));

                ShiftRecord shift = dao.getShiftById(id);

                if (shift == null) {
                    response.sendError(
                            HttpServletResponse.SC_NOT_FOUND,
                            "Shift schedule not found.");
                    return;
                }

                showForm(request, response, shift);
                return;
            }

            List<ShiftRecord> shifts = dao.getAllShifts();

            request.setAttribute("shifts", shifts);
            request.getRequestDispatcher(
                    "/WEB-INF/views/staff-shifts.jsp")
                    .forward(request, response);

        } catch (NumberFormatException e) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Invalid shift ID.");
        } catch (SQLException e) {
            throw new ServletException(
                    "Unable to load staff shift schedules.", e);
        }
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        if (!checkAccess(request, response, true)) {
            return;
        }

        request.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");

        try {
            switch (action == null ? "" : action) {

                case "add":
                    dao.addShift(readShift(request, false));
                    break;

                case "update":
                    dao.updateShift(readShift(request, true));
                    break;

                case "status":
                    int statusId = Integer.parseInt(
                            request.getParameter("shiftId"));

                    String status =
                            request.getParameter("shiftStatus");

                    if (!"ACTIVE".equals(status)
                            && !"INACTIVE".equals(status)) {
                        response.sendError(
                                HttpServletResponse.SC_BAD_REQUEST,
                                "Invalid shift status.");
                        return;
                    }

                    dao.updateShiftStatus(statusId, status);
                    break;

                case "delete":
                    int deleteId = Integer.parseInt(
                            request.getParameter("shiftId"));

                    dao.deleteShift(deleteId);
                    break;

                default:
                    response.sendError(
                            HttpServletResponse.SC_BAD_REQUEST,
                            "Invalid action.");
                    return;
            }

            response.sendRedirect(
                    request.getContextPath()
                            + "/staff-shifts?message=success");

        } catch (NumberFormatException
                 | java.time.DateTimeException e) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Invalid date, time, or shift ID.");
        } catch (IllegalArgumentException e) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Invalid shift information.");
        } catch (SQLException e) {
            throw new ServletException(
                    "Unable to save staff shift schedule.", e);
        }
    }

    private ShiftRecord readShift(
            HttpServletRequest request, boolean updating) {

        ShiftRecord shift = new ShiftRecord();

        if (updating) {
            shift.setShiftId(Integer.parseInt(
                    request.getParameter("shiftId")));
        }

        shift.setStaffId(Integer.parseInt(
                request.getParameter("staffId")));

        String day = request.getParameter("dayOfWeek");
        Set<String> validDays = Set.of(
                "MONDAY", "TUESDAY", "WEDNESDAY",
                "THURSDAY", "FRIDAY", "SATURDAY", "SUNDAY");

        if (day == null || !validDays.contains(day)) {
            throw new IllegalArgumentException("Invalid day.");
        }

        shift.setDayOfWeek(day);

        LocalTime start = LocalTime.parse(
                request.getParameter("shiftStart"));
        LocalTime end = LocalTime.parse(
                request.getParameter("shiftEnd"));

        if (!start.isBefore(end)) {
            throw new IllegalArgumentException(
                    "Shift end must be after shift start.");
        }

        shift.setShiftStart(start);
        shift.setShiftEnd(end);

        LocalDate effectiveFrom = LocalDate.parse(
                request.getParameter("effectiveFrom"));

        String untilValue =
                request.getParameter("effectiveUntil");

        LocalDate effectiveUntil =
                (untilValue == null || untilValue.isBlank())
                        ? null : LocalDate.parse(untilValue);

        if (effectiveUntil != null
                && effectiveUntil.isBefore(effectiveFrom)) {
            throw new IllegalArgumentException(
                    "End date cannot precede start date.");
        }

        shift.setEffectiveFrom(effectiveFrom);
        shift.setEffectiveUntil(effectiveUntil);

        String status = request.getParameter("shiftStatus");

        if (!"ACTIVE".equals(status)
                && !"INACTIVE".equals(status)) {
            throw new IllegalArgumentException(
                    "Invalid shift status.");
        }

        shift.setShiftStatus(status);

        return shift;
    }

    private void showForm(
            HttpServletRequest request,
            HttpServletResponse response,
            ShiftRecord shift)
            throws ServletException, IOException, SQLException {

        request.setAttribute("shift", shift);
        request.setAttribute("staffList", dao.getActiveStaff());

        request.getRequestDispatcher(
                "/WEB-INF/views/staff-shift-form.jsp")
                .forward(request, response);
    }

    private boolean checkAccess(
            HttpServletRequest request,
            HttpServletResponse response,
            boolean adminOnly) throws IOException {

        HttpSession session = request.getSession(false);

        if (session == null
                || session.getAttribute("userId") == null) {
            response.sendRedirect(
                    request.getContextPath() + "/login");
            return false;
        }

        Object roleValue = session.getAttribute("role");

        if (roleValue == null) {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "User role is missing.");
            return false;
        }

        String role = roleValue.toString().toUpperCase();

        if (!ROLES.contains(role)
                || (adminOnly && !"ADMIN".equals(role))) {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "You do not have permission to perform this action.");
            return false;
        }

        return true;
    }
}
