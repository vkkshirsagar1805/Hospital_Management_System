
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.hospital.model.EmergencyRequest" %>

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
    List<EmergencyRequest> emergencyRequests =
        (List<EmergencyRequest>) request.getAttribute("emergencyRequests");

    List<EmergencyRequest> patients =
        (List<EmergencyRequest>) request.getAttribute("patients");

    List<EmergencyRequest> availableAmbulances =
        (List<EmergencyRequest>) request.getAttribute("availableAmbulances");

    String contextPath = request.getContextPath();
    String role = session.getAttribute("role") == null
        ? "" : session.getAttribute("role").toString().toUpperCase();

    boolean canManage = role.equals("ADMIN")
        || role.equals("DOCTOR")
        || role.equals("RECEPTIONIST")
        || role.equals("STAFF");

    String success = request.getParameter("success");
    String error = request.getParameter("error");
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Emergency Requests | CityCare Hospital</title>

<style>
:root {
    --navy: #10243a;
    --blue: #1769aa;
    --red: #d92d3a;
    --bg: #f3f6fa;
    --border: #e1e7ef;
    --muted: #64748b;
}
* { box-sizing: border-box; }
body {
    margin: 0;
    background: var(--bg);
    color: #1e293b;
    font-family: Arial, Helvetica, sans-serif;
}
.topbar {
    background: var(--navy);
    color: white;
    padding: 19px 5%;
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 15px;
    flex-wrap: wrap;
}
.topbar h1 { margin: 0; font-size: 23px; }
.topbar p { margin: 6px 0 0; color: #cbd5e1; font-size: 13px; }
.topbar a {
    display: inline-block;
    background: #e2e8f0;
    color: #263445;
    text-decoration: none;
    padding: 10px 15px;
    border-radius: 7px;
    font-weight: bold;
    transition: background 0.2s ease;
}

.topbar a:hover {
    background: #cbd5e1;
}
.container {
    width: 94%;
    max-width: 1450px;
    margin: 25px auto;
}
.alert {
    padding: 13px 16px;
    border-radius: 8px;
    margin-bottom: 17px;
}
.success { background: #dcfce7; color: #166534; }
.error { background: #fee2e2; color: #991b1b; }
.card {
    background: white;
    border: 1px solid var(--border);
    border-radius: 13px;
    padding: 22px;
    margin-bottom: 22px;
    box-shadow: 0 3px 12px rgba(15, 23, 42, .04);
}
.card h2 { margin: 0 0 18px; font-size: 19px; }
.form-grid {
    display: grid;
    grid-template-columns: repeat(3, minmax(0, 1fr));
    gap: 16px;
}
.field label {
    display: block;
    font-size: 13px;
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
textarea { min-height: 85px; resize: vertical; }
.full { grid-column: 1 / -1; }
.btn {
    border: 0;
    border-radius: 7px;
    padding: 10px 14px;
    cursor: pointer;
    font-weight: bold;
    font-size: 13px;
    text-decoration: none;
    display: inline-block;
}
.btn-primary { background: var(--blue); color: white; }
.btn-red { background: var(--red); color: white; }
.btn-light { background: #eaf0f7; color: #1e293b; }
.table-wrap { overflow-x: auto; }
table { width: 100%; border-collapse: collapse; min-width: 1100px; }
th, td {
    text-align: left;
    padding: 13px 11px;
    border-bottom: 1px solid var(--border);
    vertical-align: top;
    font-size: 13px;
}
th {
    color: var(--muted);
    background: #f8fafc;
    font-size: 12px;
    text-transform: uppercase;
}
.badge {
    display: inline-block;
    padding: 5px 8px;
    border-radius: 20px;
    background: #e2e8f0;
    font-size: 11px;
    font-weight: bold;
    white-space: nowrap;
}
.CRITICAL, .HIGH { background: #fee2e2; color: #b91c1c; }
.MEDIUM { background: #fef3c7; color: #92400e; }
.LOW { background: #dcfce7; color: #166534; }
.REPORTED { background: #e0e7ff; color: #3730a3; }
.DISPATCHED, .IN_PROGRESS { background: #dbeafe; color: #1d4ed8; }
.RESOLVED { background: #dcfce7; color: #166534; }
.CANCELLED { background: #e2e8f0; color: #475569; }
.row-form { display: grid; gap: 8px; min-width: 180px; }
.row-form .btn { width: 100%; }
.muted { color: var(--muted); }
.empty { text-align: center; padding: 30px; color: var(--muted); }
@media (max-width: 800px) {
    .form-grid { grid-template-columns: 1fr; }
    .full { grid-column: auto; }
    .card { padding: 16px; }
}
</style>
</head>

<body>

<header class="topbar">
    <div>
        <h1>🚨 Emergency Requests</h1>
        <p>CityCare Hospital · Emergency response management</p>
    </div>
    <a href="<%= contextPath %>/dashboard">← Back to Dashboard</a>
</header>

<main class="container">

<% if ("1".equals(success)) { %>
    <div class="alert success">
        Operation completed. Refresh the list to see the latest status.
    </div>
<% } %>

<% if ("invalid".equals(error)) { %>
    <div class="alert error">
        Invalid or incomplete information. Check the form and try again.
    </div>
<% } else if ("database".equals(error)) { %>
    <div class="alert error">
        The database operation failed. Check the server log and database constraints.
    </div>
<% } %>

<% if (canManage) { %>
<section class="card">
    <h2>Register Emergency</h2>

    <form method="post" action="<%= contextPath %>/emergency-requests">
        <input type="hidden" name="action" value="create">

        <div class="form-grid">
            <div class="field">
                <label for="emergencyType">Emergency Type *</label>
                <select id="emergencyType" name="emergencyType" required>
                    <option value="MEDICAL">Medical</option>
                    <option value="ACCIDENT">Accident</option>
                    <option value="CARDIAC">Cardiac</option>
                    <option value="RESPIRATORY">Respiratory</option>
                    <option value="TRAUMA">Trauma</option>
                    <option value="OTHER">Other</option>
                </select>
            </div>

            <div class="field">
                <label for="severity">Severity *</label>
                <select id="severity" name="severity" required>
                    <option value="MEDIUM">Medium</option>
                    <option value="LOW">Low</option>
                    <option value="HIGH">High</option>
                    <option value="CRITICAL">Critical</option>
                </select>
            </div>

            <div class="field">
                <label for="patientId">Patient (optional)</label>
                <select id="patientId" name="patientId">
                    <option value="">Not registered / unknown</option>
                    <% if (patients != null) {
                        for (EmergencyRequest p : patients) { %>
                            <option value="<%= p.getPatientId() %>">
                                <%= esc(p.getPatientName()) %>
                                (ID: <%= p.getPatientId() %>)
                            </option>
                    <%  }
                    } %>
                </select>
            </div>

            <div class="field full">
                <label for="requestLocation">Emergency Location *</label>
                <input id="requestLocation" name="requestLocation"
                       maxlength="300" required
                       placeholder="Enter ward, room, building or address">
            </div>

            <div class="field full">
                <label for="requestDescription">Description</label>
                <textarea id="requestDescription" name="requestDescription"
                          maxlength="5000"
                          placeholder="Describe the emergency and immediate needs"></textarea>
            </div>

            <div class="field full">
                <button class="btn btn-red" type="submit">
                    Register Emergency
                </button>
            </div>
        </div>
    </form>
</section>
<% } %>

<section class="card">
    <h2>Emergency Request Records</h2>

    <div class="table-wrap">
    <table>
        <thead>
        <tr>
            <th>ID / Time</th>
            <th>Emergency</th>
            <th>Location / Description</th>
            <th>Patient</th>
            <th>Reported By</th>
            <th>Ambulance</th>
            <th>Status</th>
            <% if (canManage) { %>
                <th>Actions</th>
            <% } %>
        </tr>
        </thead>

        <tbody>
        <% if (emergencyRequests == null || emergencyRequests.isEmpty()) { %>
            <tr>
                <td class="empty" colspan="<%= canManage ? 8 : 7 %>">
                    No emergency requests found.
                </td>
            </tr>
        <% } else {
            for (EmergencyRequest er : emergencyRequests) {
                String severityClass = er.getSeverity() == null
                    ? "" : er.getSeverity();

                String statusClass = er.getRequestStatus() == null
                    ? "" : er.getRequestStatus();
        %>
            <tr>
                <td>
                    <strong>#<%= er.getEmergencyRequestId() %></strong><br>
                    <span class="muted">
                        <%= esc(er.getRequestedAt()) %>
                    </span>
                </td>

                <td>
                    <strong><%= esc(er.getEmergencyType()) %></strong><br>
                    <span class="badge <%= esc(severityClass) %>">
                        <%= esc(severityClass) %>
                    </span>
                </td>

                <td>
                    <strong><%= esc(er.getRequestLocation()) %></strong><br>
                    <%= esc(er.getRequestDescription()) %>
                </td>

                <td>
                    <%= er.getPatientId() == null
                        ? "Not specified"
                        : esc(er.getPatientName()) + " (ID: "
                            + er.getPatientId() + ")" %>
                </td>

                <td><%= esc(er.getReportedByUsername()) %></td>

                <td>
                    <%= er.getAmbulanceId() == null
                        ? "Not assigned"
                        : esc(er.getAmbulanceNumber()) %>
                </td>

                <td>
                    <span class="badge <%= esc(statusClass) %>">
                        <%= esc(statusClass) %>
                    </span>

                    <% if (er.getDispatchedAt() != null) { %>
                        <br><small class="muted">
                            Dispatched: <%= esc(er.getDispatchedAt()) %>
                        </small>
                    <% } %>

                    <% if (er.getResolvedAt() != null) { %>
                        <br><small class="muted">
                            Closed: <%= esc(er.getResolvedAt()) %>
                        </small>
                    <% } %>
                </td>

                <% if (canManage) { %>
                <td>
                    <div class="row-form">

                    <% if (!"RESOLVED".equals(statusClass)
                            && !"CANCELLED".equals(statusClass)) { %>

                        <form method="post"
                              action="<%= contextPath %>/emergency-requests">
                            <input type="hidden" name="action"
                                   value="updateStatus">
                            <input type="hidden" name="requestId"
                                   value="<%= er.getEmergencyRequestId() %>">

                            <select name="requestStatus" required>
                                <% String[] statuses = {
                                    "REPORTED", "ACKNOWLEDGED",
                                    "DISPATCHED", "IN_PROGRESS",
                                    "RESOLVED", "CANCELLED"
                                };
                                for (String s : statuses) { %>
                                    <option value="<%= s %>"
                                        <%= s.equals(statusClass)
                                            ? "selected" : "" %>>
                                        <%= s.replace('_', ' ') %>
                                    </option>
                                <% } %>
                            </select>

                            <input type="text" name="resolutionNotes"
                                   maxlength="500"
                                   value="<%= esc(er.getResolutionNotes()) %>"
                                   placeholder="Resolution notes">

                            <button class="btn btn-primary" type="submit">
                                Update Status
                            </button>
                        </form>

                        <% if (er.getAmbulanceId() == null
                                && availableAmbulances != null
                                && !availableAmbulances.isEmpty()) { %>

                        <form method="post"
                              action="<%= contextPath %>/emergency-requests">
                            <input type="hidden" name="action"
                                   value="assignAmbulance">
                            <input type="hidden" name="requestId"
                                   value="<%= er.getEmergencyRequestId() %>">

                            <select name="ambulanceId" required>
                                <option value="">Select ambulance</option>
                                <% for (EmergencyRequest a : availableAmbulances) { %>
                                    <option value="<%= a.getAmbulanceId() %>">
                                        <%= esc(a.getAmbulanceNumber()) %>
                                    </option>
                                <% } %>
                            </select>

                            <button class="btn btn-red" type="submit">
                                Assign & Dispatch
                            </button>
                        </form>

                        <% } %>

                    <% } else { %>
                        <span class="muted">Request closed</span>
                    <% } %>

                    </div>
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
