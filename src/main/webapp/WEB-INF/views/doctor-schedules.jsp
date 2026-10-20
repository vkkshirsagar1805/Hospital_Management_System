
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Doctor Schedules | CityCare Hospital</title>

    <style>
        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            padding: 25px;
            font-family: Arial, sans-serif;
            background: #f4f7fb;
            color: #263445;
        }

        .container {
            max-width: 1250px;
            margin: auto;
        }

        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 15px;
            margin-bottom: 22px;
        }

        h1 {
            color: #174a72;
            margin: 0 0 8px;
        }

        .subtitle {
            color: #64748b;
            margin: 0;
        }

        .button {
            display: inline-block;
            padding: 11px 15px;
            border-radius: 5px;
            text-decoration: none;
            border: none;
            cursor: pointer;
            font-size: 14px;
        }

        .primary {
            background: #176b4d;
            color: white;
        }

        .secondary {
            background: #e2e8f0;
            color: #263445;
        }

        .card {
            background: white;
            border-radius: 10px;
            padding: 22px;
            box-shadow: 0 3px 12px #00000012;
        }

        .message {
            padding: 12px 15px;
            border-radius: 5px;
            margin-bottom: 18px;
        }

        .success {
            color: #166534;
            background: #dcfce7;
        }

        .warning {
            color: #92400e;
            background: #fef3c7;
        }

        .table-wrapper {
            width: 100%;
            overflow-x: auto;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            min-width: 950px;
        }

        th, td {
            text-align: left;
            padding: 13px 11px;
            border-bottom: 1px solid #e2e8f0;
            vertical-align: middle;
        }

        th {
            background: #edf3f8;
            color: #174a72;
            white-space: nowrap;
        }

        tr:hover td {
            background: #fafcff;
        }

        .badge {
            display: inline-block;
            padding: 5px 9px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: bold;
        }

        .active {
            background: #dcfce7;
            color: #166534;
        }

        .inactive {
            background: #fee2e2;
            color: #991b1b;
        }

        .actions {
            display: flex;
            flex-wrap: wrap;
            gap: 7px;
            align-items: center;
        }

        .small-button {
            padding: 7px 10px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 12px;
        }

        .edit {
            background: #dbeafe;
            color: #1d4ed8;
        }

        .activate {
            background: #dcfce7;
            color: #166534;
        }

        .deactivate {
            background: #fee2e2;
            color: #991b1b;
        }

        .delete {
            background: #991b1b;
            color: white;
        }

        .empty {
            padding: 35px;
            text-align: center;
            color: #64748b;
        }

        form {
            display: inline;
        }

        @media (max-width: 600px) {
            body {
                padding: 14px;
            }

            .card {
                padding: 12px;
            }
        }
    </style>
</head>

<body>
<div class="container">

    <div class="header">
        <div>
            <h1>Doctor Schedules</h1>
            <p class="subtitle">
                CityCare Hospital — Manage doctor working hours.
            </p>
        </div>

        <div class="actions">
            <c:if test="${sessionScope.role == 'ADMIN'}">
                <a class="button primary"
                   href="${pageContext.request.contextPath}/doctor-schedules?action=new">
                    + Add Schedule
                </a>
            </c:if>

            <a class="button secondary"
               href="${pageContext.request.contextPath}/dashboard">
                Dashboard
            </a>
        </div>
    </div>

    <c:if test="${param.saved == '1'}">
        <div class="message success">
            Schedule saved successfully.
        </div>
    </c:if>

    <c:if test="${param.statusUpdated == '1'}">
        <div class="message success">
            Schedule status updated successfully.
        </div>
    </c:if>

    <c:if test="${param.deleted == '1'}">
        <div class="message success">
            Schedule deleted successfully.
        </div>
    </c:if>

    <div class="card">
        <div class="table-wrapper">
            <table>
                <thead>
                <tr>
                    <th>ID</th>
                    <th>Doctor</th>
                    <th>Day</th>
                    <th>Start Time</th>
                    <th>End Time</th>
                    <th>Valid From</th>
                    <th>Valid Until</th>
                    <th>Status</th>
                    <th>Actions</th>
                </tr>
                </thead>

                <tbody>
                <c:choose>
                    <c:when test="${not empty schedules}">
                        <c:forEach var="schedule" items="${schedules}">
                            <tr>
                                <td>
                                    <c:out value="${schedule.scheduleId}"/>
                                </td>

                                <td>
                                    <c:out value="${schedule.doctorName}"/>
                                </td>

                                <td>
                                    <c:out value="${schedule.dayOfWeek}"/>
                                </td>

                                <td>
                                    <c:out value="${schedule.startTime}"/>
                                </td>

                                <td>
                                    <c:out value="${schedule.endTime}"/>
                                </td>

                                <td>
                                    <c:out value="${schedule.validFrom}"/>
                                </td>

                                <td>
                                    <c:choose>
                                        <c:when test="${not empty schedule.validUntil}">
                                            <c:out value="${schedule.validUntil}"/>
                                        </c:when>
                                        <c:otherwise>
                                            No end date
                                        </c:otherwise>
                                    </c:choose>
                                </td>

                                <td>
                                    <c:choose>
                                        <c:when test="${schedule.scheduleStatus == 'ACTIVE'}">
                                            <span class="badge active">ACTIVE</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge inactive">INACTIVE</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>

                                <td>
                                    <div class="actions">

                                        <c:if test="${sessionScope.role == 'ADMIN'}">
                                            <a class="button small-button edit"
                                               href="${pageContext.request.contextPath}/doctor-schedules?action=edit&amp;scheduleId=${schedule.scheduleId}">
                                                Edit
                                            </a>
                                        </c:if>

                                        <c:if test="${sessionScope.role == 'ADMIN' || sessionScope.role == 'RECEPTIONIST'}">
                                            <form method="post"
                                                  action="${pageContext.request.contextPath}/doctor-schedules">

                                                <input type="hidden"
                                                       name="action"
                                                       value="status">

                                                <input type="hidden"
                                                       name="scheduleId"
                                                       value="<c:out value='${schedule.scheduleId}'/>">

                                                <c:choose>
                                                    <c:when test="${schedule.scheduleStatus == 'ACTIVE'}">
                                                        <input type="hidden"
                                                               name="scheduleStatus"
                                                               value="INACTIVE">

                                                        <button type="submit"
                                                                class="small-button deactivate">
                                                            Deactivate
                                                        </button>
                                                    </c:when>

                                                    <c:otherwise>
                                                        <input type="hidden"
                                                               name="scheduleStatus"
                                                               value="ACTIVE">

                                                        <button type="submit"
                                                                class="small-button activate">
                                                            Activate
                                                        </button>
                                                    </c:otherwise>
                                                </c:choose>
                                            </form>
                                        </c:if>

                                        <c:if test="${sessionScope.role == 'ADMIN'}">
                                            <form method="post"
                                                  action="${pageContext.request.contextPath}/doctor-schedules"
                                                  onsubmit="return confirm('Delete this doctor schedule?');">

                                                <input type="hidden"
                                                       name="action"
                                                       value="delete">

                                                <input type="hidden"
                                                       name="scheduleId"
                                                       value="<c:out value='${schedule.scheduleId}'/>">

                                                <button type="submit"
                                                        class="small-button delete">
                                                    Delete
                                                </button>
                                            </form>
                                        </c:if>

                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                    </c:when>

                    <c:otherwise>
                        <tr>
                            <td colspan="9" class="empty">
                                No doctor schedules found. An administrator
                                can add the first schedule.
                            </td>
                        </tr>
                    </c:otherwise>
                </c:choose>
                </tbody>
            </table>
        </div>
    </div>

</div>
</body>
</html>
