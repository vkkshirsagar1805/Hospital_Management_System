
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" import="java.util.*,com.hospital.model.Ambulance" %>

<%!
    private String esc(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#39;");
    }
%>

<%
    List<Ambulance> ambulances =
        (List<Ambulance>) request.getAttribute("ambulances");

    if (ambulances == null) {
        ambulances = new ArrayList<>();
    }

    Boolean manageAttribute = (Boolean) request.getAttribute("canManage");
    boolean canManage = Boolean.TRUE.equals(manageAttribute);

    Ambulance editAmbulance =
        (Ambulance) request.getAttribute("editAmbulance");

    String message = (String) session.getAttribute("ambulanceMessage");
    session.removeAttribute("ambulanceMessage");

    String ctx = request.getContextPath();

    int availableCount = 0;
    int assignedCount = 0;
    int onTripCount = 0;
    int maintenanceCount = 0;

    for (Ambulance a : ambulances) {
        if ("AVAILABLE".equals(a.getAmbulanceStatus())) availableCount++;
        if ("ASSIGNED".equals(a.getAmbulanceStatus())) assignedCount++;
        if ("ON_TRIP".equals(a.getAmbulanceStatus())) onTripCount++;
        if ("MAINTENANCE".equals(a.getAmbulanceStatus())) maintenanceCount++;
    }

    String[] statuses = {
        "AVAILABLE", "ASSIGNED", "ON_TRIP",
        "MAINTENANCE", "OUT_OF_SERVICE"
    };

    String[] types = {
        "BASIC", "ADVANCED_LIFE_SUPPORT",
        "PATIENT_TRANSPORT", "OTHER"
    };
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Ambulance Management | CityCare Hospital</title>

<style>
    * { box-sizing: border-box; }

    body {
        margin: 0;
        font-family: Arial, Helvetica, sans-serif;
        background: #f3f6fb;
        color: #17243a;
    }

    .topbar {
        background: #142d4e;
        color: white;
        padding: 20px 5%;
        display: flex;
        justify-content: space-between;
        align-items: center;
        gap: 15px;
        flex-wrap: wrap;
    }

    .topbar h1 {
        margin: 0;
        font-size: 24px;
    }

    .topbar p {
        margin: 6px 0 0;
        color: #d3deed;
        font-size: 13px;
    }

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
        max-width: 1400px;
        margin: 28px auto;
        padding: 0 20px;
    }

    .page-heading {
        display: flex;
        justify-content: space-between;
        align-items: center;
        gap: 12px;
        flex-wrap: wrap;
        margin-bottom: 20px;
    }

    .page-heading h2 {
        margin: 0 0 6px;
        font-size: 25px;
    }

    .muted {
        color: #64748b;
        font-size: 14px;
    }

    .stats {
        display: grid;
        grid-template-columns: repeat(4, minmax(0, 1fr));
        gap: 16px;
        margin-bottom: 24px;
    }

    .stat-card, .panel {
        background: white;
        border: 1px solid #e0e7f0;
        border-radius: 12px;
        box-shadow: 0 3px 12px rgba(20, 45, 78, .04);
    }

    .stat-card { padding: 20px; }

    .stat-card span {
        color: #64748b;
        font-size: 13px;
    }

    .stat-card h3 {
        margin: 10px 0 0;
        font-size: 28px;
    }

    .panel {
        padding: 22px;
        margin-bottom: 24px;
    }

    .panel h3 {
        margin: 0 0 8px;
        font-size: 19px;
    }

    .message {
        padding: 13px 16px;
        border-radius: 8px;
        background: #e8f5e9;
        color: #176b36;
        border: 1px solid #b8e1c1;
        margin-bottom: 18px;
    }

    .form-grid {
        display: grid;
        grid-template-columns: repeat(3, minmax(0, 1fr));
        gap: 16px;
        margin-top: 20px;
    }

    .field label {
        display: block;
        font-size: 13px;
        font-weight: bold;
        margin-bottom: 7px;
    }

    .field input, .field select, .field textarea {
        width: 100%;
        padding: 11px;
        border: 1px solid #cbd5e1;
        border-radius: 7px;
        background: white;
        color: #17243a;
        font: inherit;
    }

    .field textarea {
        resize: vertical;
        min-height: 42px;
    }

    .full-width { grid-column: 1 / -1; }

    .btn {
        display: inline-block;
        border: none;
        border-radius: 7px;
        padding: 10px 14px;
        font-size: 13px;
        font-weight: bold;
        cursor: pointer;
        text-decoration: none;
        text-align: center;
    }

    .btn-primary { background: #1769aa; color: white; }
    .btn-secondary { background: #e8edf5; color: #263a54; }
    .btn-success { background: #d9f4e3; color: #176b36; }
    .btn-warning { background: #fff0cc; color: #865b00; }

    .table-wrapper {
        overflow-x: auto;
        margin-top: 18px;
    }

    table {
        width: 100%;
        border-collapse: collapse;
        min-width: 1000px;
    }

    th, td {
        padding: 14px 12px;
        text-align: left;
        border-bottom: 1px solid #e8edf4;
        vertical-align: top;
        font-size: 13px;
    }

    th {
        background: #f7f9fc;
        color: #53647b;
        font-size: 12px;
        text-transform: uppercase;
        letter-spacing: .3px;
    }

    .vehicle {
        font-weight: bold;
        color: #173c67;
    }

    .badge {
        display: inline-block;
        padding: 6px 9px;
        border-radius: 20px;
        background: #e8edf5;
        color: #334155;
        font-size: 11px;
        font-weight: bold;
        white-space: nowrap;
    }

    .AVAILABLE { background: #d9f4e3; color: #176b36; }
    .ASSIGNED { background: #dceafe; color: #174a91; }
    .ON_TRIP { background: #fff0cc; color: #865b00; }
    .MAINTENANCE, .OUT_OF_SERVICE {
        background: #fee2e2;
        color: #991b1b;
    }

    .actions {
        display: flex;
        align-items: center;
        gap: 8px;
        flex-wrap: wrap;
    }

    .status-form {
        display: flex;
        gap: 6px;
        align-items: center;
    }

    .status-form select {
        padding: 8px;
        border: 1px solid #cbd5e1;
        border-radius: 6px;
        max-width: 150px;
    }

    .empty {
        text-align: center;
        padding: 35px;
        color: #64748b;
    }

    .footer {
        text-align: center;
        color: #64748b;
        padding: 20px;
        font-size: 12px;
    }

    @media (max-width: 850px) {
        .stats { grid-template-columns: repeat(2, minmax(0, 1fr)); }
        .form-grid { grid-template-columns: repeat(2, minmax(0, 1fr)); }
    }

    @media (max-width: 550px) {
        .stats, .form-grid { grid-template-columns: 1fr; }
        .full-width { grid-column: auto; }
        .panel { padding: 16px; }
    }
</style>
</head>

<body>

<header class="topbar">
    <div>
        <h1>CityCare Hospital</h1>
        <p>Emergency Services &amp; Ambulance Operations</p>
    </div>
    <a href="<%= ctx %>/dashboard">← Back to Dashboard</a>
</header>

<main class="container">

    <div class="page-heading">
        <div>
            <h2>Ambulance Management</h2>
            <div class="muted">
                Manage vehicles, driver details and fleet availability.
            </div>
        </div>
        <div class="muted">
            Total fleet: <strong><%= ambulances.size() %></strong>
        </div>
    </div>

    <% if (message != null && !message.trim().isEmpty()) { %>
        <div class="message" role="status"><%= esc(message) %></div>
    <% } %>

    <section class="stats">
        <div class="stat-card">
            <span>Total Ambulances</span>
            <h3><%= ambulances.size() %></h3>
        </div>
        <div class="stat-card">
            <span>Available</span>
            <h3><%= availableCount %></h3>
        </div>
        <div class="stat-card">
            <span>Assigned</span>
            <h3><%= assignedCount %></h3>
        </div>
        <div class="stat-card">
            <span>On Trip</span>
            <h3><%= onTripCount %></h3>
        </div>
    </section>

    <% if (canManage) { %>
    <section class="panel">
        <h3>
            <%= editAmbulance == null
                ? "Register New Ambulance"
                : "Edit Ambulance Details" %>
        </h3>
        <p class="muted">
            Register a vehicle or update its basic information.
            New vehicles start with AVAILABLE status.
        </p>

        <form method="post" action="<%= ctx %>/ambulances">
            <input type="hidden" name="action"
                value="<%= editAmbulance == null ? "add" : "update" %>">

            <% if (editAmbulance != null) { %>
                <input type="hidden" name="ambulanceId"
                    value="<%= editAmbulance.getAmbulanceId() %>">
            <% } %>

            <div class="form-grid">
                <div class="field">
                    <label for="vehicleNumber">Vehicle Number *</label>
                    <input id="vehicleNumber" name="vehicleNumber"
                        maxlength="30" required
                        value="<%= editAmbulance == null ? "" :
                            esc(editAmbulance.getVehicleNumber()) %>"
                        placeholder="e.g. MH12AB1234">
                </div>

                <div class="field">
                    <label for="ambulanceType">Ambulance Type *</label>
                    <select id="ambulanceType" name="ambulanceType" required>
                        <% for (String type : types) { %>
                            <option value="<%= type %>"
                                <%= editAmbulance != null &&
                                    type.equals(editAmbulance.getAmbulanceType())
                                    ? "selected" : "" %>>
                                <%= type.replace('_', ' ') %>
                            </option>
                        <% } %>
                    </select>
                </div>

                <div class="field">
                    <label for="driverName">Driver Name</label>
                    <input id="driverName" name="driverName" maxlength="150"
                        value="<%= editAmbulance == null ? "" :
                            esc(editAmbulance.getDriverName()) %>"
                        placeholder="Driver's full name">
                </div>

                <div class="field">
                    <label for="driverPhone">Driver Phone</label>
                    <input id="driverPhone" name="driverPhone" maxlength="25"
                        pattern="[0-9+() .-]{5,25}"
                        value="<%= editAmbulance == null ? "" :
                            esc(editAmbulance.getDriverPhone()) %>"
                        placeholder="Contact number">
                </div>

                <div class="field">
                    <label for="currentLocation">Current Location</label>
                    <input id="currentLocation" name="currentLocation"
                        maxlength="255"
                        value="<%= editAmbulance == null ? "" :
                            esc(editAmbulance.getCurrentLocation()) %>"
                        placeholder="e.g. Emergency entrance">
                </div>

                <div class="field">
                    <label for="notes">Notes</label>
                    <input id="notes" name="notes" maxlength="500"
                        value="<%= editAmbulance == null ? "" :
                            esc(editAmbulance.getNotes()) %>"
                        placeholder="Optional remarks">
                </div>

                <div class="full-width actions">
                    <button class="btn btn-primary" type="submit">
                        <%= editAmbulance == null
                            ? "Register Ambulance"
                            : "Save Changes" %>
                    </button>

                    <% if (editAmbulance != null) { %>
                        <a class="btn btn-secondary"
                            href="<%= ctx %>/ambulances">Cancel Edit</a>
                    <% } %>
                </div>
            </div>
        </form>
    </section>
    <% } %>

    <section class="panel">
        <h3>Ambulance Fleet</h3>
        <p class="muted">
            View vehicle information and the latest recorded availability.
        </p>

        <div class="table-wrapper">
            <table>
                <thead>
                    <tr>
                        <th>Vehicle</th>
                        <th>Type</th>
                        <th>Driver</th>
                        <th>Contact</th>
                        <th>Current Location</th>
                        <th>Status</th>
                        <th>Last Status Update</th>
                        <% if (canManage) { %>
                            <th>Actions</th>
                        <% } %>
                    </tr>
                </thead>
                <tbody>
                <% if (ambulances.isEmpty()) { %>
                    <tr>
                        <td colspan="<%= canManage ? 8 : 7 %>" class="empty">
                            No ambulances registered yet.
                            <% if (canManage) { %>
                                Add your first ambulance using the form above.
                            <% } %>
                        </td>
                    </tr>
                <% } else {
                    for (Ambulance a : ambulances) {
                        String status = a.getAmbulanceStatus();
                %>
                    <tr>
                        <td>
                            <div class="vehicle">
                                <%= esc(a.getVehicleNumber()) %>
                            </div>
                            <div class="muted">
                                ID: <%= a.getAmbulanceId() %>
                            </div>
                        </td>

                        <td><%= esc(a.getAmbulanceType() == null ? "" :
                            a.getAmbulanceType().replace('_', ' ')) %></td>

                        <td><%= esc(a.getDriverName() == null ||
                            a.getDriverName().trim().isEmpty()
                            ? "Not assigned" : a.getDriverName()) %></td>

                        <td>
                            <% if (a.getDriverPhone() != null &&
                                !a.getDriverPhone().trim().isEmpty()) { %>
                                <a href="tel:<%= esc(a.getDriverPhone()) %>">
                                    <%= esc(a.getDriverPhone()) %>
                                </a>
                            <% } else { %>
                                <span class="muted">Not provided</span>
                            <% } %>
                        </td>

                        <td><%= esc(a.getCurrentLocation() == null ||
                            a.getCurrentLocation().trim().isEmpty()
                            ? "Not updated" : a.getCurrentLocation()) %></td>

                        <td>
                            <span class="badge <%= esc(status) %>">
                                <%= esc(status == null ? "UNKNOWN" :
                                    status.replace('_', ' ')) %>
                            </span>
                        </td>

                        <td>
                            <% if (a.getLastStatusUpdate() != null) { %>
                                <%= a.getLastStatusUpdate() %>
                            <% } else { %>
                                <span class="muted">Not recorded</span>
                            <% } %>
                        </td>

                        <% if (canManage) { %>
                        <td>
                            <div class="actions">
                                <a class="btn btn-secondary"
                                    href="<%= ctx %>/ambulances?editId=<%=
                                        a.getAmbulanceId() %>">Edit</a>

                                <form class="status-form" method="post"
                                    action="<%= ctx %>/ambulances">
                                    <input type="hidden" name="action"
                                        value="updateStatus">
                                    <input type="hidden" name="ambulanceId"
                                        value="<%= a.getAmbulanceId() %>">

                                    <select name="ambulanceStatus"
                                        aria-label="New ambulance status">
                                        <% for (String s : statuses) { %>
                                            <option value="<%= s %>"
                                                <%= s.equals(status)
                                                    ? "selected" : "" %>>
                                                <%= s.replace('_', ' ') %>
                                            </option>
                                        <% } %>
                                    </select>

                                    <button class="btn btn-success"
                                        type="submit">Update</button>
                                </form>
                            </div>
                        </td>
                        <% } %>
                    </tr>
                <% } } %>
                </tbody>
            </table>
        </div>
    </section>

    <div class="muted">
        Maintenance count: <strong><%= maintenanceCount %></strong>
        &nbsp; | &nbsp;
        Out-of-service count:
        <strong><%= ambulances.size() - availableCount
            - assignedCount - onTripCount - maintenanceCount %></strong>
    </div>

</main>

<footer class="footer">
    CityCare Hospital · Ambulance Operations
</footer>

</body>
</html>
