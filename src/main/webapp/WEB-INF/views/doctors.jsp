
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Doctor Management</title>

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
        h1 { color: #173b63; }
        .subtitle { color: #65758b; margin-bottom: 25px; }

        .table-wrapper {
            overflow-x: auto;
            background: white;
            border-radius: 8px;
            box-shadow: 0 3px 12px #0000000d;
        }

        table {
            width: 100%;
            min-width: 1100px;
            border-collapse: collapse;
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
        .empty { padding: 30px; text-align: center; color: #65758b; }
        .status { font-weight: bold; }

        .message {
            padding: 12px;
            border-radius: 5px;
            margin: 12px 0;
            background: #e1f5e8;
            color: #176638;
        }

        .button {
            display: inline-block;
            padding: 8px 12px;
            border: none;
            border-radius: 4px;
            text-decoration: none;
            cursor: pointer;
            font-size: 14px;
            white-space: nowrap;
        }

        .register { background: #1769aa; color: white; }
        .edit { background: #e5a323; color: #222; }
        .delete { background: #c0392b; color: white; }
        .activate { background: #218838; color: white; }
        .deactivate { background: #687586; color: white; }

        .actions {
            display: flex;
            align-items: center;
            gap: 7px;
            flex-wrap: wrap;
        }
        
        .action form {
        	margin: 0;
        }
        
		.dashboard-button {
    		background: #e5edf7;
    		color: #173b63;
    		font-weight: bold;
		}

		.dashboard-button:hover {
    		background: #d5e3f3;
		}

    </style>
</head>

<body>
<div class="container">

    <h1>Doctor Management</h1>

    <c:if test="${param.registered == '1'}">
        <div class="message">Doctor registered successfully!</div>
    </c:if>

    <c:if test="${param.updated == '1'}">
        <div class="message">Doctor details updated successfully!</div>
    </c:if>

    <c:if test="${param.deleted == '1'}">
        <div class="message">Doctor deleted successfully!</div>
    </c:if>

    <c:if test="${param.statusUpdated == '1'}">
        <div class="message">Doctor employment status updated successfully!</div>
    </c:if>

	<div class="actions" style="margin: 18px 0;">
    	<a class="button dashboard-button"
       		href="${pageContext.request.contextPath}/dashboard">
        	Back to Dashboard
    	</a>

    	<c:if test="${sessionScope.role eq 'ADMIN'}">
        	<a class="button register"
           	href="${pageContext.request.contextPath}/doctors?action=new">
            	+ Register New Doctor
        	</a>
    	</c:if>
	</div>

    <p class="subtitle">
        View and manage the doctors registered in the hospital database.
    </p>

    <div class="table-wrapper">
        <table>
            <thead>
            <tr>
                <th>Doctor ID</th>
                <th>Full Name</th>
                <th>Department ID</th>
				<th>Department Name</th>
                <th>Specialization</th>
                <th>Qualification</th>
                <th>Phone</th>
                <th>Email</th>
                <th>Employment Status</th>
                <th>Created At</th>
                <th>Actions</th>
            </tr>
            </thead>

            <tbody>
            <c:choose>
                <c:when test="${not empty doctors}">
                    <c:forEach var="doctor" items="${doctors}">
                        <tr>
                            <td><c:out value="${doctor.doctorId}"/></td>
                            <td><c:out value="${doctor.fullName}"/></td>
                            <td><c:out value="${doctor.departmentId}"/></td>
                            <td><c:out value="${doctor.departmentName}"/></td>
                            <td><c:out value="${doctor.specialization}"/></td>
                            <td><c:out value="${doctor.qualification}"/></td>
                            <td><c:out value="${doctor.phone}"/></td>
                            <td><c:out value="${doctor.email}"/></td>
                            <td>
                                <span class="status">
                                    <c:out value="${doctor.employmentStatus}"/>
                                </span>
                            </td>
                            <td><c:out value="${doctor.createdAt}"/></td>

                            <td>
                                <div class="actions">

                                    <!-- Full doctor management: ADMIN only -->
                                    <c:if test="${sessionScope.role eq 'ADMIN'}">
                                        <a class="button edit"
                                           href="${pageContext.request.contextPath}/doctors?action=edit&amp;id=${doctor.doctorId}">
                                            Edit
                                        </a>

                                        <form method="post"
                                              action="${pageContext.request.contextPath}/doctors"
                                              onsubmit="return confirm('Delete this fictional test doctor?');">
                                            <input type="hidden" name="action" value="delete">
                                            <input type="hidden" name="doctorId"
                                                   value="${doctor.doctorId}">

                                            <button class="button delete" type="submit">
                                                Delete
                                            </button>
                                        </form>
                                    </c:if>

                                    <!-- ADMIN and RECEPTIONIST: status changes only -->
                                    <c:if test="${sessionScope.role eq 'ADMIN' or sessionScope.role eq 'RECEPTIONIST'}">
                                        <c:choose>
                                            <c:when test="${doctor.employmentStatus eq 'ACTIVE'}">
                                                <form method="post"
                                                      action="${pageContext.request.contextPath}/doctors"
                                                      onsubmit="return confirm('Deactivate this doctor?');">
                                                    <input type="hidden" name="action" value="status">
                                                    <input type="hidden" name="doctorId"
                                                           value="${doctor.doctorId}">
                                                    <input type="hidden" name="employmentStatus"
                                                           value="INACTIVE">

                                                    <button class="button deactivate" type="submit">
                                                        Deactivate
                                                    </button>
                                                </form>
                                            </c:when>

                                            <c:otherwise>
                                                <form method="post"
                                                      action="${pageContext.request.contextPath}/doctors"
                                                      onsubmit="return confirm('Activate this doctor?');">
                                                    <input type="hidden" name="action" value="status">
                                                    <input type="hidden" name="doctorId"
                                                           value="${doctor.doctorId}">
                                                    <input type="hidden" name="employmentStatus"
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
                        <td colspan="11" class="empty">
                            No doctor records found in the database.
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
