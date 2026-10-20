
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Doctor</title>

    <style>
        body {
            margin: 0;
            padding: 25px;
            font-family: Arial, sans-serif;
            background: #f4f7fb;
            color: #263445;
        }

        .container {
            max-width: 750px;
            margin: 20px auto;
            padding: 28px;
            background: white;
            border-radius: 10px;
            box-shadow: 0 3px 12px #0000000d;
        }

        h1 {
            color: #173b63;
            margin-top: 0;
        }

        .form-group {
            margin-bottom: 17px;
        }

        label {
            display: block;
            margin-bottom: 7px;
            font-weight: bold;
        }

        input, select {
            width: 100%;
            padding: 11px;
            border: 1px solid #cbd5e1;
            border-radius: 5px;
            font-size: 15px;
            background: white;
        }

        .actions {
            display: flex;
            gap: 10px;
            margin-top: 25px;
        }

        .button {
            padding: 11px 17px;
            border: none;
            border-radius: 5px;
            text-decoration: none;
            cursor: pointer;
            font-size: 14px;
        }

        .primary {
            background: #1769aa;
            color: white;
        }

        .secondary {
            background: #e7edf4;
            color: #263445;
        }
    </style>
</head>

<body>
<div class="container">

    <h1>Edit Doctor</h1>

    <form method="post"
          action="${pageContext.request.contextPath}/doctors">

        <input type="hidden" name="action" value="update">

        <input type="hidden" name="doctorId"
               value="${doctor.doctorId}">

        <div class="form-group">
            <label>Doctor ID</label>
            <input type="text" value="${doctor.doctorId}" readonly>
        </div>

        <div class="form-group">
            <label for="fullName">Full Name *</label>
            <input type="text" id="fullName" name="fullName"
                   maxlength="120"
                   value="<c:out value='${doctor.fullName}'/>"
                   required>
        </div>

        <div class="form-group">
            <label for="departmentId">Department *</label>
            <select id="departmentId" name="departmentId" required>
                <option value="">-- Select Department --</option>

                <c:forEach var="department" items="${departments}">
                    <option value="${department.departmentId}"
                        <c:if test="${department.departmentId == doctor.departmentId}">
                            selected
                        </c:if>>
                        <c:out value="${department.departmentName}"/>
                    </option>
                </c:forEach>
            </select>
        </div>

        <div class="form-group">
            <label for="specialization">Specialization *</label>
            <input type="text" id="specialization"
                   name="specialization" maxlength="120"
                   value="<c:out value='${doctor.specialization}'/>"
                   required>
        </div>

        <div class="form-group">
            <label for="qualification">Qualification</label>
            <input type="text" id="qualification"
                   name="qualification" maxlength="200"
                   value="<c:out value='${doctor.qualification}'/>">
        </div>

        <div class="form-group">
            <label for="phone">Phone</label>
            <input type="tel" id="phone" name="phone"
                   maxlength="20"
                   value="<c:out value='${doctor.phone}'/>">
        </div>

        <div class="form-group">
            <label for="email">Email</label>
            <input type="email" id="email" name="email"
                   maxlength="150"
                   value="<c:out value='${doctor.email}'/>">
        </div>

        <div class="form-group">
            <label for="employmentStatus">Employment Status *</label>
            <select id="employmentStatus" name="employmentStatus" required>
                <option value="ACTIVE"
                    <c:if test="${doctor.employmentStatus == 'ACTIVE'}">
                        selected
                    </c:if>>
                    Active
                </option>

                <option value="ON_LEAVE"
                    <c:if test="${doctor.employmentStatus == 'ON_LEAVE'}">
                        selected
                    </c:if>>
                    On Leave
                </option>

                <option value="INACTIVE"
                    <c:if test="${doctor.employmentStatus == 'INACTIVE'}">
                        selected
                    </c:if>>
                    Inactive
                </option>
            </select>
        </div>

        <div class="actions">
            <button type="submit" class="button primary">
                Save Changes
            </button>

            <a class="button secondary"
               href="${pageContext.request.contextPath}/doctors">
                Cancel
            </a>
        </div>

    </form>

</div>
</body>
</html>
