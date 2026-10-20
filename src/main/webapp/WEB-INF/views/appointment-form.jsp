
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Book Appointment | CityCare Hospital</title>

    <style>
        * {
            box-sizing: border-box;
        }

        body {
            font-family: Arial, sans-serif;
            background: #f4f7fb;
            padding: 30px;
            margin: 0;
        }

        .card {
            max-width: 650px;
            margin: auto;
            padding: 28px;
            background: white;
            border-radius: 12px;
            box-shadow: 0 3px 15px rgba(0, 0, 0, 0.08);
        }

        h2 {
            color: #17365d;
            margin-bottom: 8px;
        }

        .subtitle {
            color: #667085;
            margin-bottom: 22px;
        }

        label {
            display: block;
            margin-top: 16px;
            font-weight: bold;
            color: #344054;
        }

        select, input, textarea {
            width: 100%;
            padding: 11px;
            margin-top: 7px;
            border: 1px solid #ccd5e0;
            border-radius: 6px;
            font-family: inherit;
            font-size: 14px;
            background: #fff;
        }

        select:disabled {
            background: #f0f2f5;
            cursor: not-allowed;
        }

        textarea {
            resize: vertical;
        }

        button {
            margin-top: 22px;
            padding: 12px 20px;
            background: #17365d;
            color: white;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            font-size: 15px;
        }

        button:hover {
            background: #244b7a;
        }

        button:disabled {
            background: #98a2b3;
            cursor: not-allowed;
        }

        .error {
            color: #b42318;
            background: #fef3f2;
            border: 1px solid #fecdca;
            padding: 10px;
            border-radius: 6px;
        }

        .info {
            color: #475467;
            font-size: 13px;
            margin-top: 7px;
        }

        a {
            color: #17365d;
        }

        .back-link {
    		margin-top: 22px;
    		display: flex;
		    flex-wrap: wrap;
		    gap: 10px;
		}

		.back-link a {
		    display: inline-block;
    		padding: 10px 15px;
		    border-radius: 7px;
    		background: #e2e8f0;
		    color: #263445;
		    text-decoration: none;
    		font-weight: bold;
		    transition: background 0.2s ease;
		}

		.back-link a:hover {
		    background: #cbd5e1;
		}
    </style>
</head>

<body>

<div class="card">

    <h2>Book an Appointment</h2>
    <p class="subtitle">CityCare Hospital — Appointment Management</p>

    <c:if test="${not empty errorMessage}">
        <p class="error">
            <c:out value="${errorMessage}" />
        </p>
    </c:if>

    <form method="post"
          action="${pageContext.request.contextPath}/appointments"
          id="appointmentForm">

        <!-- Patient selection -->
        <label for="patientId">Patient</label>
        <select id="patientId" name="patientId" required>
            <option value="">-- Select Patient --</option>

            <c:forEach var="p" items="${patients}">
                <option value="${p[0]}">
                    <c:out value="${p[1]}" />
                </option>
            </c:forEach>
        </select>
        
        <c:if test="${param.registered == '1'}">
        	<p class='info'>
        		Patinet registered successfully. Please complete the appointment details.
        	</p>
        </c:if>>

        <!-- Department selection -->
        <label for="departmentId">Department</label>
        <select id="departmentId" name="departmentId" required>
            <option value="">-- Select Department --</option>

            <c:forEach var="dept" items="${departments}">
                <option value="${dept[0]}">
                    <c:out value="${dept[1]}" />
                </option>
            </c:forEach>
        </select>

        <!-- Doctor selection depends on department -->
        <label for="doctorId">Doctor</label>
        <select id="doctorId" name="doctorId" required disabled>
            <option value="">-- Select a department first --</option>
        </select>

        <p class="info" id="doctorMessage" aria-live="polite">
            Choose a department to see its available doctors.
        </p>

        <!-- Appointment date and time -->
        <label for="appointmentDate">Appointment Date</label>
		<input type="date"
       		   id="appointmentDate"
       		   name="appointmentDate"
       		   required />

		<label for="appointmentSlot">Available Time Slots</label>
		<select id="appointmentSlot" required disabled>
    	<option value="">-- Select doctor and date first --</option>
		</select>

			<p class="info" id="slotMessage" aria-live="polite">
    			Select a doctor and appointment date to view available slots.
			</p>

		<input type="hidden"
       		   id="appointmentDatetime"
               name="appointmentDatetime"
               value="">

        <!-- Reason -->
        <label for="reason">Reason for Appointment</label>
        <textarea id="reason"
                  name="reason"
                  rows="3"
                  maxlength="500"
                  placeholder="Enter the reason for the appointment"></textarea>

        <!-- Notes -->
        <label for="notes">Notes</label>
        <textarea id="notes"
                  name="notes"
                  rows="3"
                  maxlength="1000"
                  placeholder="Additional notes (optional)"></textarea>

        <button type="submit" id="submitButton">
            Book Appointment
        </button>

    </form>

    <div class="back-link">
        <a href="${pageContext.request.contextPath}/appointments">
            Back to Appointments
        </a>
    	<a href="${pageContext.request.contextPath}/dashboard">
        	Back to Dashboard
    	</a>

	</div>

<script>
document.addEventListener("DOMContentLoaded", function () {

    const departmentSelect = document.getElementById("departmentId");
    const doctorSelect = document.getElementById("doctorId");
    const doctorMessage = document.getElementById("doctorMessage");
    const appointmentDate = document.getElementById("appointmentDate");
    const appointmentSlot = document.getElementById("appointmentSlot");
    const slotMessage = document.getElementById("slotMessage");
    const appointmentDatetime = document.getElementById("appointmentDatetime");
    const submitButton = document.getElementById("submitButton");
    const appointmentForm = document.getElementById("appointmentForm");

    const contextPath = "${pageContext.request.contextPath}";

    let doctorRequestId = 0;
    let slotRequestId = 0;

    // Prevent selecting a date in the past.
    const now = new Date();
    const localToday = [
        now.getFullYear(),
        String(now.getMonth() + 1).padStart(2, "0"),
        String(now.getDate()).padStart(2, "0")
    ].join("-");

    appointmentDate.min = localToday;

    function resetSlots(message) {
        appointmentSlot.replaceChildren();

        const option = document.createElement("option");
        option.value = "";
        option.textContent = message;

        appointmentSlot.appendChild(option);
        appointmentSlot.disabled = true;
        appointmentDatetime.value = "";
    }

    // Load doctors when a department is selected.
    departmentSelect.addEventListener("change", async function () {

        const departmentId = this.value;
        const requestId = ++doctorRequestId;

        // Invalidate any request for slots belonging to the old doctor.
        ++slotRequestId;
        resetSlots("-- Select doctor and date first --");
        slotMessage.textContent =
            "Select a doctor and appointment date to view available slots.";

        doctorSelect.replaceChildren();
        doctorSelect.disabled = true;

        const placeholder = document.createElement("option");
        placeholder.value = "";

        if (!departmentId) {
            placeholder.textContent = "-- Select a department first --";
            doctorSelect.appendChild(placeholder);

            doctorMessage.textContent =
                "Choose a department to see its available doctors.";
            return;
        }

        placeholder.textContent = "Loading doctors...";
        doctorSelect.appendChild(placeholder);
        doctorMessage.textContent = "Loading doctors...";

        try {
            const url = contextPath
                + "/appointment-doctors?departmentId="
                + encodeURIComponent(departmentId);

            const response = await fetch(url, {
                headers: { "Accept": "application/json" },
                credentials: "same-origin"
            });

            if (!response.ok) {
                throw new Error("Unable to load doctors.");
            }

            const doctors = await response.json();

            if (requestId !== doctorRequestId) {
                return;
            }

            doctorSelect.replaceChildren();

            const defaultOption = document.createElement("option");
            defaultOption.value = "";
            defaultOption.textContent = doctors.length
                ? "-- Select Doctor --"
                : "-- No active doctors in this department --";

            doctorSelect.appendChild(defaultOption);

            doctors.forEach(function (doctor) {
                const option = document.createElement("option");
                option.value = doctor.id;
                option.textContent = doctor.name
                    + (doctor.specialization
                        ? " — " + doctor.specialization
                        : "");

                doctorSelect.appendChild(option);
            });

            doctorSelect.disabled = doctors.length === 0;

            doctorMessage.textContent = doctors.length
                + " doctor(s) found. Select a doctor.";

        } catch (error) {
            if (requestId !== doctorRequestId) {
                return;
            }

            doctorSelect.replaceChildren();

            const option = document.createElement("option");
            option.value = "";
            option.textContent = "-- Unable to load doctors --";
            doctorSelect.appendChild(option);

            doctorMessage.textContent =
                "Unable to load doctors. Please try again.";

            console.error("Doctor loading error:", error);
        }
    });

    // Load available time slots for the selected doctor and date.
    async function loadSlots() {

        const doctorId = doctorSelect.value;
        const date = appointmentDate.value;
        const requestId = ++slotRequestId;

        resetSlots("-- Loading available slots... --");

        if (!doctorId || !date || doctorSelect.disabled) {
            resetSlots("-- Select doctor and date first --");
            slotMessage.textContent =
                "Select a doctor and appointment date to view available slots.";
            return;
        }

        slotMessage.textContent = "Checking the doctor's schedule...";

        try {
            const url = contextPath
                + "/appointment-slots?doctorId="
                + encodeURIComponent(doctorId)
                + "&date="
                + encodeURIComponent(date);

            const response = await fetch(url, {
                headers: { "Accept": "application/json" },
                credentials: "same-origin"
            });

            if (!response.ok) {
                throw new Error("Unable to load appointment slots.");
            }

            const slots = await response.json();

            // Ignore responses for an earlier doctor/date selection.
            if (requestId !== slotRequestId) {
                return;
            }

            appointmentSlot.replaceChildren();

            if (!Array.isArray(slots) || slots.length === 0) {
                const option = document.createElement("option");
                option.value = "";
                option.textContent = "-- No slots available --";
                appointmentSlot.appendChild(option);
                appointmentSlot.disabled = true;
                appointmentDatetime.value = "";

                slotMessage.textContent =
                    "No scheduled slots were found for this doctor on this date.";
                return;
            }

            const defaultOption = document.createElement("option");
            defaultOption.value = "";
            defaultOption.textContent = "-- Select a time slot --";
            appointmentSlot.appendChild(defaultOption);

            slots.forEach(function (slot) {
                const option = document.createElement("option");

                // Accept either HH:mm or HH:mm:ss from the servlet.
                const time = String(slot).substring(0, 5);

                option.value = time;
                option.textContent = time;

                appointmentSlot.appendChild(option);
            });

            appointmentSlot.disabled = false;
            slotMessage.textContent =
                slots.length + " time slot(s) returned. Select a slot.";

        } catch (error) {
            if (requestId !== slotRequestId) {
                return;
            }

            resetSlots("-- Unable to load slots --");
            slotMessage.textContent =
                "Could not load appointment slots. Please try again.";

            console.error("Appointment slot loading error:", error);
        }
    }

    // Refresh slots whenever the doctor or date changes.
    doctorSelect.addEventListener("change", loadSlots);
    appointmentDate.addEventListener("change", loadSlots);

    // Combine the selected date and time for the existing Java servlet.
    appointmentSlot.addEventListener("change", function () {
        if (appointmentDate.value && this.value) {
            appointmentDatetime.value =
                appointmentDate.value + "T" + this.value;
        } else {
            appointmentDatetime.value = "";
        }
    });

    // Validate the form before submitting it.
    appointmentForm.addEventListener("submit", function (event) {

        if (!document.getElementById("patientId").value) {
            event.preventDefault();
            alert("Please select a patient.");
            return;
        }

        if (!departmentSelect.value || !doctorSelect.value
                || doctorSelect.disabled) {
            event.preventDefault();
            alert("Please select a department and an active doctor.");
            return;
        }

        if (!appointmentDate.value || !appointmentSlot.value
                || appointmentSlot.disabled
                || !appointmentDatetime.value) {
            event.preventDefault();
            alert("Please select an appointment date and an available time slot.");
            return;
        }

        submitButton.disabled = true;
        submitButton.textContent = "Processing...";
    });

});
</script>

</body>
</html>
