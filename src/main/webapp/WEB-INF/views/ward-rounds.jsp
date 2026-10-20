<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" import="java.util.*,com.hospital.model.WardRound,com.hospital.model.Doctor" %>

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
    List<WardRound> rounds =
        (List<WardRound>) request.getAttribute("rounds");
    List<Doctor> doctors =
        (List<Doctor>) request.getAttribute("doctors");

    Boolean manageValue = (Boolean) request.getAttribute("canManage");
    boolean canManage = Boolean.TRUE.equals(manageValue);

    if (rounds == null) rounds = new ArrayList<>();
    if (doctors == null) doctors = new ArrayList<>();

    String message = (String) session.getAttribute("wardRoundMessage");
    if (message != null) session.removeAttribute("wardRoundMessage");

    String ctx = request.getContextPath();
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Ward Rounds | CityCare Hospital</title>

<style>
* { box-sizing: border-box; }

body {
    margin: 0;
    font-family: Arial, Helvetica, sans-serif;
    background: #f3f6fb;
    color: #1e293b;
}

header {
    background: #123b68;
    color: white;
    padding: 22px 5%;
}

header h1 { margin: 0 0 6px; font-size: 25px; }
header p { margin: 0; color: #d8e8fa; }

.container {
    max-width: 1250px;
    margin: 28px auto;
    padding: 0 20px;
}

.topbar {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 12px;
    flex-wrap: wrap;
    margin-bottom: 22px;
}

a.back {
    display: inline-block;
    padding: 10px 15px;
    border-radius: 7px;
    background: #e2e8f0;
    color: #263445;
    text-decoration: none;
    font-weight: bold;
    transition: background 0.2s ease;
}

a.back:hover {
    background: #cbd5e1;
}

.card {
    background: white;
    border-radius: 12px;
    padding: 22px;
    margin-bottom: 24px;
    box-shadow: 0 4px 18px rgba(15, 35, 65, .06);
}

.card h2 { margin: 0 0 18px; font-size: 20px; }

.message {
    background: #e8f5e9;
    border: 1px solid #a5d6a7;
    color: #245d2a;
    border-radius: 8px;
    padding: 12px 15px;
    margin-bottom: 18px;
}

.form-grid {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 16px;
}

.field { display: flex; flex-direction: column; gap: 7px; }
.field.full { grid-column: 1 / -1; }

label { font-size: 13px; font-weight: bold; color: #475569; }

input, select, textarea {
    width: 100%;
    border: 1px solid #cbd5e1;
    border-radius: 7px;
    padding: 11px;
    font: inherit;
    background: white;
}

textarea { min-height: 85px; resize: vertical; }

button, .button {
    border: 0;
    border-radius: 7px;
    padding: 10px 15px;
    font-weight: bold;
    cursor: pointer;
    text-decoration: none;
    display: inline-block;
    font-size: 13px;
}

.primary { background: #1769aa; color: white; }
.secondary { background: #e7eef7; color: #23476d; }

.table-wrap { overflow-x: auto; }

table {
    width: 100%;
    border-collapse: collapse;
    min-width: 850px;
}

th, td {
    text-align: left;
    padding: 13px 12px;
    border-bottom: 1px solid #e7edf4;
    vertical-align: top;
    font-size: 13px;
}

th {
    background: #f7f9fc;
    color: #52647a;
    font-size: 12px;
    text-transform: uppercase;
}

.status {
    display: inline-block;
    border-radius: 20px;
    padding: 5px 9px;
    background: #e8eef7;
    color: #334b68;
    font-size: 11px;
    font-weight: bold;
    white-space: nowrap;
}

.status.COMPLETED { background: #dcfce7; color: #166534; }
.status.IN_PROGRESS { background: #dbeafe; color: #1d4ed8; }
.status.CANCELLED { background: #fee2e2; color: #991b1b; }
.status.PLANNED { background: #fef3c7; color: #92400e; }

.status-form { display: flex; gap: 6px; align-items: center; }
.status-form select { min-width: 135px; padding: 7px; }

.empty { padding: 28px; text-align: center; color: #64748b; }

@media (max-width: 650px) {
    .form-grid { grid-template-columns: 1fr; }
    .field.full { grid-column: auto; }
    .card { padding: 16px; }
}
</style>
</head>

<body>

<header>
    <h1>Ward Rounds Management</h1>
    <p>CityCare Hospital · Clinical Operations</p>
</header>

<main class="container">

    <div class="topbar">
        <div>
            <h2 style="margin:0 0 6px;">Ward Rounds</h2>
            <span style="color:#64748b;font-size:14px;">
                Schedule rounds and monitor their progress.
            </span>
        </div>
        <a class="back" href="<%= ctx %>/dashboard">← Back to Dashboard</a>
    </div>

    <% if (message != null && !message.isBlank()) { %>
        <div class="message"><%= esc(message) %></div>
    <% } %>

    <% if (canManage) { %>
    <section class="card">
        <h2>Schedule a Ward Round</h2>

        <form method="post" action="<%= ctx %>/ward-rounds">
            <input type="hidden" name="action" value="add">

            <div class="form-grid">

                <div class="field">
                    <label for="doctorId">Doctor *</label>
                    <select id="doctorId" name="doctorId" required>
                        <option value="">Select doctor</option>
                        <% for (Doctor doctor : doctors) { %>
                            <option value="<%= doctor.getDoctorId() %>">
                                <%= esc(doctor.getFullName()) %>
                            </option>
                        <% } %>
                    </select>
                </div>

                <div class="field">
                    <label for="wardName">Ward Name *</label>
                    <input id="wardName" name="wardName" maxlength="100"
                           placeholder="e.g. General Ward A" required>
                </div>

                <div class="field">
                    <label for="roundDate">Round Date *</label>
                    <input type="date" id="roundDate" name="roundDate"
                           required>
                </div>

                <div class="field">
                    <label for="startTime">Start Time *</label>
                    <input type="time" id="startTime" name="startTime"
                           required>
                </div>

                <div class="field">
                    <label for="endTime">End Time *</label>
                    <input type="time" id="endTime" name="endTime"
                           required>
                </div>

                <div class="field full">
                    <label for="notes">Notes</label>
                    <textarea id="notes" name="notes" maxlength="5000"
                              placeholder="Round instructions or observations"></textarea>
                </div>

                <div class="field full">
                    <button class="primary" type="submit">
                        + Schedule Ward Round
                    </button>
                </div>

            </div>
        </form>
    </section>
    <% } %>

    <section class="card">
        <h2>Scheduled and Previous Rounds</h2>

        <div class="table-wrap">
            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Date &amp; Time</th>
                        <th>Doctor</th>
                        <th>Ward</th>
                        <th>Notes</th>
                        <th>Status</th>
                        <% if (canManage) { %>
                            <th>Update Status</th>
                        <% } %>
                    </tr>
                </thead>

                <tbody>
                <% if (rounds.isEmpty()) { %>
                    <tr>
                        <td colspan="<%= canManage ? 7 : 6 %>" class="empty">
                            No ward rounds found. Schedule the first round above.
                        </td>
                    </tr>
                <% } else { %>

                    <% for (WardRound round : rounds) { %>
                    <tr>
                        <td>#<%= round.getWardRoundId() %></td>

                        <td>
                            <strong><%= esc(round.getRoundDate()) %></strong><br>
                            <%= round.getStartTime() == null ? "—" :
                                esc(round.getStartTime().toString().substring(0, 5)) %>
                            –
                            <%= round.getEndTime() == null ? "—" :
                                esc(round.getEndTime().toString().substring(0, 5)) %>
                        </td>

                        <td>
                            <%
                                String doctorName = "Doctor ID: " + round.getDoctorId();
                                for (Doctor d : doctors) {
                                    if (d.getDoctorId() == round.getDoctorId()) {
                                        doctorName = d.getFullName();
                                        break;
                                    }
                                }
                            %>
                            <%= esc(doctorName) %>
                        </td>

                        <td><%= esc(round.getWardName()) %></td>
                        <td><%= esc(round.getNotes()) %></td>

                        <td>
                            <span class="status <%= esc(round.getRoundStatus()) %>">
                                <%= esc(round.getRoundStatus()) %>
                            </span>
                        </td>

                        <% if (canManage) { %>
                        <td>
                            <form class="status-form" method="post"
                                  action="<%= ctx %>/ward-rounds">
                                <input type="hidden" name="action"
                                       value="updateStatus">
                                <input type="hidden" name="wardRoundId"
                                       value="<%= round.getWardRoundId() %>">

                                <select name="roundStatus" aria-label="Round status">
                                    <option value="PLANNED"
                                        <%= "PLANNED".equals(round.getRoundStatus()) ? "selected" : "" %>>
                                        Planned
                                    </option>
                                    <option value="IN_PROGRESS"
                                        <%= "IN_PROGRESS".equals(round.getRoundStatus()) ? "selected" : "" %>>
                                        In Progress
                                    </option>
                                    <option value="COMPLETED"
                                        <%= "COMPLETED".equals(round.getRoundStatus()) ? "selected" : "" %>>
                                        Completed
                                    </option>
                                    <option value="CANCELLED"
                                        <%= "CANCELLED".equals(round.getRoundStatus()) ? "selected" : "" %>>
                                        Cancelled
                                    </option>
                                </select>

                                <button class="primary" type="submit">Save</button>
                            </form>
                        </td>
                        <% } %>
                    </tr>
                    <% } %>

                <% } %>
                </tbody>
            </table>
        </div>
    </section>

</main>

<script>
(function () {
    const dateInput = document.getElementById("roundDate");

    if (dateInput) {
        const today = new Date();
        const localDate = new Date(
            today.getTime() - today.getTimezoneOffset() * 60000
        ).toISOString().slice(0, 10);

        dateInput.min = localDate;
        dateInput.value = localDate;
    }

    const startInput = document.getElementById("startTime");
    const endInput = document.getElementById("endTime");

    if (startInput && endInput) {
        startInput.addEventListener("change", function () {
            endInput.min = startInput.value;

            if (endInput.value && endInput.value <= startInput.value) {
                endInput.value = "";
            }
        });
    }
})();
</script>

</body>
</html>
