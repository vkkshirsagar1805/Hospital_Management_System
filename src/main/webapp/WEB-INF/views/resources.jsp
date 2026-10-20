<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="com.hospital.model.Patient" %>

<%!
    // Escape dynamic values before inserting them into HTML.
    private String esc(Object value) {
        if (value == null) return "";
        String s = String.valueOf(value);
        return s.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }
%>

<%
    if (session.getAttribute("role") == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    String role = String.valueOf(session.getAttribute("role"));

    boolean canAllocate =
        "ADMIN".equalsIgnoreCase(role)
        || "DOCTOR".equalsIgnoreCase(role)
        || "RECEPTIONIST".equalsIgnoreCase(role);

    List<Map<String, Object>> beds =
        (List<Map<String, Object>>) request.getAttribute("beds");

    List<Map<String, Object>> resources =
        (List<Map<String, Object>>) request.getAttribute("resources");

    List<Map<String, Object>> operationTheatres =
        (List<Map<String, Object>>) request.getAttribute("operationTheatres");

    List<Map<String, Object>> allocations =
        (List<Map<String, Object>>) request.getAttribute("activeAllocations");

    List<Patient> patients =
        (List<Patient>) request.getAttribute("patients");

    if (beds == null) beds = new java.util.ArrayList<>();
    if (resources == null) resources = new java.util.ArrayList<>();
    if (operationTheatres == null)
        operationTheatres = new java.util.ArrayList<>();
    if (allocations == null) allocations = new java.util.ArrayList<>();
    if (patients == null) patients = new java.util.ArrayList<>();

    String resourceMessage =
        (String) session.getAttribute("resourceMessage");

    if (resourceMessage != null) {
        session.removeAttribute("resourceMessage");
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Hospital Resource Management</title>

<style>
* { box-sizing: border-box; }

body {
    margin: 0;
    padding: 24px;
    font-family: Arial, sans-serif;
    background: #f4f7fb;
    color: #243247;
}

.container { max-width: 1200px; margin: auto; }

.header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 12px;
    flex-wrap: wrap;
    margin-bottom: 24px;
}

h1 { margin: 0 0 6px; font-size: 29px; }
h2 { font-size: 19px; margin-top: 0; }

.muted {
    color: #65748b;
    font-size: 14px;
    line-height: 1.5;
}

.grid {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 18px;
    align-items: start;
}

.card {
    background: #fff;
    padding: 20px;
    border-radius: 12px;
    box-shadow: 0 2px 10px #14213d0b;
    min-width: 0;
}

.full { grid-column: 1 / -1; }

.button {
    display: inline-block;
    padding: 10px 15px;
    border: none;
    border-radius: 7px;
    background: #155eef;
    color: #fff;
    text-decoration: none;
    font-size: 14px;
    font-weight: 600;
    cursor: pointer;
}

.button:hover { background: #104ac2; }
.button:disabled { background: #94a3b8; cursor: not-allowed; }

.button-danger { background: #b42318; }
.button-danger:hover { background: #912018; }

.table-wrap { overflow-x: auto; width: 100%; }

table {
    width: 100%;
    border-collapse: collapse;
    font-size: 14px;
}

th, td {
    text-align: left;
    padding: 11px 9px;
    border-bottom: 1px solid #e6ebf2;
    white-space: nowrap;
    vertical-align: middle;
}

th { background: #f7f9fc; color: #35445b; }
tbody tr:hover { background: #f8faff; }
.status { font-weight: bold; font-size: 12px; }

.form-grid {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 16px;
}

.form-group {
    display: flex;
    flex-direction: column;
    gap: 7px;
    min-width: 0;
}

.form-group.full-width { grid-column: 1 / -1; }

label {
    font-size: 14px;
    font-weight: 600;
    color: #35445b;
}

select, input[type="text"], input[type="number"] {
    width: 100%;
    padding: 11px 12px;
    border: 1px solid #cbd5e1;
    border-radius: 7px;
    background: #fff;
    color: #243247;
    font-size: 14px;
}

select:focus, input:focus {
    outline: none;
    border-color: #155eef;
    box-shadow: 0 0 0 3px #155eef18;
}

.form-actions {
    margin-top: 17px;
    display: flex;
    gap: 10px;
    flex-wrap: wrap;
}

.inline-form { display: inline-block; margin: 0; }

.empty-message {
    color: #65748b;
    text-align: center;
    padding: 18px;
}

.message {
    padding: 13px 16px;
    margin-bottom: 18px;
    background: #eff6ff;
    border: 1px solid #bfdbfe;
    border-radius: 8px;
    color: #1e40af;
}

@media (max-width: 720px) {
    body { padding: 14px; }
    .grid, .form-grid { grid-template-columns: 1fr; }
    .full, .form-group.full-width { grid-column: auto; }
    h1 { font-size: 24px; }
}
</style>
</head>

<body>
<div class="container">

    <div class="header">
        <div>
            <h1>Hospital Resources</h1>
            <div class="muted">
                Manage beds, medical equipment, operation theatres
                and patient allocations.
            </div>
        </div>

        <a class="button"
           href="<%= request.getContextPath() %>/dashboard"
           style="background: #e2e8f0; color: #263445;">
            Back to Dashboard
        </a>
    </div>

    <% if (resourceMessage != null) { %>
        <div class="message" role="status"><%= esc(resourceMessage) %></div>
    <% } %>

    <div class="grid">

        <% if (canAllocate) { %>
        <section class="card full">
            <h2>Allocate Bed to Patient</h2>
            <p class="muted">Assign an available hospital bed to a registered patient.</p>

            <form method="post" action="<%= request.getContextPath() %>/resources">
                <input type="hidden" name="action" value="allocateBed">

                <div class="form-grid">
                    <div class="form-group">
                        <label for="patientId">Patient</label>
                        <select id="patientId" name="patientId" required>
                            <option value="">Select patient</option>
                            <% for (Patient p : patients) { %>
                                <option value="<%= p.getPatientId() %>">
                                    <%= esc(p.getFullName()) %>
                                    (ID: <%= p.getPatientId() %>)
                                </option>
                            <% } %>
                        </select>
                    </div>

                    <div class="form-group">
                        <label for="bedId">Available Bed</label>
                        <select id="bedId" name="bedId" required>
                            <option value="">Select available bed</option>
                            <% for (Map<String, Object> bed : beds) {
                                if ("AVAILABLE".equals(String.valueOf(bed.get("bed_status")))) {
                            %>
                                <option value="<%= esc(bed.get("bed_id")) %>">
                                    <%= esc(bed.get("bed_number")) %> -
                                    <%= esc(bed.get("ward_name")) %>
                                    (<%= esc(bed.get("bed_type")) %>)
                                </option>
                            <% } } %>
                        </select>
                    </div>

                    <div class="form-group full-width">
                        <label for="bedNotes">Notes (Optional)</label>
                        <input type="text" id="bedNotes" name="notes"
                               maxlength="500" placeholder="Enter allocation notes">
                    </div>
                </div>

                <div class="form-actions">
                    <button type="submit" class="button"
                        <%= (patients.isEmpty() || beds.isEmpty()) ? "disabled" : "" %>>
                        Allocate Bed
                    </button>
                </div>
            </form>
        </section>

        <section class="card full">
            <h2>Allocate Medical Equipment</h2>
            <p class="muted">Allocate available equipment to a registered patient.</p>

            <form method="post" action="<%= request.getContextPath() %>/resources">
                <input type="hidden" name="action" value="allocateResource">

                <div class="form-grid">
                    <div class="form-group">
                        <label for="equipmentPatientId">Patient</label>
                        <select id="equipmentPatientId" name="patientId" required>
                            <option value="">Select patient</option>
                            <% for (Patient p : patients) { %>
                                <option value="<%= p.getPatientId() %>">
                                    <%= esc(p.getFullName()) %>
                                    (ID: <%= p.getPatientId() %>)
                                </option>
                            <% } %>
                        </select>
                    </div>

                    <div class="form-group">
                        <label for="resourceId">Equipment</label>
                        <select id="resourceId" name="resourceId" required>
                            <option value="">Select equipment</option>
                            <% for (Map<String, Object> item : resources) {
                                int available = item.get("available_quantity") == null
                                    ? 0 : ((Number) item.get("available_quantity")).intValue();
                                boolean active = "ACTIVE".equals(
                                    String.valueOf(item.get("resource_status")));
                                if (active && available > 0) {
                            %>
                                <option value="<%= esc(item.get("resource_id")) %>">
                                    <%= esc(item.get("resource_name")) %>
                                    (Available: <%= available %>)
                                </option>
                            <% } } %>
                        </select>
                    </div>

                    <div class="form-group">
                        <label for="quantity">Quantity</label>
                        <input type="number" id="quantity" name="quantity"
                               min="1" value="1" required>
                    </div>

                    <div class="form-group">
                        <label for="equipmentNotes">Notes (Optional)</label>
                        <input type="text" id="equipmentNotes" name="notes"
                               maxlength="500" placeholder="Enter allocation notes">
                    </div>
                </div>

                <div class="form-actions">
                    <button type="submit" class="button"
                        <%= (patients.isEmpty() || resources.isEmpty()) ? "disabled" : "" %>>
                        Allocate Equipment
                    </button>
                </div>
            </form>
        </section>
        <% } %>

        <section class="card">
            <h2>Hospital Beds</h2>
            <p class="muted">Total registered beds: <%= beds.size() %></p>
            <div class="table-wrap">
                <table>
                    <thead><tr><th>Bed</th><th>Ward</th><th>Type</th><th>Status</th></tr></thead>
                    <tbody>
                    <% for (Map<String, Object> bed : beds) { %>
                        <tr>
                            <td><%= esc(bed.get("bed_number")) %></td>
                            <td><%= esc(bed.get("ward_name")) %></td>
                            <td><%= esc(bed.get("bed_type")) %></td>
                            <td class="status"><%= esc(bed.get("bed_status")) %></td>
                        </tr>
                    <% } %>
                    <% if (beds.isEmpty()) { %>
                        <tr><td colspan="4" class="empty-message">No beds registered.</td></tr>
                    <% } %>
                    </tbody>
                </table>
            </div>
        </section>

        <section class="card">
            <h2>Medical Equipment</h2>
            <p class="muted">Equipment records: <%= resources.size() %></p>
            <div class="table-wrap">
                <table>
                    <thead>
                        <tr><th>Name</th><th>Category</th><th>Available</th><th>Total</th><th>Status</th></tr>
                    </thead>
                    <tbody>
                    <% for (Map<String, Object> item : resources) { %>
                        <tr>
                            <td><%= esc(item.get("resource_name")) %></td>
                            <td><%= esc(item.get("resource_category")) %></td>
                            <td><%= esc(item.get("available_quantity")) %></td>
                            <td><%= esc(item.get("total_quantity")) %></td>
                            <td class="status"><%= esc(item.get("resource_status")) %></td>
                        </tr>
                    <% } %>
                    <% if (resources.isEmpty()) { %>
                        <tr><td colspan="5" class="empty-message">No equipment registered.</td></tr>
                    <% } %>
                    </tbody>
                </table>
            </div>
        </section>

        <section class="card">
            <h2>Operation Theatres</h2>
            <p class="muted">Registered theatres: <%= operationTheatres.size() %></p>
            <div class="table-wrap">
                <table>
                    <thead>
                        <tr><th>Name</th><th>Type</th><th>Location</th><th>Status</th></tr>
                    </thead>
                    <tbody>
                    <% for (Map<String, Object> ot : operationTheatres) { %>
                        <tr>
                            <td><%= esc(ot.get("ot_name")) %></td>
                            <td><%= esc(ot.get("ot_type")) %></td>
                            <td><%= ot.get("location") != null ? esc(ot.get("location")) : "—" %></td>
                            <td class="status"><%= esc(ot.get("ot_status")) %></td>
                        </tr>
                    <% } %>
                    <% if (operationTheatres.isEmpty()) { %>
                        <tr><td colspan="4" class="empty-message">No operation theatres registered.</td></tr>
                    <% } %>
                    </tbody>
                </table>
            </div>
        </section>

        <section class="card full">
            <h2>Active Allocations</h2>
            <p class="muted">Current active allocations: <%= allocations.size() %></p>
            <div class="table-wrap">
                <table>
                    <thead>
                        <tr>
                            <th>Patient</th><th>Bed</th><th>Equipment</th>
                            <th>Quantity</th><th>Start</th><th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                    <% for (Map<String, Object> a : allocations) { %>
                        <tr>
                            <td>
                                <%= a.get("patient_name") != null
                                    ? esc(a.get("patient_name"))
                                    : (a.get("patient_id") != null
                                        ? "Patient #" + esc(a.get("patient_id")) : "—") %>
                            </td>
                            <td><%= a.get("bed_number") != null ? esc(a.get("bed_number")) : "—" %></td>
                            <td><%= a.get("resource_name") != null ? esc(a.get("resource_name")) : "—" %></td>
                            <td><%= esc(a.get("allocated_quantity")) %></td>
                            <td><%= esc(a.get("allocation_start")) %></td>
                            <td>
                                <% if (canAllocate && a.get("allocation_id") != null) { %>

                                    <% if (a.get("bed_id") != null) { %>
                                        <form class="inline-form" method="post"
                                              action="<%= request.getContextPath() %>/resources"
                                              onsubmit="return confirm('Release this bed allocation?');">
                                            <input type="hidden" name="action" value="releaseBed">
                                            <input type="hidden" name="allocationId"
                                                   value="<%= esc(a.get("allocation_id")) %>">
                                            <button type="submit" class="button button-danger">
                                                Release Bed
                                            </button>
                                        </form>
                                    <% } else if (a.get("resource_id") != null) { %>
                                        <form class="inline-form" method="post"
                                              action="<%= request.getContextPath() %>/resources"
                                              onsubmit="return confirm('Release this equipment allocation?');">
                                            <input type="hidden" name="action" value="releaseResource">
                                            <input type="hidden" name="allocationId"
                                                   value="<%= esc(a.get("allocation_id")) %>">
                                            <button type="submit" class="button button-danger">
                                                Release Equipment
                                            </button>
                                        </form>
                                    <% } else { %>
                                        —
                                    <% } %>

                                <% } else { %>
                                    Read only
                                <% } %>
                            </td>
                        </tr>
                    <% } %>
                    <% if (allocations.isEmpty()) { %>
                        <tr><td colspan="6" class="empty-message">No active allocations.</td></tr>
                    <% } %>
                    </tbody>
                </table>
            </div>
        </section>

    </div>
</div>
</body>
</html>
