
package com.hospital.servlet;

import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import com.hospital.dao.SearchDAO;
import com.hospital.model.SearchResult;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/search")
public class SearchServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final SearchDAO searchDAO = new SearchDAO();

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        // Require an authenticated user.
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(
                request.getContextPath() + "/login"
            );
            return;
        }

        String role = String.valueOf(session.getAttribute("role"));

        String query = request.getParameter("q");

        if (query == null) {
            query = "";
        }

        query = query.trim();

        request.setAttribute("searchQuery", query);
        request.setAttribute("searchResults",
                             new ArrayList<SearchResult>());

        if (query.isBlank()) {
            request.setAttribute(
                "searchMessage",
                "Enter a name, ID, phone number, or keyword to search."
            );

        } else if (query.length() > 100) {
            request.setAttribute(
                "searchMessage",
                "Search text must not exceed 100 characters."
            );

        } else {
            try {
                List<SearchResult> results = searchDAO.search(query);

                // Staff must not see appointment search results.
                if ("STAFF".equalsIgnoreCase(role)) {
                    results.removeIf(result ->
                        "Appointment".equals(result.getType())
                    );
                }

                request.setAttribute("searchResults", results);

                if (results.isEmpty()) {
                    request.setAttribute(
                        "searchMessage",
                        "No matching records were found."
                    );
                }

            } catch (SQLException e) {
                getServletContext().log(
                    "Hospital record search failed.", e
                );

                request.setAttribute(
                    "searchMessage",
                    "Search is temporarily unavailable. Please try again."
                );
            }
        }

        request.getRequestDispatcher(
            "/WEB-INF/views/search-results.jsp"
        ).forward(request, response);
    }
}