
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register Staff | CityCare Hospital</title>

    <style>
        * {
            box-sizing: border-box;
        }

        body {
            font-family: Arial, sans-serif;
            background: #f4f7fb;
            margin: 0;
            padding: 30px 16px;
            color: #263445;
        }

        .container {
            max-width: 700px;
            margin: auto;
            background: #ffffff;
            padding: 28px;
            border-radius: 10px;
            box-shadow: 0 3px 12px #00000012;
        }

        h1 {
            color: #174a72;
            margin-top: 0;
        }

        .subtitle {
            color: #64748b;
            margin-bottom: 25px;
        }

        .field {
            margin-bottom: 17px;
        }

        label {
            display: block;
            font-weight: bold;
            margin-bottom: 7px;
        }

        input, select {
            width: 100%;
            padding: 11px;
            border: 1px solid #cbd5e1;
            border-radius: 5px;
            font-size: 15px;
            background: #ffffff;
        }

        input:focus, select:focus {
            outline: 2px solid #93c5fd;
            border-color: #2563eb;
        }

        .hint {
            color: #64748b;
            font-size: 13px;
            margin-top: 5px;
        }

        .error {
            background: #fef2f2;
            color: #b91c1c;
            padding: 12px;
            border-radius: 5px;
            margin-bottom: 18px;
        }

        .button-row {
            display: flex;
            align-items: center;
            flex-wrap: wrap;
            gap: 12px;
            margin-top: 25px;
        }

        .submit-button {
            background: #176b4d;
            color: white;
            border: none;
            padding: 12px 18px;
            border-radius: 5px;
            cursor: pointer;
            font-size: 15px;
        }

        .submit-button:hover {
            background: #12563e;
        }

        .submit-button:disabled {
            background: #94a3b8;
            cursor: not-allowed;
        }

        .back {
            color: #174a72;
            text-decoration: none;
            padding: 10px 4px;
        }

        .back:hover {
            text-decoration: underline;
        }

        .required {
            color: #b91c1c;
        }
    </style>
</head>

<body>
<div class="container">

    <h1>Register New Staff</h1>

    <p class="subtitle">
        CityCare Hospital — Enter the staff member's details below.
    </p>

    <c:if test="${not empty errorMessage}">
        <div class="error">
            <c:out value="${errorMessage}"/>
        </div>
    </c:if>

    <form action="${pageContext.request.contextPath}/staff"
          method="post">

        <!-- IMPORTANT: Identifies this request as staff registration -->
        <input type="hidden" name="action" value="create">

        <div class="field">
            <label for="fullName">
                Full Name <span class="required">*</span>
            </label>
            <input
                type="text"
                id="fullName"
                name="fullName"
                maxlength="120"
                required
                placeholder="Enter full name">
        </div>

        <div class="field">
            <label for="departmentId">
                Department <span class="required">*</span>
            </label>

            <select id="departmentId" name="departmentId" required>
                <option value="">-- Select Department --</option>

                <c:forEach var="department" items="${departments}">
                    <option value="${department.departmentId}">
                        <c:out value="${department.departmentName}"/>
                    </option>
                </c:forEach>
            </select>
        </div>

        <div class="field">
            <label for="designation">
                Designation <span class="required">*</span>
            </label>
            <input
                type="text"
                id="designation"
                name="designation"
                maxlength="100"
                required
                placeholder="e.g. Staff Nurse, Lab Technician">
        </div>

        <div class="field">
            <label for="staffType">
                Staff Type <span class="required">*</span>
            </label>

            <select id="staffType" name="staffType" required>
                <option value="NURSE">Nurse</option>
                <option value="RESIDENT">Resident</option>
                <option value="CONSULTANT">Consultant</option>
                <option value="TECHNICIAN">Technician</option>
                <option value="ADMINISTRATIVE">Administrative</option>
                <option value="OTHER" selected>Other</option>
            </select>
        </div>

        <div class="field">
            <label for="phone">Phone</label>
            <input
                type="tel"
                id="phone"
                name="phone"
                maxlength="20"
                placeholder="Enter phone number">
        </div>

        <div class="field">
            <label for="email">Email</label>
            <input
                type="email"
                id="email"
                name="email"
                maxlength="150"
                placeholder="Enter email address">
        </div>

        <p class="hint">
            New staff members are registered with ACTIVE status.
            Supervisor assignments can be configured later.
        </p>

        <div class="button-row">
            <button
                type="submit"
                class="submit-button"
                <c:if test="${empty departments}">disabled</c:if>>
                Register Staff
            </button>

            <a class="back"
               href="${pageContext.request.contextPath}/staff">
                Back to Staff List
            </a>
        </div>

        <c:if test="${empty departments}">
            <div class="error">
                No active departments are available. Activate a department
                before registering staff.
            </div>
        </c:if>

    </form>
</div>
</body>
</html>
