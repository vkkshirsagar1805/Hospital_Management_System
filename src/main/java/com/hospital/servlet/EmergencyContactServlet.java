
package com.hospital.servlet;

import com.hospital.dao.EmergencyContactDAO;
import com.hospital.model.EmergencyContact;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.Set;

@WebServlet("/emergency-contacts")
public class EmergencyContactServlet extends HttpServlet {

    private final EmergencyContactDAO contactDAO =
            new EmergencyContactDAO();

    private static final Set<String> CONTACT_TYPES = Set.of(
            "HOSPITAL", "AMBULANCE_SERVICE", "FIRE",
            "POLICE", "BLOOD_BANK", "OTHER"
    );

    private boolean isAdmin(String role) {
        return "ADMIN".equalsIgnoreCase(role);
    }

    private String getRole(HttpSession session) {
        Object role = session.getAttribute("role");
        return role == null ? "" : role.toString();
    }

    private boolean isLoggedIn(HttpSession session) {
        return session != null && session.getAttribute("userId") != null;
    }

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (!isLoggedIn(session)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String role = getRole(session);

        if (!isAdmin(role)
                && !Set.of("DOCTOR", "STAFF", "RECEPTIONIST")
                      .contains(role.toUpperCase())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        try {
            List<EmergencyContact> contacts =
                    isAdmin(role)
                    ? contactDAO.getAllContacts()
                    : contactDAO.getActiveContacts();

            request.setAttribute("contacts", contacts);
            request.setAttribute("canManage", isAdmin(role));

            String editId = request.getParameter("editId");

            if (isAdmin(role) && editId != null) {
                int id = parsePositiveInt(editId, "contact ID");
                EmergencyContact contact = contactDAO.getContactById(id);

                if (contact == null) {
                    request.getSession().setAttribute(
                            "emergencyContactMessage",
                            "Contact not found."
                    );
                    response.sendRedirect(
                            request.getContextPath() + "/emergency-contacts"
                    );
                    return;
                }

                request.setAttribute("editContact", contact);
            }

            request.getRequestDispatcher(
                    "/WEB-INF/views/emergency-contacts.jsp"
            ).forward(request, response);

        } catch (IllegalArgumentException e) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST, e.getMessage()
            );
        } catch (SQLException e) {
            throw new ServletException(
                    "Unable to load emergency contacts.", e
            );
        }
    }

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (!isLoggedIn(session)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        if (!isAdmin(getRole(session))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        request.setCharacterEncoding("UTF-8");

        String message;

        try {
            String action = request.getParameter("action");

            if ("add".equals(action)) {
                EmergencyContact contact = readContact(request);
                contact.setContactStatus("ACTIVE");

                if (!contactDAO.addContact(contact)) {
                    throw new IllegalArgumentException(
                            "Contact could not be added."
                    );
                }

                message = "Emergency contact added successfully.";

            } else if ("update".equals(action)) {
                int id = parsePositiveInt(
                        request.getParameter("contactId"), "contact ID"
                );

                if (contactDAO.getContactById(id) == null) {
                    throw new IllegalArgumentException(
                            "Contact not found."
                    );
                }

                EmergencyContact contact = readContact(request);
                contact.setContactId(id);

                if (!contactDAO.updateContact(contact)) {
                    throw new IllegalArgumentException(
                            "Contact could not be updated."
                    );
                }

                message = "Emergency contact updated successfully.";

            } else if ("updateStatus".equals(action)) {
                int id = parsePositiveInt(
                        request.getParameter("contactId"), "contact ID"
                );

                String status = request.getParameter("contactStatus");

                if (!"ACTIVE".equals(status)
                        && !"INACTIVE".equals(status)) {
                    throw new IllegalArgumentException(
                            "Invalid contact status."
                    );
                }

                if (contactDAO.getContactById(id) == null) {
                    throw new IllegalArgumentException(
                            "Contact not found."
                    );
                }

                if (!contactDAO.updateContactStatus(id, status)) {
                    throw new IllegalArgumentException(
                            "Contact status could not be updated."
                    );
                }

                message = "Contact status updated successfully.";

            } else {
                throw new IllegalArgumentException(
                        "Invalid contact action."
                );
            }

        } catch (IllegalArgumentException e) {
            message = e.getMessage();

        } catch (SQLException e) {
            throw new ServletException(
                    "Unable to save emergency contact.", e
            );
        }

        session.setAttribute("emergencyContactMessage", message);

        response.sendRedirect(
                request.getContextPath() + "/emergency-contacts"
        );
    }

    private EmergencyContact readContact(HttpServletRequest request) {
        EmergencyContact contact = new EmergencyContact();

        String name = trim(request.getParameter("contactName"));
        String type = trim(request.getParameter("contactType"));
        String phone = trim(request.getParameter("phone"));
        String alternatePhone = trim(
                request.getParameter("alternatePhone")
        );
        String address = trim(request.getParameter("address"));
        String hours = trim(request.getParameter("operatingHours"));
        String notes = trim(request.getParameter("notes"));

        if (name.isEmpty() || name.length() > 150) {
            throw new IllegalArgumentException(
                    "Contact name is required (maximum 150 characters)."
            );
        }

        if (!CONTACT_TYPES.contains(type)) {
            throw new IllegalArgumentException(
                    "Select a valid contact type."
            );
        }

        if (phone.isEmpty() || phone.length() > 25
                || !phone.matches("[0-9+() .-]{5,25}")) {
            throw new IllegalArgumentException(
                    "Enter a valid primary phone number."
            );
        }

        if (!alternatePhone.isEmpty()
                && (alternatePhone.length() > 25
                || !alternatePhone.matches("[0-9+() .-]{5,25}"))) {
            throw new IllegalArgumentException(
                    "Enter a valid alternate phone number."
            );
        }

        if (address.length() > 300) {
            throw new IllegalArgumentException(
                    "Address must not exceed 300 characters."
            );
        }

        if (hours.length() > 100) {
            throw new IllegalArgumentException(
                    "Operating hours must not exceed 100 characters."
            );
        }

        if (notes.length() > 500) {
            throw new IllegalArgumentException(
                    "Notes must not exceed 500 characters."
            );
        }

        contact.setContactName(name);
        contact.setContactType(type);
        contact.setPhone(phone);
        contact.setAlternatePhone(
                alternatePhone.isEmpty() ? null : alternatePhone
        );
        contact.setAddress(address.isEmpty() ? null : address);
        contact.setOperatingHours(hours.isEmpty() ? null : hours);
        contact.setNotes(notes.isEmpty() ? null : notes);

        return contact;
    }

    private int parsePositiveInt(String value, String field) {
        try {
            int id = Integer.parseInt(value);

            if (id <= 0) {
                throw new NumberFormatException();
            }

            return id;

        } catch (NumberFormatException e) {
            throw new IllegalArgumentException(
                    "Invalid " + field + "."
            );
        }
    }

    private String trim(String value) {
        return value == null ? "" : value.trim();
    }
}
