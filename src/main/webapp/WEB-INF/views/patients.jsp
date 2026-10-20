
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Patient Management</title>

    <style>
        * { box-sizing: border-box; }

        body {
            margin: 0;
            padding: 25px;
            font-family: Arial, sans-serif;
            background: #f4f7fb;
            color: #263445;
        }

        .container { max-width: 1400px; margin: auto; }
        h1 { color: #173b63; margin-bottom: 8px; }
        .subtitle { color: #65758b; margin-bottom: 25px; }

        .toolbar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 12px;
            margin-bottom: 20px;
            flex-wrap: wrap;
        }

        .button {
            display: inline-block;
            padding: 10px 15px;
            border: none;
            border-radius: 5px;
            text-decoration: none;
            cursor: pointer;
            font-size: 14px;
        }

        .primary { background: #1769aa; color: white; }
        .edit { background: #e5a323; color: #222; }
        .delete { background: #c0392b; color: white; }
        .activate { background: #218838; color: white; }
        .deactivate { background: #687586; color: white; }

        .message {
            padding: 12px;
            border-radius: 5px;
            margin-bottom: 15px;
            background: #e1f5e8;
            color: #176638;
        }

        .error { background: #fde8e7; color: #922b21; }

        .table-wrapper {
            overflow-x: auto;
            background: white;
            border-radius: 8px;
            box-shadow: 0 3px 12px #0000000d;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            min-width: 1050px;
        }

        th, td {
            padding: 13px;
            text-align: left;
            border-bottom: 1px solid #e5eaf0;
            vertical-align: top;
        }

        th {
            background: #173b63;
            color: white;
            white-space: nowrap;
        }

        tr:hover td { background: #f8fbff; }

        .actions {
            display: flex;
            gap: 7px;
            align-items: center;
            flex-wrap: wrap;
        }
        
        .dashboard-button{
        	background: #e5edf7;
        	color: #173b63;
        	front-weight: bold;
        }
        
        .dashboard-button:hover{
        	background: #d5e3f3;
        }

        .actions form { margin: 0; }
        .status { font-weight: bold; }
        .empty { padding: 30px; text-align: center; color: #65758b; }
    </style>
</head>

<body>
<div class="container">

    <h1>Patient Management</h1>
    <p class="subtitle">
        Register, view, update and manage hospital patient records.
    </p>

    <div class="toolbar">
        <h2>Registered Patients</h2>
        
        <div>
        	<a class = "button dashboard-button"
        		href="${pageContext.request.contextPath}/dashboard">
        		Back to Dashboard
        	</a>
        </div>
        

        <c:if test="${sessionScope.role eq 'ADMIN'}">
            <a class="button primary"
               href="${pageContext.request.contextPath}/patients?action=new">
                + Register New Patient
            </a>
        </c:if>
    </div>

    <c:if test="${param.registered == '1'}">
        <div class="message">Patient registered successfully.</div>
    </c:if>

    <c:if test="${param.updated == '1'}">
        <div class="message">Patient details updated successfully.</div>
    </c:if>

    <c:if test="${param.deleted == '1'}">
        <div class="message">Patient record deleted successfully.</div>
    </c:if>

    <c:if test="${param.statusUpdated == '1'}">
        <div class="message">Patient status updated successfully.</div>
    </c:if>

    <c:if test="${param.error == 'constraint'}">
        <div class="message error">
            This patient record cannot be deleted because it is linked
            to other hospital records.
        </div>
    </c:if>

    <div class="table-wrapper">
        <table>
            <thead>
            <tr>
                <th>ID</th>
                <th>Full Name</th>
                <th>Date of Birth</th>
                <th>Gender</th>
                <th>Phone</th>
                <th>Email</th>
                <th>Address</th>
                <th>Registration Date</th>
                <th>Status</th>
                <th>Actions</th>
            </tr>
            </thead>

            <tbody>
            <c:choose>
                <c:when test="${not empty patients}">
                    <c:forEach var="patient" items="${patients}">
                        <tr>
                            <td><c:out value="${patient.patientId}"/></td>
                            <td><c:out value="${patient.fullName}"/></td>
                            <td><c:out value="${patient.dateOfBirth}"/></td>
                            <td><c:out value="${patient.gender}"/></td>
                            <td><c:out value="${patient.phone}"/></td>
                            <td><c:out value="${patient.email}"/></td>
                            <td><c:out value="${patient.address}"/></td>
                            <td><c:out value="${patient.registrationDate}"/></td>

                            <td>
                                <span class="status">
                                    <c:out value="${patient.recordStatus}"/>
                                </span>
                            </td>

                            <td>
                                <div class="actions">

                                    <!-- Only ADMIN can edit patient details -->
                                    <c:if test="${sessionScope.role eq 'ADMIN'}">
                                        <a class="button edit"
                                           href="${pageContext.request.contextPath}/patients?action=edit&amp;id=${patient.patientId}">
                                            Edit
                                        </a>

                                        <form method="post"
                                              action="${pageContext.request.contextPath}/patients"
                                              onsubmit="return confirm('Delete this fictional test patient record?');">
                                            <input type="hidden" name="action" value="delete">
                                            <input type="hidden" name="patientId"
                                                   value="${patient.patientId}">

                                            <button class="button delete" type="submit">
                                                Delete
                                            </button>
                                        </form>
                                    </c:if>

                                    <!-- ADMIN and RECEPTIONIST can change status -->
                                    <c:if test="${sessionScope.role eq 'ADMIN' or sessionScope.role eq 'RECEPTIONIST'}">

                                        <c:choose>
                                            <c:when test="${patient.recordStatus eq 'ACTIVE'}">
                                                <form method="post"
                                                      action="${pageContext.request.contextPath}/patients"
                                                      onsubmit="return confirm('Deactivate this patient record?');">

                                                    <input type="hidden" name="action" value="status">
                                                    <input type="hidden" name="patientId"
                                                           value="${patient.patientId}">
                                                    <input type="hidden" name="recordStatus"
                                                           value="INACTIVE">

                                                    <button class="button deactivate" type="submit">
                                                        Deactivate
                                                    </button>
                                                </form>
                                            </c:when>

                                            <c:otherwise>
                                                <form method="post"
                                                      action="${pageContext.request.contextPath}/patients"
                                                      onsubmit="return confirm('Activate this patient record?');">

                                                    <input type="hidden" name="action" value="status">
                                                    <input type="hidden" name="patientId"
                                                           value="${patient.patientId}">
                                                    <input type="hidden" name="recordStatus"
                                                           value="ACTIVE">

                                                    <button class="button activate" type="submit">
                                                        Activate
                                                    </button>
                                                </form>
                                            </c:otherwise>
                                        </c:choose>

                                    </c:if>

                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                </c:when>

                <c:otherwise>
                    <tr>
                        <td colspan="10" class="empty">
                            No patient records found.
                        </td>
                    </tr>
                </c:otherwise>
            </c:choose>
            </tbody>
        </table>
    </div>

</div>
</body>
</html>
