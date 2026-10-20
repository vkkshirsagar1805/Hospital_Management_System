
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<section class="card schedule-section appointment-workflow">
    <div class="card-header">
        <div>
            <h2 class="section-title">Appointment Management</h2>
            <p class="section-subtitle">
                Review appointments and perform actions permitted by your role.
            </p>
        </div>
        <a class="btn" href="${pageContext.request.contextPath}/appointments">
            View all
        </a>
    </div>

    <c:if test="${param.workflowMessage == 'updated'}">
        <div class="workflow-message success-message">
            Appointment status updated successfully.
        </div>
    </c:if>

    <c:if test="${param.workflowMessage == 'not-updated'}">
        <div class="workflow-message error-message">
            The action was not completed. The appointment may have changed
            or your role may not permit this action.
        </div>
    </c:if>

    <div class="table-wrap">
        <table class="data-table">
            <thead>
                <tr>
                    <th>Patient</th>
                    <th>Doctor</th>
                    <th>Date &amp; Time</th>
                    <th>Reason</th>
                    <th>Status</th>
                    <th>Actions</th>
                </tr>
            </thead>

            <tbody>
                <c:forEach var="a" items="${workflowAppointments}">
                    <tr>
                        <td>
                            <strong><c:out value="${a.patientName}"/></strong>
                            <div class="muted">
                                ID: <c:out value="${a.patientId}"/>
                            </div>
                        </td>

                        <td><c:out value="${a.doctorName}"/></td>

                        <td>
                            <fmt:formatDate
                                value="${a.appointmentDatetime}"
                                pattern="dd MMM yyyy, hh:mm a"/>
                        </td>

                        <td><c:out value="${a.reason}"/></td>

                        <td>
                            <c:choose>
                                <c:when test="${a.appointmentStatus == 'COMPLETED'}">
                                    <span class="status-badge status-success">Completed</span>
                                </c:when>
                                <c:when test="${a.appointmentStatus == 'CANCELLED'}">
                                    <span class="status-badge status-danger">Cancelled</span>
                                </c:when>
                                <c:when test="${a.appointmentStatus == 'NO_SHOW'}">
                                    <span class="status-badge status-danger">No-show</span>
                                </c:when>
                                <c:when test="${a.appointmentStatus == 'CHECKED_IN'}">
                                    <span class="status-badge status-info">Checked in</span>
                                </c:when>
                                <c:when test="${a.appointmentStatus == 'CONFIRMED'}">
                                    <span class="status-badge status-success">Confirmed</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="status-badge status-warning">
                                        <c:out value="${a.appointmentStatus}"/>
                                    </span>
                                </c:otherwise>
                            </c:choose>
                        </td>

                        <td class="workflow-actions">
                            <%-- Doctor: approve requested appointment --%>
                            <c:if test="${sessionScope.role == 'DOCTOR'
                                and a.appointmentStatus == 'REQUESTED'}">
                                <form method="post"
                                    action="${pageContext.request.contextPath}/appointments">
                                    <input type="hidden" name="action" value="updateStatus">
                                    <input type="hidden" name="appointmentId"
                                        value="${a.appointmentId}">
                                    <input type="hidden" name="newStatus"
                                        value="CONFIRMED">
                                    <button class="btn btn-primary" type="submit">
                                        Approve
                                    </button>
                                </form>
                            </c:if>

                            <%-- Receptionist: approve a request --%>
                            <c:if test="${sessionScope.role == 'RECEPTIONIST'
                                and a.appointmentStatus == 'REQUESTED'}">
                                <form method="post"
                                    action="${pageContext.request.contextPath}/appointments">
                                    <input type="hidden" name="action" value="updateStatus">
                                    <input type="hidden" name="appointmentId"
                                        value="${a.appointmentId}">
                                    <input type="hidden" name="newStatus"
                                        value="CONFIRMED">
                                    <button class="btn btn-primary" type="submit">
                                        Approve
                                    </button>
                                </form>
                            </c:if>

                            <%-- Receptionist: check in --%>
                            <c:if test="${sessionScope.role == 'RECEPTIONIST'
                                and a.appointmentStatus == 'CONFIRMED'}">
                                <form method="post"
                                    action="${pageContext.request.contextPath}/appointments">
                                    <input type="hidden" name="action" value="updateStatus">
                                    <input type="hidden" name="appointmentId"
                                        value="${a.appointmentId}">
                                    <input type="hidden" name="newStatus"
                                        value="CHECKED_IN">
                                    <button class="btn btn-primary" type="submit">
                                        Check in
                                    </button>
                                </form>
                            </c:if>

                            <%-- Assigned doctor: complete consultation --%>
                            <c:if test="${sessionScope.role == 'DOCTOR'
                                and a.appointmentStatus == 'CHECKED_IN'}">
                                <form method="post"
                                    action="${pageContext.request.contextPath}/appointments">
                                    <input type="hidden" name="action" value="updateStatus">
                                    <input type="hidden" name="appointmentId"
                                        value="${a.appointmentId}">
                                    <input type="hidden" name="newStatus"
                                        value="COMPLETED">
                                    <button class="btn btn-primary" type="submit">
                                        Complete
                                    </button>
                                </form>
                            </c:if>

                            <%-- Receptionist or staff: mark no-show --%>
                            <c:if test="${(sessionScope.role == 'RECEPTIONIST'
                                or sessionScope.role == 'STAFF')
                                and a.appointmentStatus == 'CONFIRMED'}">
                                <form method="post"
                                    action="${pageContext.request.contextPath}/appointments">
                                    <input type="hidden" name="action" value="updateStatus">
                                    <input type="hidden" name="appointmentId"
                                        value="${a.appointmentId}">
                                    <input type="hidden" name="newStatus"
                                        value="NO_SHOW">
                                    <button class="btn" type="submit">
                                        No-show
                                    </button>
                                </form>
                            </c:if>

                            <%-- Doctor or receptionist: cancel --%>
                            <c:if test="${(sessionScope.role == 'DOCTOR'
                                or sessionScope.role == 'RECEPTIONIST')
                                and (a.appointmentStatus == 'REQUESTED'
                                or a.appointmentStatus == 'CONFIRMED')}">
                                <form method="post"
                                    action="${pageContext.request.contextPath}/appointments"
                                    onsubmit="return confirm('Cancel this appointment?');">
                                    <input type="hidden" name="action" value="updateStatus">
                                    <input type="hidden" name="appointmentId"
                                        value="${a.appointmentId}">
                                    <input type="hidden" name="newStatus"
                                        value="CANCELLED">
                                    <button class="btn workflow-cancel" type="submit">
                                        Cancel
                                    </button>
                                </form>
                            </c:if>

                            <c:if test="${a.appointmentStatus == 'COMPLETED'
                                or a.appointmentStatus == 'CANCELLED'
                                or a.appointmentStatus == 'NO_SHOW'}">
                                <span class="muted">No actions</span>
                            </c:if>
                        </td>
                    </tr>
                </c:forEach>

                <c:if test="${empty workflowAppointments}">
                    <tr>
                        <td colspan="6">
                            <div class="empty-state">
                                <strong>No appointments found</strong>
                                No appointments are currently available for this view.
                            </div>
                        </td>
                    </tr>
                </c:if>
            </tbody>
        </table>
    </div>
</section>
