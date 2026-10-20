
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="com.hospital.model.SearchResult" %>
<%!
    private String escapeHtml(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#x27;");
    }
%>
<%
    String contextPath = request.getContextPath();

    String searchQuery = (String) request.getAttribute("searchQuery");
    if (searchQuery == null) searchQuery = "";

    String searchMessage = (String) request.getAttribute("searchMessage");

    List<SearchResult> searchResults =
        (List<SearchResult>) request.getAttribute("searchResults");

    if (searchResults == null) {
        searchResults = java.util.Collections.emptyList();
    }

    String username = String.valueOf(
        session.getAttribute("username") == null
            ? "User" : session.getAttribute("username")
    );
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Search Results | CityCare Hospital</title>

<style>
    * {
        box-sizing: border-box;
    }

    body {
        margin: 0;
        font-family: Arial, Helvetica, sans-serif;
        background: #f4f7fb;
        color: #1e293b;
    }

    .header {
        background: #ffffff;
        border-bottom: 1px solid #e2e8f0;
        padding: 18px 5%;
        display: flex;
        justify-content: space-between;
        align-items: center;
        gap: 16px;
        flex-wrap: wrap;
    }

    .brand {
        font-size: 21px;
        font-weight: 800;
        color: #0f766e;
    }

    .header-right {
        display: flex;
        align-items: center;
        gap: 16px;
        flex-wrap: wrap;
    }

    .username {
        color: #475569;
        font-size: 14px;
    }

    .logout {
        text-decoration: none;
        color: #b91c1c;
        font-weight: 600;
        font-size: 14px;
    }

    .container {
        width: 90%;
        max-width: 1150px;
        margin: 32px auto;
    }

    .page-heading {
        margin-bottom: 22px;
    }

    .page-heading h1 {
        margin: 0 0 8px;
        font-size: 28px;
    }

    .page-heading p {
        margin: 0;
        color: #64748b;
        line-height: 1.6;
    }

    .search-panel,
    .results-panel {
        background: #ffffff;
        border: 1px solid #e2e8f0;
        border-radius: 14px;
        padding: 22px;
        margin-bottom: 22px;
        box-shadow: 0 4px 14px rgba(15, 23, 42, 0.04);
    }

    .search-form {
        display: flex;
        gap: 10px;
    }

    .search-form input {
        flex: 1;
        min-width: 0;
        padding: 13px 15px;
        border: 1px solid #cbd5e1;
        border-radius: 9px;
        font-size: 15px;
        outline: none;
    }

    .search-form input:focus {
        border-color: #0d9488;
        box-shadow: 0 0 0 3px rgba(13, 148, 136, 0.12);
    }

    .btn {
        display: inline-block;
        border: none;
        border-radius: 9px;
        padding: 12px 17px;
        font-weight: 700;
        font-size: 14px;
        cursor: pointer;
        text-decoration: none;
        text-align: center;
    }

    .btn-primary {
        background: #0f766e;
        color: #ffffff;
    }

    .btn-secondary {
        background: #e2e8f0;
        color: #334155;
    }

    .result-heading {
        display: flex;
        justify-content: space-between;
        align-items: center;
        gap: 12px;
        flex-wrap: wrap;
        margin-bottom: 16px;
    }

    .result-heading h2 {
        margin: 0;
        font-size: 19px;
    }

    .count {
        color: #64748b;
        font-size: 13px;
    }

    .result-list {
        display: grid;
        gap: 13px;
    }

    .result-card {
        border: 1px solid #e2e8f0;
        border-radius: 11px;
        padding: 17px;
        display: flex;
        justify-content: space-between;
        align-items: center;
        gap: 16px;
        flex-wrap: wrap;
    }

    .result-type {
        display: inline-block;
        background: #ccfbf1;
        color: #115e59;
        padding: 5px 9px;
        border-radius: 20px;
        font-size: 11px;
        font-weight: 800;
        margin-bottom: 8px;
    }

    .result-card h3 {
        margin: 0 0 7px;
        font-size: 17px;
        overflow-wrap: anywhere;
    }

    .description {
        color: #64748b;
        font-size: 13px;
        line-height: 1.6;
        overflow-wrap: anywhere;
    }

    .status {
        color: #334155;
        font-size: 12px;
        font-weight: 700;
        margin-top: 7px;
    }

    .empty-state {
        text-align: center;
        padding: 35px 12px;
        color: #64748b;
        line-height: 1.7;
    }

    .empty-state strong {
        display: block;
        color: #334155;
        font-size: 17px;
        margin-bottom: 8px;
    }

    .footer {
        text-align: center;
        padding: 22px;
        color: #94a3b8;
        font-size: 12px;
    }

    @media (max-width: 600px) {
        .container {
            width: 94%;
            margin-top: 22px;
        }

        .search-panel,
        .results-panel {
            padding: 16px;
        }

        .search-form {
            flex-direction: column;
        }

        .search-form .btn {
            width: 100%;
        }

        .page-heading h1 {
            font-size: 24px;
        }

        .result-card {
            align-items: flex-start;
        }
    }
</style>
</head>

<body>

<header class="header">
    <div class="brand">CityCare Hospital</div>

    <div class="header-right">
        <span class="username">
            Welcome, <%= escapeHtml(username) %>
        </span>

        <a class="logout"
           href="<%= contextPath %>/logout">Logout</a>
    </div>
</header>

<main class="container">

    <section class="page-heading">
        <h1>Hospital Record Search</h1>
        <p>Find patient records, doctor information, and appointments.</p>
    </section>

    <section class="search-panel">
        <form class="search-form"
              action="<%= contextPath %>/search"
              method="get">

            <input type="search"
                   name="q"
                   value="<%= escapeHtml(searchQuery) %>"
                   maxlength="100"
                   placeholder="Search by name, ID, phone, or keyword..."
                   aria-label="Search hospital records"
                   required>

            <button class="btn btn-primary" type="submit">
                Search Records
            </button>

            <a class="btn btn-secondary"
               href="<%= contextPath %>/dashboard">Dashboard</a>
        </form>
    </section>

    <section class="results-panel">
        <div class="result-heading">
            <h2>Search Results</h2>
            <span class="count">
                <%= searchResults.size() %> record(s) displayed
            </span>
        </div>

        <% if (searchMessage != null && searchResults.isEmpty()) { %>

            <div class="empty-state">
                <strong>Nothing to display</strong>
                <%= escapeHtml(searchMessage) %>
            </div>

        <% } else if (searchResults.isEmpty()) { %>

            <div class="empty-state">
                <strong>Start your search</strong>
                Enter a keyword above to find hospital records.
            </div>

        <% } else { %>

            <div class="result-list">

                <% for (SearchResult result : searchResults) { %>

                    <article class="result-card">
                        <div>
                            <span class="result-type">
                                <%= escapeHtml(result.getType()) %>
                            </span>

                            <h3>
                                <%= escapeHtml(result.getTitle()) %>
                            </h3>

                            <div class="description">
                                <%= escapeHtml(result.getDescription()) %>
                            </div>

                            <% if (result.getStatus() != null
                                   && !result.getStatus().isBlank()) { %>
                                <div class="status">
                                    Status: <%= escapeHtml(result.getStatus()) %>
                                </div>
                            <% } %>
                        </div>

                        <div>
                            <a class="btn btn-secondary"
                               href="<%= contextPath
                                   + escapeHtml(result.getUrl()) %>">
                                Open Module
                            </a>
                        </div>
                    </article>

                <% } %>

            </div>

        <% } %>
    </section>

</main>

<footer class="footer">
    CityCare Hospital Management System
</footer>

</body>
</html>
