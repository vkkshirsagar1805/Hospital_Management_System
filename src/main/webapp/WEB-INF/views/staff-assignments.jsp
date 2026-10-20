<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"
    import="java.util.*,com.hospital.model.StaffAssignment,com.hospital.model.Staff,com.hospital.model.Department" %>

<%!
    private String esc(Object value) {
        if (value == null) return "";
        return value.toString()
            .replace("&", "&amp;")
            .replace("<", "&lt;")
            .replace(">", "&gt;")
            .replace("\"", "&quot;")
            .replace("'", "&#39;");
    }
%>

<%
    List<StaffAssignment> assignments =
        (List<StaffAssignment>) request.getAttribute("assignments");
    if (assignments == null) assignments = new ArrayList<>();

    List<Staff> staffList =
        (List<Staff>) request.getAttribute("staffList");
    if (staffList == null) staffList = new ArrayList<>();

    List<Department> departments =
        (List<Department>) request.getAttribute("departments");
    if (departments == null) departments = new ArrayList<>();

    boolean canManage =
        Boolean.TRUE.equals(request.getAttribute("canManage"));

    String message =
        (String) session.getAttribute("assignmentMessage");
    session.removeAttribute("assignmentMessage");

    String context = request.getContextPath();
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Staff Assignments | CityCare Hospital</title>

<style>
* { box-sizing: border-box; }

body {
    margin: 0;
    font-family: Arial, sans-serif;
    background: #f3f6fb;
    color: #1f2937;
}

header {
    background: #123b63;
    color: white;
    padding: 22px 5%;
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 15px;
    flex-wrap: wrap;
}

header h1 { margin: 0; font-size: 24px; }
header p { margin: 6px 0 0; color: #dbeafe; }
header a { color: white; text-decoration: none; }

main {
    max-width: 1300px;
    margin: 28px auto;
    padding: 0 20px;
}

.panel {
    background: white;
    padding: 24px;
    margin-bottom: 24px;
    border-radius: 12px;
    box-shadow: 0 3px 12px #152c4b0d;
}

h2 { margin-top: 0; color: #123b63; }

.grid {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 16px;
}

label {
    display: block;
    font-size: 14px;
    font-weight: bold;
    margin-bottom: 7px;
}

input, select, textarea {
    width: 100%;
    padding: 11px;
    border: 1px solid #cbd5e1;
    border-radius: 7px;
    font: inherit;
    background: white;
}

textarea { resize: vertical; }

button {
    padding: 10px 15px;
    border: 0;
    border-radius: 7px;
    background: #1769aa;
    color: white;
    font-weight: bold;
    cursor: pointer;
}

button:hover { background: #124f82; }

.message {
    padding: 13px 16px;
    margin-bottom: 20px;
    border-radius: 8px;
    background: #e0f2fe;
    color: #075985;
}

.table-wrap { overflow-x: auto; }

table {
    width: 100%;
    border-collapse: collapse;
    min-width: 950px;
}

th, td {
    text-align: left;
    padding: 13px 12px;
    border-bottom: 1px solid #e5e7eb;
    vertical-align: top;
}

th {
    background: #f1f5f9;
    color: #334155;
    font-size: 13px;
}

td { font-size: 14px; }

.status {
    display: inline-block;
    padding: 5px 9px;
    border-radius: 20px;
    background: #e0f2fe;
    color: #075985;
    font-size: 12px;
    font-weight: bold;
}

.status-COMPLETED {
    background: #dcfce7;
    color: #166534;
}

.status-CANCELLED {
    background: #fee2e2;
    color: #991b1b;
}

.status-IN_PROGRESS {
    background: #fef3c7;
    color: #92400e;
}

.status-form {
    display: flex;
    gap: 7px;
    min-width: 210px;
}

.status-form select { min-width: 130px; }

.status-form button { white-space: nowrap; }

.empty {
    text-align: center;
    color: #64748b;
    padding: 25px;
}

small { color: #64748b; }

@media (max-width: 700px) {
    .grid { grid-template-columns: 1fr; }
    main { padding: 0 12px; }
    .panel { padding: 17px; }
}
</style>
</head>

<body>

<header>
    <div>
        <h1>Staff Assignments</h1>
        <p>Manage staff duties, departments and shifts.</p>
    </div>
    <a href="<%= context %>/dashboard"
    	style="display:inline-block;
          padding:10px 15px;
          border-radius:7px;
          background:#e2e8f0;
          color:#263445;
          text-decoration:none;
          font-weight:bold;">
     	Back to Dashboard
	</a>
</header>

<main>

<% if (message != null && !message.isEmpty()) { %>
    <div class="message"><%= esc(message) %></div>
<% } %>

<% if (canManage) { %>
<section class="panel">
    <h2>Create Staff Assignment</h2>
    <p>Select a staff member and department, then enter the shift details.</p>

    <form method="post" action="<%= context %>/staff-assignments">
        <input type="hidden" name="action" value="add">

        <div class="grid">
            <div>
                <label for="staffId">Staff Member</label>
                <select id="staffId" name="staffId" required>
                    <option value="">Select active staff member</option>
                    <% for (Staff staff : staffList) { %>
                        <option value="<%= staff.getStaffId() %>">
                            <%= esc(staff.getFullName()) %>
                            — <%= esc(staff.getDesignation()) %>
                            (ID: <%= staff.getStaffId() %>)
                        </option>
                    <% } %>
                </select>
                <% if (staffList.isEmpty()) { %>
                    <small>No active staff members available.</small>
                <% } %>
            </div>

            <div>
                <label for="departmentId">Department</label>
                <select id="departmentId" name="departmentId" required>
                    <option value="">Select active department</option>
                    <% for (Department department : departments) { %>
                        <option value="<%= department.getDepartmentId() %>">
                            <%= esc(department.getDepartmentName()) %>
                        </option>
                    <% } %>
                </select>
                <% if (departments.isEmpty()) { %>
                    <small>No active departments available.</small>
                <% } %>
            </div>

            <div>
                <label for="assignmentTitle">Assignment Title</label>
                <input id="assignmentTitle" name="assignmentTitle"
                    maxlength="150" required
                    placeholder="e.g. Night Ward Duty">
            </div>

            <div>
                <label for="dutyLocation">Duty Location</label>
                <input id="dutyLocation" name="dutyLocation"
                    maxlength="150"
                    placeholder="e.g. General Ward">
            </div>

            <div>
                <label for="shiftStart">Shift Start</label>
                <input id="shiftStart" name="shiftStart"
                    type="datetime-local" required>
            </div>

            <div>
                <label for="shiftEnd">Shift End</label>
                <input id="shiftEnd" name="shiftEnd"
                    type="datetime-local" required>
            </div>

            <div style="grid-column:1/-1">
                <label for="notes">Notes (Optional)</label>
                <textarea id="notes" name="notes" rows="3"
                    maxlength="500"
                    placeholder="Additional instructions"></textarea>
            </div>
        </div>

        <p style="margin-bottom:0;margin-top:20px">
            <button type="submit"
                <%= staffList.isEmpty() || departments.isEmpty()
                    ? "disabled" : "" %>>
                Create Assignment
            </button>
        </p>
    </form>
</section>
<% } %>

<section class="panel">
    <h2>All Staff Assignments</h2>
    <p>Total assignments:
        <strong><%= assignments.size() %></strong>
    </p>

    <div class="table-wrap">
    <table>
        <thead>
        <tr>
            <th>ID</th>
            <th>Staff Member</th>
            <th>Department ID</th>
            <th>Assignment</th>
            <th>Location</th>
            <th>Shift Start</th>
            <th>Shift End</th>
            <th>Status</th>
            <% if (canManage) { %>
                <th>Update Status</th>
            <% } %>
        </tr>
        </thead>

        <tbody>
        <% if (assignments.isEmpty()) { %>
            <tr>
                <td class="empty"
                    colspan="<%= canManage ? 9 : 8 %>">
                    No staff assignments found.
                </td>
            </tr>
        <% } else {
            for (StaffAssignment a : assignments) {
                String status = a.getAssignmentStatus();

                String staffName = "Unknown staff";
                for (Staff staff : staffList) {
                    if (staff.getStaffId() == a.getStaffId()) {
                        staffName = staff.getFullName();
                        break;
                    }
                }

                String departmentName = "Department ID: "
                        + a.getDepartmentId();

                for (Department department : departments) {
                    if (department.getDepartmentId()
                            == a.getDepartmentId()) {
                        departmentName = department.getDepartmentName();
                        break;
                    }
                }
        %>
            <tr>
                <td><%= a.getAssignmentId() %></td>

                <td>
                    <strong><%= esc(staffName) %></strong>
                    <br><small>ID: <%= a.getStaffId() %></small>
                </td>

                <td>
                    <%= esc(departmentName) %>
                    <br><small>ID: <%= a.getDepartmentId() %></small>
                </td>

                <td>
                    <strong><%= esc(a.getAssignmentTitle()) %></strong>
                    <% if (a.getNotes() != null
                            && !a.getNotes().isEmpty()) { %>
                        <br><small><%= esc(a.getNotes()) %></small>
                    <% } %>
                </td>

                <td><%= esc(a.getDutyLocation()) %></td>
                <td><%= esc(a.getShiftStart()) %></td>
                <td><%= esc(a.getShiftEnd()) %></td>

                <td>
                    <span class="status status-<%= esc(status) %>">
                        <%= esc(status) %>
                    </span>
                </td>

                <% if (canManage) { %>
                <td>
                    <form class="status-form" method="post"
                        action="<%= context %>/staff-assignments">

                        <input type="hidden" name="action"
                            value="updateStatus">

                        <input type="hidden" name="assignmentId"
                            value="<%= a.getAssignmentId() %>">

                        <select name="status"
                            aria-label="Assignment status">
                            <option value="SCHEDULED"
                                <%= "SCHEDULED".equals(status)
                                    ? "selected" : "" %>>
                                Scheduled
                            </option>
                            <option value="IN_PROGRESS"
                                <%= "IN_PROGRESS".equals(status)
                                    ? "selected" : "" %>>
                                In Progress
                            </option>
                            <option value="COMPLETED"
                                <%= "COMPLETED".equals(status)
                                    ? "selected" : "" %>>
                                Completed
                            </option>
                            <option value="CANCELLED"
                                <%= "CANCELLED".equals(status)
                                    ? "selected" : "" %>>
                                Cancelled
                            </option>
                        </select>

                        <button type="submit">Save</button>
                    </form>
                </td>
                <% } %>
            </tr>
        <%  }
           } %>
        </tbody>
    </table>
    </div>
</section>

</main>
</body>
</html>
