
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Departments | CityCare Hospital</title>

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
            max-width: 1200px;
            margin: auto;
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

        .panel {
            background: white;
            padding: 24px;
            border-radius: 0 0 10px 10px;
            box-shadow: 0 3px 12px rgba(0, 0, 0, 0.07);
        }

        .top-actions {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 12px;
            flex-wrap: wrap;
            margin-bottom: 20px;
        }

        .button {
            display: inline-block;
            padding: 9px 13px;
            border: none;
            border-radius: 5px;
            text-decoration: none;
            font-size: 14px;
            cursor: pointer;
        }

        .add-button {
            background: #123b63;
            color: white;
        }

        .edit-button {
            background: #e0f2fe;
            color: #075985;
        }

        .delete-button {
            background: #fee2e2;
            color: #991b1b;
        }

        .table-wrapper {
            overflow-x: auto;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            min-width: 850px;
        }

        th, td {
            padding: 13px 12px;
            border-bottom: 1px solid #e2e8f0;
            text-align: left;
            vertical-align: middle;
        }

        th {
            background: #eaf0f7;
            color: #123b63;
        }

        tr:hover td {
            background: #f8fafc;
        }

        .status {
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

        .message {
            padding: 12px 15px;
            margin-bottom: 18px;
            border-radius: 6px;
        }

        .success {
            background: #dcfce7;
            color: #166534;
        }

        .empty {
            text-align: center;
            padding: 25px;
            color: #64748b;
        }

        .row-actions {
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .row-actions form {
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

        @media (max-width: 600px) {
            .panel {
                padding: 15px;
            }

            .header {
                padding: 18px;
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

    <main class="panel">

        <div class="top-actions">
            <div>
                <h2>Department Management</h2>
                <p>View, edit, and manage hospital departments.</p>
            </div>

            <div class="row-actions">
        		<a class="button dashboard-button"
           			href="${pageContext.request.contextPath}/dashboard">
            		Back to Dashboard
        		</a>

        		<a class="button add-button"
           			href="${pageContext.request.contextPath}/departments/new">
            		+ Add Department
        		</a>
    		</div>
        </div>

        <c:if test="${param.updated == '1'}">
            <div class="message success">
                Department updated successfully.
            </div>
        </c:if>

        <c:if test="${param.deleted == '1'}">
            <div class="message success">
                Department deleted successfully.
            </div>
        </c:if>

        <p>
            Total departments:
            <strong><c:out value="${departments.size()}"/></strong>
        </p>

        <div class="table-wrapper">
            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Department Name</th>
                        <th>Description</th>
                        <th>Location</th>
                        <th>Status</th>
                        <th>Created At</th>
                        <th>Actions</th>
                    </tr>
                </thead>

                <tbody>
                    <c:forEach var="department" items="${departments}">
                        <tr>
                            <td>
                                <c:out value="${department.departmentId}"/>
                            </td>

                            <td>
                                <c:out value="${department.departmentName}"/>
                            </td>

                            <td>
                                <c:out value="${department.description}"/>
                            </td>

                            <td>
                                <c:out value="${department.location}"/>
                            </td>

                            <td>
                                <c:choose>
                                    <c:when test="${department.status == 'ACTIVE'}">
                                        <span class="status active">Active</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="status inactive">Inactive</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>

                            <td>
                                <c:out value="${department.createdAt}"/>
                            </td>

                            <td>
                                <div class="row-actions">

                                    <a class="button edit-button"
                                       href="${pageContext.request.contextPath}/departments/edit?id=${department.departmentId}">
                                        Edit
                                    </a>

                                    <form method="post"
                                          action="${pageContext.request.contextPath}/departments/delete"
                                          onsubmit="return confirm('Are you sure you want to delete this department?');">

                                        <input type="hidden"
                                               name="departmentId"
                                               value="<c:out value='${department.departmentId}'/>">

                                        <button class="button delete-button"
                                                type="submit">
                                            Delete
                                        </button>
                                    </form>

                                </div>
                            </td>
                        </tr>
                    </c:forEach>

                    <c:if test="${empty departments}">
                        <tr>
                            <td colspan="7" class="empty">
                                No departments found. Add your first department.
                            </td>
                        </tr>
                    </c:if>
                </tbody>
            </table>
        </div>

    </main>
</div>
</body>
</html>
