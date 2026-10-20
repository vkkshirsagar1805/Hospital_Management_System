
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Staff Management</title>

    <style>
        body {
            font-family: Arial, sans-serif;
            background: #f4f7fb;
            margin: 0;
            padding: 30px;
            color: #263445;
        }

        .container {
            max-width: 1400px;
            margin: auto;
            background: white;
            padding: 25px;
            border-radius: 10px;
            box-shadow: 0 3px 12px #00000012;
        }

        h1 { color: #174a72; margin-top: 0; }
        .subtitle { color: #64748b; }
        
        .dashboard-button {
    		display: inline-block;
		    background: #e5edf7;
    		color: #173b63;
		    border-radius: 5px;
    		padding: 11px 16px;
		    text-decoration: none;
    		font-size: 14px;
		    font-weight: bold;
		}

		.dashboard-button:hover {
		    background: #d5e3f3;
		}

        .add-button, .edit-button, .delete-button,
        .status-button {
            display: inline-block;
            border: none;
            border-radius: 5px;
            padding: 8px 12px;
            text-decoration: none;
            cursor: pointer;
            font-size: 14px;
        }

        .add-button {
            display: inline-block;
            background: #176b4d;
            color: white;
            padding: 11px 16px;
            margin: 12px 0 20px;
        }

        .edit-button { background: #2563eb; color: white; }
        .delete-button { background: #b91c1c; color: white; }
        .activate-button { background: #176b4d; color: white; }
        .deactivate-button { background: #b45309; color: white; }

        .table-wrapper { overflow-x: auto; }

        table {
            width: 100%;
            border-collapse: collapse;
            white-space: nowrap;
        }

        th, td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #e2e8f0;
        }

        th { background: #174a72; color: white; }
        tr:hover { background: #f1f6fa; }

        .empty {
            text-align: center;
            padding: 25px;
            color: #64748b;
        }

        .success {
            color: #176b4d;
            font-weight: bold;
        }

        .error {
            color: #b91c1c;
            font-weight: bold;
        }

        .actions {
            display: flex;
            align-items: center;
            gap: 8px;
            flex-wrap: wrap;
        }

        .actions form { margin: 0; }

        .status-label {
            font-weight: bold;
        }

        .status-active { color: #176b4d; }
        .status-inactive { color: #b91c1c; }
        .status-on-leave { color: #b45309; }
    </style>
</head>

<body>
<div class="container">
    
    <div class="actions" style="justify-content: space-between; margin-bottom: 12px;">
    	<h1 style="margin-bottom: 0;">Staff Management</h1>

    	<a class="dashboard-button"
       		href="${pageContext.request.contextPath}/dashboard">
        	Back to Dashboard
    	</a>
	</div>

    <c:if test="${param.registered == '1'}">
        <p class="success">Staff member registered successfully.</p>
    </c:if>

    <c:if test="${param.updated == '1'}">
        <p class="success">Staff details updated successfully.</p>
    </c:if>

    <c:if test="${param.deleted == '1'}">
        <p class="success">Staff member deleted successfully.</p>
    </c:if>

    <c:if test="${param.statusUpdated == '1'}">
        <p class="success">Staff employment status updated successfully.</p>
    </c:if>

    <p class="subtitle">
        View hospital staff records and manage employment status.
    </p>

	<!-- Only ADMIN can register staff -->
	<c:if test="${sessionScope.role == 'ADMIN'}">
    	<a class="add-button"
       		href="${pageContext.request.contextPath}/staff?action=new">
        	+ Register New Staff
    	</a>
	</c:if>

    <div class="table-wrapper">
        <table>
            <thead>
                <tr>
                    <th>Staff ID</th>
                    <th>Full Name</th>
                    <th>Department ID</th>
                    <th>Designation</th>
                    <th>Staff Type</th>
                    <th>Supervisor Staff ID</th>
                    <th>Supervisor Doctor ID</th>
                    <th>Phone</th>
                    <th>Email</th>
                    <th>Employment Status</th>
                    <th>Created At</th>
                    <th>Actions</th>
                </tr>
            </thead>

            <tbody>
                <c:forEach var="staff" items="${staffList}">
                    <tr>
                        <td><c:out value="${staff.staffId}"/></td>
                        <td><c:out value="${staff.fullName}"/></td>
                        <td><c:out value="${staff.departmentId}"/></td>
                        <td><c:out value="${staff.designation}"/></td>
                        <td><c:out value="${staff.staffType}"/></td>

                        <td>
                            <c:out value="${staff.supervisorStaffId}"
                                   default="Not assigned"/>
                        </td>

                        <td>
                            <c:out value="${staff.supervisorDoctorId}"
                                   default="Not assigned"/>
                        </td>

                        <td>
                            <c:out value="${staff.phone}"
                                   default="Not provided"/>
                        </td>

                        <td>
                            <c:out value="${staff.email}"
                                   default="Not provided"/>
                        </td>

                        <td>
                            <c:choose>
                                <c:when test="${staff.employmentStatus == 'ACTIVE'}">
                                    <span class="status-label status-active">
                                        ACTIVE
                                    </span>
                                </c:when>
                                <c:when test="${staff.employmentStatus == 'INACTIVE'}">
                                    <span class="status-label status-inactive">
                                        INACTIVE
                                    </span>
                                </c:when>
                                <c:when test="${staff.employmentStatus == 'ON_LEAVE'}">
                                    <span class="status-label status-on-leave">
                                        ON LEAVE
                                    </span>
                                </c:when>
                                <c:otherwise>
                                    <c:out value="${staff.employmentStatus}"/>
                                </c:otherwise>
                            </c:choose>
                        </td>

                        <td><c:out value="${staff.createdAt}"/></td>

                        <td>
                            <div class="actions">

                                <!-- Only ADMIN can edit or delete -->
                                <c:if test="${sessionScope.role == 'ADMIN'}">
                                    <a class="edit-button"
                                       href="${pageContext.request.contextPath}/staff?action=edit&amp;id=${staff.staffId}">
                                        Edit
                                    </a>

                                    <form
                                        action="${pageContext.request.contextPath}/staff"
                                        method="post"
                                        onsubmit="return confirm('Are you sure you want to delete this staff member?');">

                                        <input type="hidden"
                                               name="action"
                                               value="delete">

                                        <input type="hidden"
                                               name="staffId"
                                               value="<c:out value='${staff.staffId}'/>">

                                        <button type="submit"
                                                class="delete-button">
                                            Delete
                                        </button>
                                    </form>
                                </c:if>

                                <!-- ADMIN and RECEPTIONIST can change status -->
                                <c:if test="${sessionScope.role == 'ADMIN' || sessionScope.role == 'RECEPTIONIST'}">

                                    <c:choose>
                                        <c:when test="${staff.employmentStatus == 'ACTIVE'}">
                                            <form
                                                action="${pageContext.request.contextPath}/staff"
                                                method="post"
                                                onsubmit="return confirm('Deactivate this staff member?');">

                                                <input type="hidden"
                                                       name="action"
                                                       value="status">

                                                <input type="hidden"
                                                       name="staffId"
                                                       value="<c:out value='${staff.staffId}'/>">

                                                <input type="hidden"
                                                       name="employmentStatus"
                                                       value="INACTIVE">

                                                <button type="submit"
                                                        class="status-button deactivate-button">
                                                    Deactivate
                                                </button>
                                            </form>
                                        </c:when>

                                        <c:otherwise>
                                            <form
                                                action="${pageContext.request.contextPath}/staff"
                                                method="post"
                                                onsubmit="return confirm('Activate this staff member?');">

                                                <input type="hidden"
                                                       name="action"
                                                       value="status">

                                                <input type="hidden"
                                                       name="staffId"
                                                       value="<c:out value='${staff.staffId}'/>">

                                                <input type="hidden"
                                                       name="employmentStatus"
                                                       value="ACTIVE">

                                                <button type="submit"
                                                        class="status-button activate-button">
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

                <c:if test="${empty staffList}">
                    <tr>
                        <td colspan="12" class="empty">
                            No staff records found.
                            <c:if test="${sessionScope.role == 'ADMIN'}">
                                Register a staff member to get started.
                            </c:if>
                        </td>
                    </tr>
                </c:if>
            </tbody>
        </table>
    </div>

</div>
</body>
</html>
