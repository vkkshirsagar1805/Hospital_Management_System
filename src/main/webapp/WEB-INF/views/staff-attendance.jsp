<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.hospital.model.StaffAttendance" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.util.List" %>

<%
    StaffAttendance attendance =
            (StaffAttendance) request.getAttribute("attendance");

    Boolean adminFlag = (Boolean) request.getAttribute("isAdmin");
    boolean isAdmin = Boolean.TRUE.equals(adminFlag);

    @SuppressWarnings("unchecked")
    List<StaffAttendance> attendanceRecords =
            (List<StaffAttendance>) request.getAttribute("attendanceRecords");

    java.time.LocalDate attendanceDate =
            (java.time.LocalDate) request.getAttribute("attendanceDate");

    String message = (String) session.getAttribute("attendanceMessage");
    session.removeAttribute("attendanceMessage");

    DateTimeFormatter timeFormat =
            DateTimeFormatter.ofPattern("hh:mm a");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Staff Attendance | CityCare Hospital</title>

    <style>
        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            font-family: Arial, sans-serif;
            background: #f3f6fb;
            color: #243047;
        }

        header {
            background: #123b68;
            color: white;
            padding: 22px 7%;
        }

        header h1 {
            margin: 0;
            font-size: 24px;
        }

        header p {
            margin: 7px 0 0;
            color: #dce9f8;
        }

        main {
            max-width: 1200px;
            margin: 35px auto;
            padding: 0 18px;
        }

        .card {
            background: white;
            border-radius: 14px;
            padding: 28px;
            margin-bottom: 22px;
            box-shadow: 0 5px 22px rgba(20, 45, 80, 0.08);
        }

        .card h2 {
            margin-top: 0;
            font-size: 21px;
        }

        .date {
            color: #68758a;
            margin-bottom: 24px;
        }

        .status {
            display: inline-block;
            padding: 7px 12px;
            border-radius: 20px;
            background: #e8f3ff;
            color: #14559a;
            font-weight: bold;
            font-size: 13px;
        }

        .details {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 16px;
            margin-top: 24px;
        }

        .detail {
            background: #f7f9fc;
            border-radius: 10px;
            padding: 18px;
        }

        .detail span {
            display: block;
            color: #68758a;
            font-size: 13px;
            margin-bottom: 9px;
        }

        .detail strong {
            font-size: 19px;
        }

        .message {
            padding: 13px 15px;
            border-radius: 8px;
            background: #e8f7ed;
            color: #176534;
            margin-bottom: 20px;
        }

        .actions {
            display: flex;
            flex-wrap: wrap;
            gap: 12px;
            margin-top: 25px;
        }

        button {
            border: 0;
            border-radius: 8px;
            padding: 13px 22px;
            font-size: 15px;
            font-weight: bold;
            cursor: pointer;
        }

        .check-in {
            background: #137a4b;
            color: white;
        }

        .check-out {
            background: #1759a6;
            color: white;
        }

        button:disabled {
            background: #d7dce5;
            color: #68758a;
            cursor: not-allowed;
        }

        .table-container {
            width: 100%;
            overflow-x: auto;
        }

        .attendance-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
            font-size: 14px;
            white-space: nowrap;
        }

        .attendance-table th,
        .attendance-table td {
            padding: 12px;
            border-bottom: 1px solid #e2e8f0;
            text-align: left;
        }

        .attendance-table th {
            background: #f1f5f9;
            color: #243047;
        }

        .attendance-table tbody tr:hover {
            background: #f8fafc;
        }

        .empty {
            text-align: center !important;
            color: #68758a;
            padding: 22px !important;
        }

        .back {
            display: inline-block;
            padding: 11px 15px;
            border-radius: 5px;
            background: #e2e8f0;
            color: #263445;
            text-decoration: none;
            font-weight: bold;
            transition: background 0.2s ease;
        }

        .back:hover {
            background: #cbd5e1;
        }

        @media (max-width: 520px) {
            .details {
                grid-template-columns: 1fr;
            }

            .card {
                padding: 21px;
            }
        }
    </style>
</head>

<body>
    <header>
        <h1>CityCare Hospital</h1>
        <p>Staff Attendance Management</p>
    </header>

    <main>

        <% if (message != null) { %>
            <div class="message">
                <%= message.replace("&", "&amp;")
                           .replace("<", "&lt;")
                           .replace(">", "&gt;")
                           .replace("\"", "&quot;")
                           .replace("'", "&#x27;") %>
            </div>
        <% } %>

        <% if (isAdmin) { %>

            <!-- Administrator: today's attendance for all staff -->
            <div class="card">
                <h2>Today's Attendance — All Staff</h2>

                <div class="date">
                    Attendance date:
                    <%= attendanceDate != null
                            ? attendanceDate
                            : java.time.LocalDate.now(
                                    java.time.ZoneId.of("Asia/Kolkata")) %>
                </div>

                <div class="table-container">
                    <table class="attendance-table">
                        <thead>
                            <tr>
                                <th>Staff ID</th>
                                <th>Status</th>
                                <th>Check In</th>
                                <th>Check Out</th>
                                <th>Late (min)</th>
                                <th>Early Departure (min)</th>
                                <th>Overtime (min)</th>
                            </tr>
                        </thead>

                        <tbody>
                            <% if (attendanceRecords != null
                                    && !attendanceRecords.isEmpty()) { %>

                                <% for (StaffAttendance record : attendanceRecords) { %>
                                    <tr>
                                        <td><%= record.getStaffId() %></td>
                                        <td>
                                            <%= record.getAttendanceStatus() %>
                                        </td>
                                        <td>
                                            <%= record.getCheckIn() == null
                                                    ? "--"
                                                    : record.getCheckIn()
                                                            .format(timeFormat) %>
                                        </td>
                                        <td>
                                            <%= record.getCheckOut() == null
                                                    ? "--"
                                                    : record.getCheckOut()
                                                            .format(timeFormat) %>
                                        </td>
                                        <td><%= record.getLateMinutes() %></td>
                                        <td><%= record.getEarlyDepartureMinutes() %></td>
                                        <td><%= record.getOvertimeMinutes() %></td>
                                    </tr>
                                <% } %>

                            <% } else { %>
                                <tr>
                                    <td colspan="7" class="empty">
                                        No attendance records found for today.
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>

        <% } else { %>

            <!-- Staff: personal attendance and check-in/check-out -->
            <div class="card">
                <h2>Today's Attendance</h2>

                <div class="date">
                    Attendance date:
                    <%= java.time.LocalDate.now(
                            java.time.ZoneId.of("Asia/Kolkata")) %>
                </div>

                <% if (attendance == null) { %>

                    <span class="status">Not checked in</span>

                    <div class="details">
                        <div class="detail">
                            <span>Check-in time</span>
                            <strong>--</strong>
                        </div>

                        <div class="detail">
                            <span>Check-out time</span>
                            <strong>--</strong>
                        </div>
                    </div>

                <% } else { %>

                    <span class="status">
                        <%= attendance.getAttendanceStatus() %>
                    </span>

                    <div class="details">
                        <div class="detail">
                            <span>Check-in time</span>
                            <strong>
                                <%= attendance.getCheckIn() == null
                                        ? "--"
                                        : attendance.getCheckIn()
                                                .format(timeFormat) %>
                            </strong>
                        </div>

                        <div class="detail">
                            <span>Check-out time</span>
                            <strong>
                                <%= attendance.getCheckOut() == null
                                        ? "--"
                                        : attendance.getCheckOut()
                                                .format(timeFormat) %>
                            </strong>
                        </div>
                    </div>

                <% } %>

                <div class="actions">
                    <% if (attendance == null) { %>

                        <form method="post"
                              action="<%= request.getContextPath() %>/staff-attendance">
                            <input type="hidden" name="action" value="checkIn">
                            <button type="submit" class="check-in">
                                Check In
                            </button>
                        </form>

                    <% } else if (attendance.getCheckOut() == null) { %>

                        <form method="post"
                              action="<%= request.getContextPath() %>/staff-attendance">
                            <input type="hidden" name="action" value="checkOut">
                            <button type="submit" class="check-out">
                                Check Out
                            </button>
                        </form>

                    <% } else { %>

                        <button type="button" disabled>
                            Attendance Completed
                        </button>

                    <% } %>
                </div>
            </div>

        <% } %>

        <a class="back"
           href="<%= request.getContextPath() %>/dashboard">
            ← Back to Dashboard
        </a>

    </main>
</body>
</html>