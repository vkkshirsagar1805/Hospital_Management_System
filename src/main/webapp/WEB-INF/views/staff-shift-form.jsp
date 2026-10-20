
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.hospital.dao.StaffShiftScheduleDAO.ShiftRecord" %>

<%
    ShiftRecord shift =
        (ShiftRecord) request.getAttribute("shift");

    List<ShiftRecord> staffList =
        (List<ShiftRecord>) request.getAttribute("staffList");

    boolean editing = shift != null;

    Object roleObject = session.getAttribute("role");
    String role = roleObject == null
        ? "" : roleObject.toString();

    if (!"ADMIN".equalsIgnoreCase(role)) {
        response.sendError(
            jakarta.servlet.http.HttpServletResponse.SC_FORBIDDEN,
            "Only administrators can manage shift schedules.");
        return;
    }

    String[] days = {
        "MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY",
        "FRIDAY", "SATURDAY", "SUNDAY"
    };
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title><%= editing ? "Edit" : "Add" %> Staff Shift | CityCare Hospital</title>

    <style>
        * { box-sizing: border-box; }
        body {
            margin: 0;
            font-family: Arial, sans-serif;
            background: #f4f7fb;
            color: #263449;
        }
        .container {
            max-width: 750px;
            margin: 35px auto;
            padding: 20px;
        }
        .card {
            background: white;
            padding: 28px;
            border-radius: 12px;
            box-shadow: 0 3px 15px #1b355010;
        }
        h1 { margin-top: 0; }
        .subtitle { color: #69788c; margin-bottom: 25px; }
        .form-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 18px;
        }
        .field { display: flex; flex-direction: column; gap: 7px; }
        .full { grid-column: 1 / -1; }
        label { font-size: 14px; font-weight: bold; }
        input, select {
            width: 100%;
            padding: 11px;
            border: 1px solid #cbd5e1;
            border-radius: 7px;
            font-size: 14px;
            background: white;
        }
        .actions { display: flex; gap: 10px; margin-top: 25px; }
        .button {
            padding: 11px 17px;
            border-radius: 7px;
            border: 0;
            text-decoration: none;
            cursor: pointer;
            font-size: 14px;
        }
        .primary { background: #1769aa; color: white; }
        .secondary { background: #e7edf5; color: #263449; }
        @media (max-width: 600px) {
            .form-grid { grid-template-columns: 1fr; }
            .full { grid-column: auto; }
        }
    </style>
</head>

<body>
<div class="container">
    <div class="card">
        <h1><%= editing ? "Edit Shift Schedule" : "Add Shift Schedule" %></h1>
        <div class="subtitle">
            CityCare Hospital — Staff duty planning
        </div>

        <form method="post"
              action="${pageContext.request.contextPath}/staff-shifts">

            <input type="hidden" name="action"
                   value="<%= editing ? "update" : "add" %>">

            <% if (editing) { %>
                <input type="hidden" name="shiftId"
                       value="<%= shift.getShiftId() %>">
            <% } %>

            <div class="form-grid">

                <div class="field full">
                    <label for="staffId">Staff Member</label>
                    <select id="staffId" name="staffId" required>
                        <option value="">Select staff member</option>

                        <% if (staffList != null) {
                            for (ShiftRecord staff : staffList) {
                                boolean selected = editing
                                    && staff.getStaffId() == shift.getStaffId();
                        %>
                            <option value="<%= staff.getStaffId() %>"
                                <%= selected ? "selected" : "" %>>
                                <%= staff.getStaffName() %>
                                <% if (staff.getDesignation() != null) { %>
                                    — <%= staff.getDesignation() %>
                                <% } %>
                            </option>
                        <%  }
                           } %>
                    </select>
                </div>

                <div class="field">
                    <label for="dayOfWeek">Day of Week</label>
                    <select id="dayOfWeek" name="dayOfWeek" required>
                        <% for (String day : days) { %>
                            <option value="<%= day %>"
                                <%= editing && day.equals(shift.getDayOfWeek())
                                    ? "selected" : "" %>>
                                <%= day %>
                            </option>
                        <% } %>
                    </select>
                </div>

                <div class="field">
                    <label for="shiftStatus">Status</label>
                    <select id="shiftStatus" name="shiftStatus" required>
                        <option value="ACTIVE"
                            <%= !editing || "ACTIVE".equals(shift.getShiftStatus())
                                ? "selected" : "" %>>
                            ACTIVE
                        </option>
                        <option value="INACTIVE"
                            <%= editing && "INACTIVE".equals(shift.getShiftStatus())
                                ? "selected" : "" %>>
                            INACTIVE
                        </option>
                    </select>
                </div>

                <div class="field">
                    <label for="shiftStart">Shift Start</label>
                    <input type="time" id="shiftStart" name="shiftStart"
                           required
                           value="<%= editing ? shift.getShiftStart() : "" %>">
                </div>

                <div class="field">
                    <label for="shiftEnd">Shift End</label>
                    <input type="time" id="shiftEnd" name="shiftEnd"
                           required
                           value="<%= editing ? shift.getShiftEnd() : "" %>">
                </div>

                <div class="field">
                    <label for="effectiveFrom">Effective From</label>
                    <input type="date" id="effectiveFrom"
                           name="effectiveFrom" required
                           value="<%= editing
                               ? shift.getEffectiveFrom()
                               : java.time.LocalDate.now() %>">
                </div>

                <div class="field">
                    <label for="effectiveUntil">Effective Until (Optional)</label>
                    <input type="date" id="effectiveUntil"
                           name="effectiveUntil"
                           value="<%= editing && shift.getEffectiveUntil() != null
                               ? shift.getEffectiveUntil() : "" %>">
                </div>

            </div>

            <div class="actions">
                <button class="button primary" type="submit">
                    <%= editing ? "Save Changes" : "Create Schedule" %>
                </button>

                <a class="button secondary"
                   href="${pageContext.request.contextPath}/staff-shifts">
                    Cancel
                </a>
            </div>
        </form>
    </div>
</div>
</body>
</html>
