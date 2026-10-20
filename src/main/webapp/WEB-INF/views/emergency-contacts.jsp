
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"
    import="java.util.*,com.hospital.model.EmergencyContact" %>

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
    List<EmergencyContact> contacts =
        (List<EmergencyContact>) request.getAttribute("contacts");

    if (contacts == null) contacts = new ArrayList<>();

    boolean canManage =
        Boolean.TRUE.equals(request.getAttribute("canManage"));

    EmergencyContact editContact =
        (EmergencyContact) request.getAttribute("editContact");

    String message =
        (String) session.getAttribute("emergencyContactMessage");

    if (message != null) {
        session.removeAttribute("emergencyContactMessage");
    }

    String ctx = request.getContextPath();

    String formAction = editContact == null ? "add" : "update";
    String formTitle = editContact == null
        ? "Add Emergency Contact" : "Edit Emergency Contact";
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Emergency Contacts | CityCare Hospital</title>

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

a {
    color: #175a91;
    text-decoration: none;
}

.back {
    display: inline-block;
    padding: 10px 15px;
    border-radius: 7px;
    background: #e2e8f0;
    color: #263445;
    font-weight: bold;
    transition: background 0.2s ease;
}

.back:hover {
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

label {
    font-size: 13px;
    font-weight: bold;
    color: #475569;
}

input, select, textarea {
    width: 100%;
    border: 1px solid #cbd5e1;
    border-radius: 7px;
    padding: 11px;
    font: inherit;
    background: white;
}

textarea { min-height: 75px; resize: vertical; }

button, .button {
    border: 0;
    border-radius: 7px;
    padding: 10px 14px;
    font-weight: bold;
    cursor: pointer;
    font-size: 13px;
    display: inline-block;
}

.primary { background: #1769aa; color: white; }
.secondary { background: #e7eef7; color: #23476d; }
.danger { background: #fee2e2; color: #991b1b; }
.success { background: #dcfce7; color: #166534; }

.table-wrap { overflow-x: auto; }

table {
    width: 100%;
    min-width: 850px;
    border-collapse: collapse;
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

.badge {
    display: inline-block;
    border-radius: 20px;
    padding: 5px 9px;
    background: #e8eef7;
    color: #334b68;
    font-size: 11px;
    font-weight: bold;
}

.badge.ACTIVE { background: #dcfce7; color: #166534; }
.badge.INACTIVE { background: #fee2e2; color: #991b1b; }

.actions { display: flex; gap: 7px; flex-wrap: wrap; }
.inline-form { display: inline; }
.empty { text-align: center; padding: 28px; color: #64748b; }

@media (max-width: 650px) {
    .form-grid { grid-template-columns: 1fr; }
    .field.full { grid-column: auto; }
    .card { padding: 16px; }
}
</style>
</head>

<body>

<header>
    <h1>Emergency Contacts</h1>
    <p>CityCare Hospital · Emergency Assistance</p>
</header>

<main class="container">

    <div class="topbar">
        <div>
            <h2 style="margin:0 0 6px;">Emergency Directory</h2>
            <span style="color:#64748b;font-size:14px;">
                Quickly find important emergency contact information.
            </span>
        </div>
        <a class="back" href="<%= ctx %>/dashboard">← Back to Dashboard</a>
    </div>

    <% if (message != null && !message.isBlank()) { %>
        <div class="message"><%= esc(message) %></div>
    <% } %>

    <% if (canManage) { %>
    <section class="card">
        <h2><%= formTitle %></h2>

        <form method="post" action="<%= ctx %>/emergency-contacts">
            <input type="hidden" name="action" value="<%= formAction %>">

            <% if (editContact != null) { %>
                <input type="hidden" name="contactId"
                       value="<%= editContact.getContactId() %>">
            <% } %>

            <div class="form-grid">

                <div class="field">
                    <label for="contactName">Contact Name *</label>
                    <input id="contactName" name="contactName"
                           maxlength="150" required
                           value="<%= editContact == null ? "" :
                               esc(editContact.getContactName()) %>">
                </div>

                <div class="field">
                    <label for="contactType">Contact Type *</label>
                    <select id="contactType" name="contactType" required>
                        <%
                            String[] types = {
                                "HOSPITAL", "AMBULANCE_SERVICE", "FIRE",
                                "POLICE", "BLOOD_BANK", "OTHER"
                            };
                            for (String type : types) {
                                boolean selected = editContact != null
                                    && type.equals(editContact.getContactType());
                        %>
                            <option value="<%= type %>"
                                <%= selected ? "selected" : "" %>>
                                <%= type.replace('_', ' ') %>
                            </option>
                        <% } %>
                    </select>
                </div>

                <div class="field">
                    <label for="phone">Primary Phone *</label>
                    <input id="phone" name="phone" maxlength="25"
                           pattern="[0-9+() .-]{5,25}" required
                           value="<%= editContact == null ? "" :
                               esc(editContact.getPhone()) %>">
                </div>

                <div class="field">
                    <label for="alternatePhone">Alternate Phone</label>
                    <input id="alternatePhone" name="alternatePhone"
                           maxlength="25" pattern="[0-9+() .-]{5,25}"
                           value="<%= editContact == null ? "" :
                               esc(editContact.getAlternatePhone()) %>">
                </div>

                <div class="field">
                    <label for="operatingHours">Operating Hours</label>
                    <input id="operatingHours" name="operatingHours"
                           maxlength="100"
                           placeholder="e.g. 24 hours"
                           value="<%= editContact == null ? "" :
                               esc(editContact.getOperatingHours()) %>">
                </div>

                <div class="field">
                    <label for="address">Address</label>
                    <input id="address" name="address" maxlength="300"
                           value="<%= editContact == null ? "" :
                               esc(editContact.getAddress()) %>">
                </div>

                <div class="field full">
                    <label for="notes">Notes</label>
                    <textarea id="notes" name="notes"
                              maxlength="500"><%= editContact == null ? "" :
                                  esc(editContact.getNotes()) %></textarea>
                </div>

                <div class="field full">
                    <div class="actions">
                        <button class="primary" type="submit">
                            <%= editContact == null ? "Add Contact" :
                                "Save Changes" %>
                        </button>

                        <% if (editContact != null) { %>
                            <a class="button secondary"
                               href="<%= ctx %>/emergency-contacts">
                                Cancel Editing
                            </a>
                        <% } %>
                    </div>
                </div>

            </div>
        </form>
    </section>
    <% } %>

    <section class="card">
        <h2>Contact Directory</h2>

        <div class="table-wrap">
            <table>
                <thead>
                    <tr>
                        <th>Name / Type</th>
                        <th>Phone Numbers</th>
                        <th>Operating Hours</th>
                        <th>Address / Notes</th>
                        <th>Status</th>
                        <% if (canManage) { %>
                            <th>Actions</th>
                        <% } %>
                    </tr>
                </thead>

                <tbody>
                <% if (contacts.isEmpty()) { %>
                    <tr>
                        <td colspan="<%= canManage ? 6 : 5 %>" class="empty">
                            No emergency contacts found.
                        </td>
                    </tr>
                <% } else { %>
                    <% for (EmergencyContact contact : contacts) { %>
                    <tr>
                        <td>
                            <strong><%= esc(contact.getContactName()) %></strong>
                            <br>
                            <span style="color:#64748b;">
                                <%= esc(contact.getContactType().replace('_', ' ')) %>
                            </span>
                        </td>

                        <td>
                            <a href="tel:<%= esc(contact.getPhone()) %>">
                                <%= esc(contact.getPhone()) %>
                            </a>

                            <% if (contact.getAlternatePhone() != null
                                   && !contact.getAlternatePhone().isBlank()) { %>
                                <br>
                                <span style="color:#64748b;">Alternate:</span>
                                <a href="tel:<%= esc(contact.getAlternatePhone()) %>">
                                    <%= esc(contact.getAlternatePhone()) %>
                                </a>
                            <% } %>
                        </td>

                        <td>
                            <%= contact.getOperatingHours() == null
                                || contact.getOperatingHours().isBlank()
                                ? "Not specified"
                                : esc(contact.getOperatingHours()) %>
                        </td>

                        <td>
                            <%= contact.getAddress() == null
                                || contact.getAddress().isBlank()
                                ? "—" : esc(contact.getAddress()) %>

                            <% if (contact.getNotes() != null
                                   && !contact.getNotes().isBlank()) { %>
                                <br><span style="color:#64748b;">
                                    <%= esc(contact.getNotes()) %>
                                </span>
                            <% } %>
                        </td>

                        <td>
                            <span class="badge <%= esc(contact.getContactStatus()) %>">
                                <%= esc(contact.getContactStatus()) %>
                            </span>
                        </td>

                        <% if (canManage) { %>
                        <td>
                            <div class="actions">
                                <a class="button secondary"
                                   href="<%= ctx %>/emergency-contacts?editId=<%= contact.getContactId() %>">
                                    Edit
                                </a>

                                <form class="inline-form" method="post"
                                      action="<%= ctx %>/emergency-contacts">
                                    <input type="hidden" name="action"
                                           value="updateStatus">
                                    <input type="hidden" name="contactId"
                                           value="<%= contact.getContactId() %>">
                                    <input type="hidden" name="contactStatus"
                                           value="<%= "ACTIVE".equals(contact.getContactStatus())
                                               ? "INACTIVE" : "ACTIVE" %>">

                                    <button type="submit"
                                        class="<%= "ACTIVE".equals(contact.getContactStatus())
                                            ? "danger" : "success" %>">
                                        <%= "ACTIVE".equals(contact.getContactStatus())
                                            ? "Deactivate" : "Activate" %>
                                    </button>
                                </form>
                            </div>
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
</body>
</html>
