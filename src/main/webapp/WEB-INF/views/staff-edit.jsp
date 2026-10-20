
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Staff | CityCare Hospital</title>

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

        .required {
            color: #b91c1c;
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

        button {
            background: #2563eb;
            color: #ffffff;
            border: none;
            padding: 12px 18px;
            border-radius: 5px;
            cursor: pointer;
            font-size: 15px;
        }

        button:hover {
            background: #1d4ed8;
        }

        .back {
            color: #174a72;
            text-decoration: none;
            padding: 10px 4px;
        }

        .back:hover {
            text-decoration: underline;
        }
    </style>
</head>

<body>
<div class="container">

    <h1>Edit Staff Member</h1>

    <p class="subtitle">
        CityCare Hospital — Update the staff member's details.
    </p>

    <c:if test="${not empty errorMessage}">
        <div class="error">
            <c:out value="${errorMessage}"/>
        </div>
    </c:if>

    <c:choose>
        <c:when test="${not empty staff}">
            <form action="${pageContext.request.contextPath}/staff"
                  method="post">

                <!-- Identifies this request as an update -->
                <input type="hidden" name="action" value="update">

                <!-- Staff ID required by StaffServlet.doPost() -->
                <input type="hidden" name="staffId"
                       value="<c:out value='${staff.staffId}'/>">

                <div class="field">
                    <label for="fullName">
                        Full Name <span class="required">*</span>
                    </label>
                    <input type="text"
                           id="fullName"
                           name="fullName"
                           maxlength="120"
                           required
                           value="<c:out value='${staff.fullName}'/>">
                </div>

                <div class="field">
                    <label for="departmentId">
                        Department <span class="required">*</span>
                    </label>

                    <select id="departmentId"
                            name="departmentId"
                            required>
                        <option value="">-- Select Department --</option>

                        <c:forEach var="department" items="${departments}">
                            <option value="${department.departmentId}"
                                <c:if test="${department.departmentId == staff.departmentId}">
                                    selected
                                </c:if>>
                                <c:out value="${department.departmentName}"/>
                            </option>
                        </c:forEach>
                    </select>
                </div>

                <div class="field">
                    <label for="designation">
                        Designation <span class="required">*</span>
                    </label>
                    <input type="text"
                           id="designation"
                           name="designation"
                           maxlength="100"
                           required
                           value="<c:out value='${staff.designation}'/>">
                </div>

                <div class="field">
                    <label for="staffType">
                        Staff Type <span class="required">*</span>
                    </label>

                    <select id="staffType" name="staffType" required>
                        <option value="NURSE"
                            <c:if test="${staff.staffType == 'NURSE'}">selected</c:if>>
                            Nurse
                        </option>
                        <option value="RESIDENT"
                            <c:if test="${staff.staffType == 'RESIDENT'}">selected</c:if>>
                            Resident
                        </option>
                        <option value="CONSULTANT"
                            <c:if test="${staff.staffType == 'CONSULTANT'}">selected</c:if>>
                            Consultant
                        </option>
                        <option value="TECHNICIAN"
                            <c:if test="${staff.staffType == 'TECHNICIAN'}">selected</c:if>>
                            Technician
                        </option>
                        <option value="ADMINISTRATIVE"
                            <c:if test="${staff.staffType == 'ADMINISTRATIVE'}">selected</c:if>>
                            Administrative
                        </option>
                        <option value="OTHER"
                            <c:if test="${staff.staffType == 'OTHER'}">selected</c:if>>
                            Other
                        </option>
                    </select>
                </div>

                <div class="field">
                    <label for="phone">Phone</label>
                    <input type="tel"
                           id="phone"
                           name="phone"
                           maxlength="20"
                           value="<c:out value='${staff.phone}'/>">
                </div>

                <div class="field">
                    <label for="email">Email</label>
                    <input type="email"
                           id="email"
                           name="email"
                           maxlength="150"
                           value="<c:out value='${staff.email}'/>">
                </div>

                <div class="field">
                    <label for="employmentStatus">
                        Employment Status <span class="required">*</span>
                    </label>

                    <select id="employmentStatus"
                            name="employmentStatus"
                            required>
                        <option value="ACTIVE"
                            <c:if test="${staff.employmentStatus == 'ACTIVE'}">selected</c:if>>
                            Active
                        </option>
                        <option value="ON_LEAVE"
                            <c:if test="${staff.employmentStatus == 'ON_LEAVE'}">selected</c:if>>
                            On Leave
                        </option>
                        <option value="INACTIVE"
                            <c:if test="${staff.employmentStatus == 'INACTIVE'}">selected</c:if>>
                            Inactive
                        </option>
                    </select>
                </div>

                <div class="button-row">
                    <button type="submit">Update Staff</button>

                    <a class="back"
                       href="${pageContext.request.contextPath}/staff">
                        Cancel
                    </a>
                </div>
            </form>
        </c:when>

        <c:otherwise>
            <div class="error">
                Staff details are unavailable. Return to the staff list
                and select a staff member to edit.
            </div>

            <a class="back"
               href="${pageContext.request.contextPath}/staff">
                Back to Staff List
            </a>
        </c:otherwise>
    </c:choose>

</div>
</body>
</html>
