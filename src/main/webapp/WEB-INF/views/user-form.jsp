
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Create User - Hospital Management System</title>

    <style>
        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            padding: 25px;
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            font-family: Arial, sans-serif;
            background: #eef3f8;
            color: #243247;
        }

        .card {
            width: 100%;
            max-width: 520px;
            padding: 32px;
            background: white;
            border-radius: 12px;
            box-shadow: 0 6px 24px rgba(0, 0, 0, 0.08);
        }

        h1 {
            margin-top: 0;
            color: #1261a0;
            font-size: 25px;
        }

        .description {
            color: #64748b;
            font-size: 14px;
            line-height: 1.5;
            margin-bottom: 24px;
        }

        label {
            display: block;
            margin: 18px 0 7px;
            font-weight: bold;
            font-size: 14px;
        }

        input, select {
            width: 100%;
            padding: 12px;
            border: 1px solid #cbd5e1;
            border-radius: 6px;
            background: white;
            font-size: 15px;
        }

        input:focus, select:focus {
            outline: 2px solid #9bc9f0;
            border-color: #1261a0;
        }

        .hint {
            display: block;
            margin-top: 6px;
            color: #64748b;
            font-size: 12px;
        }

        .error {
            padding: 12px;
            margin-bottom: 16px;
            color: #991b1b;
            background: #fee2e2;
            border-radius: 6px;
            font-size: 14px;
        }

        .success {
            padding: 12px;
            margin-bottom: 16px;
            color: #166534;
            background: #dcfce7;
            border-radius: 6px;
            font-size: 14px;
        }

        .buttons {
            display: flex;
            gap: 12px;
            margin-top: 25px;
        }

        button, .back {
            flex: 1;
            padding: 12px;
            border: none;
            border-radius: 6px;
            text-align: center;
            text-decoration: none;
            font-size: 14px;
            font-weight: bold;
            cursor: pointer;
        }

        button {
            background: #1261a0;
            color: white;
        }

        button:hover {
            background: #0b497b;
        }

        .back {
            background: #e2e8f0;
            color: #243247;
        }
    </style>
</head>

<body>

<div class="card">

    <h1>Create User Account</h1>

    <p class="description">
        Create an account for an administrator, doctor, staff member,
        or receptionist.
    </p>

    <c:if test="${not empty param.created}">
        <div class="success">
            User account created successfully.
        </div>
    </c:if>

    <c:if test="${not empty errorMessage}">
        <div class="error">
            <c:out value="${errorMessage}"/>
        </div>
    </c:if>

    <form action="${pageContext.request.contextPath}/users"
          method="post">

        <label for="username">Username</label>

        <input type="text"
               id="username"
               name="username"
               minlength="3"
               maxlength="60"
               pattern="[A-Za-z0-9._-]+"
               autocomplete="off"
               value="<c:out value='${enteredUsername}'/>"
               required>

        <span class="hint">
            Use 3–60 letters, numbers, dots, underscores, or hyphens.
        </span>

        <label for="password">Temporary Password</label>

        <input type="password"
               id="password"
               name="password"
               minlength="12"
               maxlength="72"
               autocomplete="new-password"
               required>

        <span class="hint">
            Use at least 12 characters. Share temporary passwords securely.
        </span>

        <label for="role">User Role</label>

        <select id="role" name="role" required>
            <option value="">-- Select a role --</option>
            <option value="ADMIN">Administrator</option>
            <option value="DOCTOR">Doctor</option>
            <option value="STAFF">Staff</option>
            <option value="RECEPTIONIST">Receptionist</option>
        </select>

        <div class="buttons">
            <a class="back"
               href="${pageContext.request.contextPath}/dashboard">
                Back to Dashboard
            </a>

            <button type="submit">Create Account</button>
        </div>

    </form>

</div>

</body>
</html>
