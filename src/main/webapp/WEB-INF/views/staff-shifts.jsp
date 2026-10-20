
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.hospital.dao.StaffShiftScheduleDAO.ShiftRecord" %>

<%
    List<ShiftRecord> shifts =
        (List<ShiftRecord>) request.getAttribute("shifts");

    Object roleObject = session.getAttribute("role");
    String role = roleObject == null
        ? "" : roleObject.toString();

    boolean isAdmin = "ADMIN".equalsIgnoreCase(role);

    String message = request.getParameter("message");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Staff Shift Schedules | CityCare Hospital</title>

    <style>
        * { box-sizing: border-box; }
        body {
            margin: 0;
            font-family: Arial, sans-serif;
            background: #f4f7fb;
            color: #263449;
        }
        .container {
            max-width: 1200px;
            margin: 35px auto;
            padding: 24px;
        }
        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 12px;
            flex-wrap: wrap;
            margin-bottom: 22px;
        }
        h1 { margin: 0 0 8px; font-size: 27px; }
        .subtitle { color: #69788c; }
        .button {
            display: inline-block;
            padding: 10px 15px;
            border-radius: 7px;
            text-decoration: none;
            border: 0;
            cursor: pointer;
            font-size: 14px;
        }
        .primary { background: #1769aa; color: white; }
        .secondary { background: #e7edf5; color: #263449; }
        .danger { background: #fee2e2; color: #991b1b; }
        .card {
            background: white;
            border-radius: 12px;
            padding: 20px;
            box-shadow: 0 3px 15px #1b355010;
            overflow-x: auto;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            min-width: 900px;
        }
        th, td {
            text-align: left;
            padding: 13px 11px;
            border-bottom: 1px solid #e8edf3;
        }
        th {
            background: #f7f9fc;
            color: #526176;
            font-size: 12px;
            text-transform: uppercase;
        }
        .badge {
            padding: 5px 9px;
            border-radius: 20px;
            font-size: 12px;
        }
        .active { background: #dcfce7; color: #166534; }
        .inactive { background: #fee2e2; color: #991b1b; }
        .actions { display: flex; gap: 7px; flex-wrap: wrap; }
        .notice {
            padding: 12px;
            margin-bottom: 15px;
            border-radius: 7px;
            background: #dcfce7;
            color: #166534;
        }
        .empty { padding: 25px; text-align: center; color: #69788c; }
    </style>
</head>

<body>
<div class="container">

    <div class="header">
        <div>
            <h1>Staff Shift Schedules</h1>
            <div class="subtitle">
                CityCare Hospital — Staff duty schedule management
            </div>
        </div>

        <div>
            <a class="button secondary"
               href="${pageContext.request.contextPath}/dashboard">
                Dashboard
            </a>

            <% if (isAdmin) { %>
                <a class="button primary"
                   href="${pageContext.request.contextPath}/staff-shifts?action=new">
                    + Add Shift
                </a>
            <% } %>
        </div>
    </div>

    <% if ("success".equals(message)) { %>
        <div class="notice">Shift schedule operation completed.</div>
    <% } %>

    <div class="card">
        <table>
            <thead>
            <tr>
                <th>ID</th>
                <th>Staff Member</th>
                <th>Designation</th>
                <th>Day</th>
                <th>Start</th>
                <th>End</th>
                <th>Effective From</th>
                <th>Effective Until</th>
                <th>Status</th>
                <% if (isAdmin) { %><th>Actions</th><% } %>
            </tr>
            </thead>

            <tbody>
            <% if (shifts == null || shifts.isEmpty()) { %>
                <tr>
                    <td colspan="<%= isAdmin ? 10 : 9 %>" class="empty">
                        No shift schedules found.
                    </td>
                </tr>
            <% } else {
                for (ShiftRecord shift : shifts) { %>
                    <tr>
                        <td><%= shift.getShiftId() %></td>
                        <td><%= shift.getStaffName() == null
                                ? "-" : shift.getStaffName() %></td>
                        <td><%= shift.getDesignation() == null
                                ? "-" : shift.getDesignation() %></td>
                        <td><%= shift.getDayOfWeek() %></td>
                        <td><%= shift.getShiftStart() %></td>
                        <td><%= shift.getShiftEnd() %></td>
                        <td><%= shift.getEffectiveFrom() %></td>
                        <td><%= shift.getEffectiveUntil() == null
                                ? "No end date" : shift.getEffectiveUntil() %></td>
                        <td>
                            <span class="badge <%= "ACTIVE".equals(shift.getShiftStatus())
                                    ? "active" : "inactive" %>">
                                <%= shift.getShiftStatus() %>
                            </span>
                        </td>

                        <% if (isAdmin) { %>
                        <td>
                            <div class="actions">
                                <a class="button secondary"
                                   href="${pageContext.request.contextPath}/staff-shifts?action=edit&id=<%= shift.getShiftId() %>">
                                    Edit
                                </a>

                                <form method="post"
                                      action="${pageContext.request.contextPath}/staff-shifts"
                                      onsubmit="return confirm('Change this shift status?');">
                                    <input type="hidden" name="action" value="status">
                                    <input type="hidden" name="shiftId"
                                           value="<%= shift.getShiftId() %>">
                                    <input type="hidden" name="shiftStatus"
                                           value="<%= "ACTIVE".equals(shift.getShiftStatus())
                                               ? "INACTIVE" : "ACTIVE" %>">
                                    <button class="button secondary" type="submit">
                                        <%= "ACTIVE".equals(shift.getShiftStatus())
                                            ? "Deactivate" : "Activate" %>
                                    </button>
                                </form>

                                <form method="post"
                                      action="${pageContext.request.contextPath}/staff-shifts"
                                      onsubmit="return confirm('Permanently delete this shift?');">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="shiftId"
                                           value="<%= shift.getShiftId() %>">
                                    <button class="button danger" type="submit">
                                        Delete
                                    </button>
                                </form>
                            </div>
                        </td>
                        <% } %>
                    </tr>
            <%  }
               } %>
            </tbody>
        </table>
    </div>

</div>
</body>
</html>
