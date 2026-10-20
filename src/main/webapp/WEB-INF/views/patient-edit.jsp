
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Patient | CityCare Hospital</title>

    <style>
        * { box-sizing: border-box; }

        body {
            margin: 0;
            padding: 30px 15px;
            font-family: Arial, sans-serif;
            background: #f3f6fa;
            color: #243247;
        }

        .container {
            max-width: 750px;
            margin: auto;
        }

        .header {
            background: #123b63;
            color: white;
            padding: 24px;
            border-radius: 10px 10px 0 0;
        }

        .header h1 { margin: 0 0 8px; }
        .header p { margin: 0; color: #dce9f5; }

        .panel {
            background: white;
            padding: 25px;
            border-radius: 0 0 10px 10px;
            box-shadow: 0 3px 12px rgba(0, 0, 0, 0.07);
        }

        .form-group { margin-bottom: 18px; }

        label {
            display: block;
            font-weight: bold;
            margin-bottom: 7px;
        }

        input, select, textarea {
            width: 100%;
            padding: 11px;
            border: 1px solid #cbd5e1;
            border-radius: 6px;
            font-size: 15px;
            font-family: inherit;
        }

        textarea {
            min-height: 90px;
            resize: vertical;
        }

        .actions {
            display: flex;
            gap: 12px;
            margin-top: 25px;
        }

        button, .back-link {
            display: inline-block;
            padding: 12px 18px;
            border: none;
            border-radius: 6px;
            text-decoration: none;
            font-size: 15px;
            cursor: pointer;
        }

        button {
            background: #123b63;
            color: white;
        }

        .back-link {
            background: #e2e8f0;
            color: #243247;
        }

        @media (max-width: 480px) {
            .actions { flex-direction: column; }
        }
    </style>
</head>

<body>
<div class="container">

    <header class="header">
        <h1>CityCare Hospital</h1>
        <p>Hospital Management &amp; Emergency Coordination</p>
    </header>

    <main class="panel">
        <h2>Edit Patient</h2>
        <p>Update the patient's information below.</p>

        <form method="post"
              action="${pageContext.request.contextPath}/patients">

            <input type="hidden" name="action" value="update">

            <input type="hidden" name="patientId"
                   value="<c:out value='${patient.patientId}'/>">

            <div class="form-group">
                <label for="fullName">Full Name *</label>
                <input type="text" id="fullName" name="fullName"
                       maxlength="120" required
                       value="<c:out value='${patient.fullName}'/>">
            </div>

            <div class="form-group">
                <label for="dateOfBirth">Date of Birth</label>
                <input type="date" id="dateOfBirth" name="dateOfBirth"
                       value="<c:out value='${patient.dateOfBirth}'/>">
            </div>

            <div class="form-group">
                <label for="gender">Gender *</label>
                <select id="gender" name="gender" required>
                    <option value="UNSPECIFIED"
                        ${patient.gender == 'UNSPECIFIED' ? 'selected' : ''}>
                        Unspecified
                    </option>
                    <option value="MALE"
                        ${patient.gender == 'MALE' ? 'selected' : ''}>
                        Male
                    </option>
                    <option value="FEMALE"
                        ${patient.gender == 'FEMALE' ? 'selected' : ''}>
                        Female
                    </option>
                    <option value="OTHER"
                        ${patient.gender == 'OTHER' ? 'selected' : ''}>
                        Other
                    </option>
                </select>
            </div>

            <div class="form-group">
                <label for="phone">Phone</label>
                <input type="tel" id="phone" name="phone"
                       maxlength="20"
                       value="<c:out value='${patient.phone}'/>">
            </div>

            <div class="form-group">
                <label for="email">Email</label>
                <input type="email" id="email" name="email"
                       maxlength="150"
                       value="<c:out value='${patient.email}'/>">
            </div>

            <div class="form-group">
                <label for="address">Address</label>
                <textarea id="address" name="address"
                          maxlength="500"><c:out value="${patient.address}"/></textarea>
            </div>

            <div class="form-group">
                <label for="recordStatus">Record Status</label>
                <select id="recordStatus" name="recordStatus">
                    <option value="ACTIVE"
                        ${patient.recordStatus == 'ACTIVE' ? 'selected' : ''}>
                        Active
                    </option>
                    <option value="INACTIVE"
                        ${patient.recordStatus == 'INACTIVE' ? 'selected' : ''}>
                        Inactive
                    </option>
                </select>
            </div>

            <div class="actions">
                <button type="submit">Save Changes</button>

                <a class="back-link"
                   href="${pageContext.request.contextPath}/patients">
                    Cancel
                </a>
            </div>
        </form>
    </main>
</div>
</body>
</html>
