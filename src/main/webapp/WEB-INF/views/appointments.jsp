<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Appointment Management | CityCare Hospital</title>

    <style>
        body {
            font-family: Arial, sans-serif;
            background: #f4f7fb;
            margin: 0;
            padding: 30px;
        }

        h1 {
            color: #17365d;
        }

        .container {
            max-width: 1200px;
            margin: auto;
            background: white;
            padding: 25px;
            border-radius: 12px;
            box-shadow: 0 3px 15px rgba(0, 0, 0, .08);
            overflow-x: auto;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }

        th, td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #e5eaf0;
            vertical-align: middle;
        }

        th {
            background: #17365d;
            color: white;
            white-space: nowrap;
        }

        tr:hover {
            background: #f4f8fc;
        }

        .action-bar {
            display: flex;
            flex-wrap: wrap;
            gap: 12px;
            margin: 22px 0;
        }

        .action-btn {
            display: inline-block;
            padding: 11px 16px;
            background: #17365d;
            color: white;
            text-decoration: none;
            border-radius: 6px;
            font-size: 14px;
            font-weight: bold;
        }

        .action-btn:hover {
            background: #244b7a;
        }

        .action-btn.secondary {
            background: #e8eef6;
            color: #17365d;
        }

        .action-btn.secondary:hover {
            background: #d8e3f1;
        }

        .status-message {
            padding: 12px;
            margin-top: 15px;
            border-radius: 6px;
        }

        .success {
            background: #dff5e5;
            color: #176534;
        }

        .warning {
            background: #fff0d6;
            color: #805500;
        }

        .empty {
            text-align: center;
            color: #777;
            padding: 25px;
        }

        .actions-cell {
            min-width: 190px;
        }

        .status-form {
            display: inline-block;
            margin: 2px;
        }

        .status-btn {
            border: none;
            border-radius: 5px;
            padding: 8px 10px;
            cursor: pointer;
            font-weight: bold;
            font-size: 12px;
        }

        .confirm-btn {
            background: #dff5e5;
            color: #176534;
        }

        .cancel-btn {
            background: #fde2e2;
            color: #a61b1b;
        }

        .checkin-btn {
            background: #dcecff;
            color: #174ea6;
        }

        .complete-btn {
            background: #e8def8;
            color: #5b2c83;
        }

        .noshow-btn {
            background: #fff0d6;
            color: #805500;
        }

        .status-btn:hover {
            filter: brightness(.95);
        }

        @media (max-width: 700px) {
            body {
                padding: 12px;
            }

            .container {
                padding: 15px;
            }
        }
    </style>
</head>

<body>
<div class="container">

    <h1>Appointment Management</h1>
    <p>CityCare Hospital — Scheduled patient appointments</p>

    <div class="action-bar">
        <c:if test="${sessionScope.role == 'ADMIN' or sessionScope.role == 'RECEPTIONIST'}">
            <a class="action-btn"
               href="${pageContext.request.contextPath}/appointments?action=new">
                + New Appointment
            </a>

            <a class="action-btn secondary"
               href="${pageContext.request.contextPath}/patients">
                + Register Patient
            </a>
        </c:if>

        <a class="action-btn secondary"
           href="${pageContext.request.contextPath}/dashboard">
            Back to Dashboard
        </a>
    </div>

    <c:if test="${param.workflowMessage == 'updated'}">
        <div class="status-message success">
            Appointment status updated successfully.
        </div>
    </c:if>

    <c:if test="${param.workflowMessage == 'not-updated'}">
        <div class="status-message warning">
            Status was not updated. Check your permissions or the
            appointment's current status.
        </div>
    </c:if>

    <c:if test="${param.success == 'created'}">
        <div class="status-message success">
            Appointment created successfully.
        </div>
    </c:if>

    <table>
        <thead>
        <tr>
            <th>ID</th>
            <th>Patient</th>
            <th>Doctor</th>
            <th>Date &amp; Time</th>
            <th>Reason</th>
            <th>Status</th>
            <th>Actions</th>
        </tr>
        </thead>

        <tbody>
        <c:forEach var="a" items="${appointments}">
            <tr>
                <td><c:out value="${a.appointmentId}"/></td>
                <td><c:out value="${a.patientName}"/></td>
                <td><c:out value="${a.doctorName}"/></td>
                <td><c:out value="${a.appointmentDatetime}"/></td>
                <td><c:out value="${a.reason}"/></td>
                <td><c:out value="${a.appointmentStatus}"/></td>

                <td class="actions-cell">

                    <%-- Doctor: confirm or cancel a requested appointment. --%>
                    <c:if test="${sessionScope.role == 'DOCTOR'
                                  and a.appointmentStatus == 'REQUESTED'}">

                        <form class="status-form" method="post"
                              action="${pageContext.request.contextPath}/appointments">
                            <input type="hidden" name="action" value="updateStatus">
                            <input type="hidden" name="appointmentId"
                                   value="${a.appointmentId}">
                            <input type="hidden" name="newStatus" value="CONFIRMED">
                            <button class="status-btn confirm-btn" type="submit">
                                Confirm
                            </button>
                        </form>

                        <form class="status-form" method="post"
                              action="${pageContext.request.contextPath}/appointments">
                            <input type="hidden" name="action" value="updateStatus">
                            <input type="hidden" name="appointmentId"
                                   value="${a.appointmentId}">
                            <input type="hidden" name="newStatus" value="CANCELLED">
                            <button class="status-btn cancel-btn" type="submit">
                                Cancel
                            </button>
                        </form>
                    </c:if>

                    <%-- Doctor: cancel a confirmed appointment. --%>
                    <c:if test="${sessionScope.role == 'DOCTOR'
                                  and a.appointmentStatus == 'CONFIRMED'}">

                        <form class="status-form" method="post"
                              action="${pageContext.request.contextPath}/appointments">
                            <input type="hidden" name="action" value="updateStatus">
                            <input type="hidden" name="appointmentId"
                                   value="${a.appointmentId}">
                            <input type="hidden" name="newStatus" value="CANCELLED">
                            <button class="status-btn cancel-btn" type="submit">
                                Cancel
                            </button>
                        </form>
                    </c:if>

                    <%-- Doctor: complete a checked-in appointment. --%>
                    <c:if test="${sessionScope.role == 'DOCTOR'
                                  and a.appointmentStatus == 'CHECKED_IN'}">

                        <form class="status-form" method="post"
                              action="${pageContext.request.contextPath}/appointments">
                            <input type="hidden" name="action" value="updateStatus">
                            <input type="hidden" name="appointmentId"
                                   value="${a.appointmentId}">
                            <input type="hidden" name="newStatus" value="COMPLETED">
                            <button class="status-btn complete-btn" type="submit">
                                Complete
                            </button>
                        </form>
                    </c:if>

                    <%-- Receptionist: confirm or cancel a requested appointment. --%>
                    <c:if test="${sessionScope.role == 'RECEPTIONIST'
                                  and a.appointmentStatus == 'REQUESTED'}">

                        <form class="status-form" method="post"
                              action="${pageContext.request.contextPath}/appointments">
                            <input type="hidden" name="action" value="updateStatus">
                            <input type="hidden" name="appointmentId"
                                   value="${a.appointmentId}">
                            <input type="hidden" name="newStatus" value="CONFIRMED">
                            <button class="status-btn confirm-btn" type="submit">
                                Confirm
                            </button>
                        </form>

                        <form class="status-form" method="post"
                              action="${pageContext.request.contextPath}/appointments">
                            <input type="hidden" name="action" value="updateStatus">
                            <input type="hidden" name="appointmentId"
                                   value="${a.appointmentId}">
                            <input type="hidden" name="newStatus" value="CANCELLED">
                            <button class="status-btn cancel-btn" type="submit">
                                Cancel
                            </button>
                        </form>
                    </c:if>

                    <%-- Receptionist: check in, cancel, or mark no-show. --%>
                    <c:if test="${sessionScope.role == 'RECEPTIONIST'
                                  and a.appointmentStatus == 'CONFIRMED'}">

                        <form class="status-form" method="post"
                              action="${pageContext.request.contextPath}/appointments">
                            <input type="hidden" name="action" value="updateStatus">
                            <input type="hidden" name="appointmentId"
                                   value="${a.appointmentId}">
                            <input type="hidden" name="newStatus" value="CHECKED_IN">
                            <button class="status-btn checkin-btn" type="submit">
                                Check In
                            </button>
                        </form>

                        <form class="status-form" method="post"
                              action="${pageContext.request.contextPath}/appointments">
                            <input type="hidden" name="action" value="updateStatus">
                            <input type="hidden" name="appointmentId"
                                   value="${a.appointmentId}">
                            <input type="hidden" name="newStatus" value="CANCELLED">
                            <button class="status-btn cancel-btn" type="submit">
                                Cancel
                            </button>
                        </form>

                        <form class="status-form" method="post"
                              action="${pageContext.request.contextPath}/appointments">
                            <input type="hidden" name="action" value="updateStatus">
                            <input type="hidden" name="appointmentId"
                                   value="${a.appointmentId}">
                            <input type="hidden" name="newStatus" value="NO_SHOW">
                            <button class="status-btn noshow-btn" type="submit">
                                No Show
                            </button>
                        </form>
                    </c:if>

                    <%-- Staff: mark a confirmed appointment as no-show. --%>
                    <c:if test="${sessionScope.role == 'STAFF'
                                  and a.appointmentStatus == 'CONFIRMED'}">

                        <form class="status-form" method="post"
                              action="${pageContext.request.contextPath}/appointments">
                            <input type="hidden" name="action" value="updateStatus">
                            <input type="hidden" name="appointmentId"
                                   value="${a.appointmentId}">
                            <input type="hidden" name="newStatus" value="NO_SHOW">
                            <button class="status-btn noshow-btn" type="submit">
                                No Show
                            </button>
                        </form>
                    </c:if>

                    <c:if test="${a.appointmentStatus == 'COMPLETED'
                                  or a.appointmentStatus == 'CANCELLED'
                                  or a.appointmentStatus == 'NO_SHOW'}">
                        <span>—</span>
                    </c:if>

                    <c:if test="${sessionScope.role == 'ADMIN'}">
                        <span>View only</span>
                    </c:if>

                </td>
            </tr>
        </c:forEach>

        <c:if test="${empty appointments}">
            <tr>
                <td colspan="7" class="empty">
                    No appointments found.
                </td>
            </tr>
        </c:if>
        </tbody>
    </table>

</div>
</body>
</html>