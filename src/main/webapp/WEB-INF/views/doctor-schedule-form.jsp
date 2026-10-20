
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Doctor Schedule | CityCare Hospital</title>

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
            max-width: 760px;
            margin: 20px auto;
        }

        .card {
            background: white;
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

        .form-group {
            margin-bottom: 19px;
        }

        label {
            display: block;
            font-weight: bold;
            margin-bottom: 7px;
        }

        input,
        select {
            width: 100%;
            padding: 11px;
            border: 1px solid #cbd5e1;
            border-radius: 5px;
            font-size: 14px;
            background: white;
        }

        input:focus,
        select:focus {
            outline: 2px solid #bfdbfe;
            border-color: #2563eb;
        }

        .hint {
            display: block;
            margin-top: 6px;
            color: #64748b;
            font-size: 12px;
        }

        .grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 16px;
        }

        .weekday-options {
            display: grid;
            grid-template-columns: repeat(4, minmax(0, 1fr));
            gap: 10px;
            margin-top: 8px;
        }

        .weekday-option {
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 10px;
            border: 1px solid #cbd5e1;
            border-radius: 6px;
            background: #f8fafc;
            cursor: pointer;
            font-weight: normal;
            margin-bottom: 0;
        }

        .weekday-option input[type="checkbox"] {
            width: auto;
            margin: 0;
            accent-color: #176b4d;
        }

        .buttons {
            display: flex;
            flex-wrap: wrap;
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

        .save {
            background: #176b4d;
            color: white;
        }

        .save:disabled {
            background: #94a3b8;
            cursor: not-allowed;
        }

        .cancel {
            background: #e2e8f0;
            color: #263445;
        }

        .error,
        .warning {
            border-radius: 5px;
            padding: 12px;
            margin-bottom: 18px;
        }

        .error {
            background: #fee2e2;
            color: #991b1b;
        }

        .warning {
            background: #fef3c7;
            color: #92400e;
        }

        @media (max-width: 600px) {
            body {
                padding: 12px;
            }

            .card {
                padding: 19px;
            }

            .grid {
                grid-template-columns: 1fr;
                gap: 0;
            }

            .weekday-options {
                grid-template-columns: repeat(2, minmax(0, 1fr));
            }
        }
    </style>
</head>

<body>
<div class="container">
    <div class="card">

        <h1>
            <c:choose>
                <c:when test="${formAction == 'update' or (empty formAction and not empty schedule)}">
                    Edit Doctor Schedule
                </c:when>
                <c:otherwise>
                    Add Doctor Schedule
                </c:otherwise>
            </c:choose>
        </h1>

        <p class="subtitle">
            CityCare Hospital — Configure a doctor's working hours.
        </p>

        <c:if test="${not empty error}">
            <div class="error">
                <c:out value="${error}"/>
            </div>
        </c:if>

        <c:if test="${empty doctors}">
            <div class="warning">
                No active doctors are available. Add or activate a doctor
                before creating a schedule.
            </div>
        </c:if>

        <form method="post"
              action="${pageContext.request.contextPath}/doctor-schedules">

            <!-- Form action -->
            <c:choose>
                <c:when test="${formAction == 'update'}">
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" name="scheduleId"
                           value="<c:out value='${submittedScheduleId}'/>">
                </c:when>

                <c:when test="${not empty schedule}">
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" name="scheduleId"
                           value="<c:out value='${schedule.scheduleId}'/>">
                </c:when>

                <c:otherwise>
                    <input type="hidden" name="action" value="create">
                </c:otherwise>
            </c:choose>

            <!-- Doctor selection -->
            <div class="form-group">
                <label for="doctorId">Doctor *</label>

                <select id="doctorId" name="doctorId" required>
                    <option value="">-- Select Doctor --</option>

                    <c:forEach var="doctor" items="${doctors}">
                        <option value="${doctor.doctorId}"
                            <c:if test="${(not empty submittedDoctorId and submittedDoctorId == doctor.doctorId) or (empty submittedDoctorId and not empty schedule and schedule.doctorId == doctor.doctorId)}">selected</c:if>>
                            <c:out value="${doctor.fullName}"/>
                        </option>
                    </c:forEach>
                </select>
            </div>

            <!-- Multiple weekdays on create; single weekday on edit -->
            <div class="form-group">
                <label>Days of Week *</label>

                <c:choose>
                    <c:when test="${formAction == 'update' or (empty formAction and not empty schedule)}">

                        <select id="dayOfWeek" name="dayOfWeek" required>
                            <option value="">-- Select Day --</option>

                            <c:forEach var="day" items="${weekdays}">
                                <option value="${day}"
                                    <c:if test="${(not empty submittedDayOfWeek and submittedDayOfWeek == day) or (empty submittedDayOfWeek and schedule.dayOfWeek == day)}">selected</c:if>>
                                    <c:out value="${day}"/>
                                </option>
                            </c:forEach>
                        </select>

                    </c:when>

                    <c:otherwise>

                        <div class="weekday-options">
                            <c:forEach var="day" items="${weekdays}">
                                <label class="weekday-option">
                                    <input type="checkbox"
                                           name="dayOfWeek"
                                           value="${day}"
                                           <c:if test="${not empty submittedDays and submittedDays.contains(day)}">checked</c:if>>
                                    <c:out value="${day}"/>
                                </label>
                            </c:forEach>
                        </div>

                        <span class="hint">
                            Select one or more weekdays for this doctor's schedule.
                        </span>

                    </c:otherwise>
                </c:choose>
            </div>

            <!-- Working hours -->
            <div class="grid">
                <div class="form-group">
                    <label for="startTime">Start Time *</label>
                    <input type="time"
                           id="startTime"
                           name="startTime"
                           required
                           value="<c:out value='${not empty submittedStartTime ? submittedStartTime : schedule.startTime}'/>">
                </div>

                <div class="form-group">
                    <label for="endTime">End Time *</label>
                    <input type="time"
                           id="endTime"
                           name="endTime"
                           required
                           value="<c:out value='${not empty submittedEndTime ? submittedEndTime : schedule.endTime}'/>">
                </div>
            </div>

            <!-- Schedule validity -->
            <div class="grid">
                <div class="form-group">
                    <label for="validFrom">Valid From *</label>
                    <input type="date"
                           id="validFrom"
                           name="validFrom"
                           required
                           value="<c:out value='${not empty submittedValidFrom ? submittedValidFrom : schedule.validFrom}'/>">
                </div>

                <div class="form-group">
                    <label for="validUntil">Valid Until</label>
                    <input type="date"
                           id="validUntil"
                           name="validUntil"
                           value="<c:out value='${not empty submittedValidUntil ? submittedValidUntil : schedule.validUntil}'/>">

                    <span class="hint">
                        Leave blank if there is no end date.
                    </span>
                </div>
            </div>

            <!-- Status is available when editing -->
            <c:if test="${formAction == 'update' or (empty formAction and not empty schedule)}">
                <div class="form-group">
                    <label for="scheduleStatus">Schedule Status *</label>

                    <select id="scheduleStatus" name="scheduleStatus" required>
                        <option value="ACTIVE"
                            <c:if test="${(not empty submittedScheduleStatus and submittedScheduleStatus == 'ACTIVE') or (empty submittedScheduleStatus and schedule.scheduleStatus == 'ACTIVE')}">selected</c:if>>
                            Active
                        </option>

                        <option value="INACTIVE"
                            <c:if test="${(not empty submittedScheduleStatus and submittedScheduleStatus == 'INACTIVE') or (empty submittedScheduleStatus and schedule.scheduleStatus == 'INACTIVE')}">selected</c:if>>
                            Inactive
                        </option>
                    </select>
                </div>
            </c:if>

            <!-- Form buttons -->
            <div class="buttons">
                <button type="submit"
                        class="button save"
                        <c:if test="${empty doctors}">disabled</c:if>>
                    <c:choose>
                        <c:when test="${formAction == 'update' or (empty formAction and not empty schedule)}">
                            Update Schedule
                        </c:when>
                        <c:otherwise>
                            Save Schedule
                        </c:otherwise>
                    </c:choose>
                </button>

                <a class="button cancel"
                   href="${pageContext.request.contextPath}/doctor-schedules">
                    Cancel
                </a>
            </div>

        </form>
    </div>
</div>
</body>
</html>
