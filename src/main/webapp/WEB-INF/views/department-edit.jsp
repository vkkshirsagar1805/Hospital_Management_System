
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Edit Department | CityCare Hospital</title>

    <style>
        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            padding: 30px 15px;
            font-family: Arial, sans-serif;
            background: #f3f6fa;
            color: #243247;
        }

        .container {
            max-width: 650px;
            margin: 0 auto;
        }

        .header {
            background: #123b63;
            color: white;
            padding: 24px;
            border-radius: 10px 10px 0 0;
        }

        .header h1 {
            margin: 0 0 8px;
        }

        .header p {
            margin: 0;
            color: #dce9f5;
        }

        .form-panel {
            background: white;
            padding: 25px;
            border-radius: 0 0 10px 10px;
            box-shadow: 0 3px 12px rgba(0, 0, 0, 0.07);
        }

        .form-group {
            margin-bottom: 18px;
        }

        label {
            display: block;
            font-weight: bold;
            margin-bottom: 7px;
        }

        input, textarea, select {
            width: 100%;
            padding: 11px;
            border: 1px solid #cbd5e1;
            border-radius: 6px;
            font-size: 15px;
            font-family: inherit;
        }

        textarea {
            min-height: 100px;
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

        button:hover {
            background: #1d527f;
        }

        .back-link {
            background: #e2e8f0;
            color: #243247;
        }

        @media (max-width: 480px) {
            .actions {
                flex-direction: column;
            }
        }
    </style>
</head>

<body>
    <div class="container">

        <header class="header">
            <h1>CityCare Hospital</h1>
            <p>Hospital Management &amp; Emergency Coordination</p>
        </header>

        <main class="form-panel">
            <h2>Edit Department</h2>
            <p>Update the department information below.</p>

            <form method="post"
                  action="${pageContext.request.contextPath}/departments/update">

                <input type="hidden"
                       name="departmentId"
                       value="<c:out value='${department.departmentId}'/>">

                <div class="form-group">
                    <label for="departmentName">Department Name *</label>

                    <input type="text"
                           id="departmentName"
                           name="departmentName"
                           maxlength="100"
                           required
                           value="<c:out value='${department.departmentName}'/>">
                </div>

                <div class="form-group">
                    <label for="description">Description</label>

                    <textarea id="description"
                              name="description"
                              maxlength="500"><c:out value="${department.description}"/></textarea>
                </div>

                <div class="form-group">
                    <label for="location">Location</label>

                    <input type="text"
                           id="location"
                           name="location"
                           maxlength="150"
                           value="<c:out value='${department.location}'/>">
                </div>

                <div class="form-group">
                    <label for="status">Status</label>

                    <select id="status" name="status">
                        <option value="ACTIVE"
                            ${department.status == 'ACTIVE' ? 'selected' : ''}>
                            Active
                        </option>

                        <option value="INACTIVE"
                            ${department.status == 'INACTIVE' ? 'selected' : ''}>
                            Inactive
                        </option>
                    </select>
                </div>

                <div class="actions">
                    <button type="submit">Save Changes</button>

                    <a class="back-link"
                       href="${pageContext.request.contextPath}/departments">
                        Cancel
                    </a>
                </div>
            </form>
        </main>
    </div>
</body>
</html>
