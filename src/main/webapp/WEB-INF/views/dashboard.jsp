<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.Map,java.util.List,java.util.Collections" %>
<%
String role = (String) session.getAttribute("role");

if (role == null || session.getAttribute("userId") == null) {
    response.sendRedirect(request.getContextPath() + "/login");
    return;
}

role = role.trim().toUpperCase();
String contextPath = request.getContextPath();

String username = (String) session.getAttribute("username");
if (username == null || username.trim().isEmpty()) {
    username = "User";
}

String safeUsername = username
    .replace("&", "&amp;")
    .replace("<", "&lt;")
    .replace(">", "&gt;")
    .replace("\"", "&quot;")
    .replace("'", "&#39;");

boolean admin = "ADMIN".equals(role);
boolean doctor = "DOCTOR".equals(role);
boolean receptionist = "RECEPTIONIST".equals(role);
boolean staff = "STAFF".equals(role);
boolean recognizedRole = admin || doctor || receptionist || staff;

if (!recognizedRole) {
    response.sendRedirect(request.getContextPath() + "/logout");
    return;
}
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CityCare Hospital | Dashboard</title>


<style>
    /* ==================================================
       1. GLOBAL THEME AND LAYOUT
       UPDATED: Sidebar width reduced from 258px to 239px.
       ================================================== */

    :root {
        --primary: #2563eb;
        --primary-dark: #1d4ed8;
        --primary-light: #eff6ff;
        --sidebar-bg: #ffffff;
        --page-bg: #f5f7fb;
        --card-bg: #ffffff;
        --text-primary: #172b4d;
        --text-secondary: #64748b;
        --border: #e5eaf2;
        --success: #16a34a;
        --warning: #d97706;
        --danger: #dc2626;

        --sidebar-width: 210px; 
        --header-height: 76px;
        --radius: 14px;
        --shadow: 0 2px 12px rgba(15, 23, 42, 0.04);
    }

    * {
        box-sizing: border-box;
    }

    html {
        scroll-behavior: smooth;
    }

    body {
        margin: 0;
        font-family: "Segoe UI", Arial, sans-serif;
        background: var(--page-bg);
        color: var(--text-primary);
        font-size: 14px;
    }

    button,
    input,
    select {
        font: inherit;
    }

    button,
    a,
    select {
        -webkit-tap-highlight-color: transparent;
    }

    a {
        color: inherit;
        text-decoration: none;
    }

    button {
        cursor: pointer;
    }

    .app-layout {
    	display: block;
    	min-height: 100vh;
	}

    .sidebar {
    		position: fixed;
	    top: 0;
	    left: 0;
	    width: 210px;
	    height: 100vh;
	    z-index: 100;
	    display: flex;
	    flex-direction: column;
	    background: var(--sidebar-bg);
	    border-right: 1px solid var(--border);
	    overflow: hidden;
	    transform: translateX(0);
	    transition: transform 0.25s ease;
    }

    .main-area {
        margin-left: 220px;
    		width: calc(100% - 220px);
    		min-height: 100vh;
    		min-width: 0;
	    box-sizing: border-box;
    }

    .top-header {
        height: var(--header-height);
        background: var(--card-bg);
        border-bottom: 1px solid var(--border);
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 18px;
        padding: 0 30px;
        position: sticky;
        top: 0;
        z-index: 50;
        margin-left: -10px;
        width: calc(100% + 10px);
        box-sizing: border-box;
    }

    .page-content {
        padding: 42px 10px 34px 40px;
        max-width: 1800px;
        margin: 0 auto;
    }

    .card {
        background: var(--card-bg);
        border: 1px solid var(--border);
        border-radius: var(--radius);
        box-shadow: var(--shadow);
        min-width: 0;
    }

    .card-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        gap: 12px;
        margin-bottom: 18px;
    }

    .section-title {
        margin: 0;
        font-size: 17px;
        font-weight: 700;
        color: var(--text-primary);
    }

    .section-subtitle {
        margin: 5px 0 0;
        color: var(--text-secondary);
        font-size: 12px;
        line-height: 1.5;
    }

    .muted {
        color: var(--text-secondary);
    }

    /* ==================================================
       2. BUTTONS, BADGES, TABLES AND FORMS
       ================================================== */

    .btn {
        display: inline-flex;
        justify-content: center;
        align-items: center;
        gap: 8px;
        min-height: 38px;
        padding: 9px 14px;
        border: 1px solid var(--border);
        border-radius: 9px;
        background: #ffffff;
        color: var(--text-primary);
        font-weight: 600;
        font-size: 12px;
        transition: background 0.2s, border-color 0.2s;
    }

    .btn:hover {
        background: #f8fafc;
        border-color: #cbd5e1;
    }

    .btn-primary {
        color: #ffffff;
        background: var(--primary);
        border-color: var(--primary);
    }

    .btn-primary:hover {
        background: var(--primary-dark);
        border-color: var(--primary-dark);
    }

    .icon-btn {
        width: 40px;
        height: 40px;
        display: inline-flex;
        justify-content: center;
        align-items: center;
        border: 1px solid var(--border);
        border-radius: 10px;
        background: #ffffff;
        color: #475569;
        font-size: 18px;
        position: relative;
    }

    .icon-btn:hover {
        background: var(--primary-light);
        color: var(--primary);
    }

    .status-badge {
        display: inline-flex;
        align-items: center;
        gap: 5px;
        padding: 5px 9px;
        border-radius: 20px;
        font-size: 11px;
        font-weight: 700;
        white-space: nowrap;
    }

    .status-success {
        background: #dcfce7;
        color: #166534;
    }

    .status-warning {
        background: #fef3c7;
        color: #92400e;
    }

    .status-danger {
        background: #fee2e2;
        color: #991b1b;
    }

    .status-info {
        background: #dbeafe;
        color: #1d4ed8;
    }

    .empty-state {
        padding: 28px 16px;
        text-align: center;
        color: var(--text-secondary);
        font-size: 13px;
    }

    .empty-state strong {
        display: block;
        margin-bottom: 6px;
        color: var(--text-primary);
    }

    .table-wrap {
        width: 100%;
        overflow-x: auto;
    }

    .data-table {
        width: 100%;
        border-collapse: collapse;
        text-align: left;
    }

    .data-table th {
        padding: 12px 14px;
        color: var(--text-secondary);
        background: #f8fafc;
        font-size: 11px;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 0.04em;
        white-space: nowrap;
    }

    .data-table td {
        padding: 14px;
        border-top: 1px solid var(--border);
        color: #334155;
        vertical-align: middle;
    }

    .data-table tbody tr:hover {
        background: #fafcff;
    }

    .form-control {
        width: 100%;
        min-height: 40px;
        padding: 9px 12px;
        border: 1px solid var(--border);
        border-radius: 9px;
        background: #ffffff;
        color: var(--text-primary);
        outline: none;
    }

    .form-control:focus {
        border-color: var(--primary);
        box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.10);
    }

    .text-link {
        color: var(--primary);
        font-weight: 600;
    }

    .text-link:hover {
        color: var(--primary-dark);
    }

    .mobile-menu-btn {
        display: none;
    }

    .sidebar-overlay {
        display: none;
    }

    /* ==================================================
       3. CITYCARE SIDEBAR
       ================================================== */

    .sidebar-brand {
        min-height: 82px;
        display: flex;
        align-items: center;
        gap: 8px;
        padding: 18px 20px;
        border-bottom: 1px solid var(--border);
    }

    .brand-logo {
        width: 44px;
        height: 44px;
        flex-shrink: 0;
        display: flex;
        align-items: center;
        justify-content: center;
        background: linear-gradient(135deg, #2563eb, #60a5fa);
        color: #ffffff;
        border-radius: 13px;
        font-size: 25px;
        font-weight: 800;
        box-shadow: 0 4px 10px rgba(37, 99, 235, 0.18);
    }

    .brand-name {
        margin: 0;
        font-size: 18px;
        font-weight: 800;
        letter-spacing: -0.5px;
        color: #173b68;
    }

    .brand-subtitle {
        margin-top: 4px;
        font-size: 10px;
        color: var(--text-secondary);
        letter-spacing: 1.2px;
        text-transform: uppercase;
    }

    .sidebar-search {
        padding: 18px 16px 12px;
    }

    .sidebar-search-box {
        display: flex;
        align-items: center;
        gap: 8px;
        padding: 0 10px;
        min-height: 40px;
        background: #f8fafc;
        border: 1px solid var(--border);
        border-radius: 9px;
    }

    .sidebar-search-box span {
        color: #94a3b8;
        font-size: 16px;
    }

    .sidebar-search-box input {
        min-width: 0;
        width: 100%;
        border: 0;
        outline: 0;
        background: transparent;
        color: var(--text-primary);
        font-size: 12px;
    }

    .shortcut-key {
        flex-shrink: 0;
        padding: 3px 5px;
        border: 1px solid #dbe2ea;
        border-radius: 5px;
        background: #ffffff;
        color: #64748b;
        font-size: 10px;
    }

    .sidebar-nav {
        flex: 1;
        min-height: 0;
        overflow-y: auto;
        padding: 4px 12px 16px;
    }

    .nav-section {
        margin: 18px 10px 8px;
        color: #94a3b8;
        font-size: 10px;
        font-weight: 800;
        letter-spacing: 1.1px;
        text-transform: uppercase;
    }

    .nav-link {
        display: flex;
        align-items: center;
        gap: 12px;
        min-height: 42px;
        padding: 10px 12px;
        margin: 3px 0;
        color: #52627a;
        border-radius: 9px;
        font-size: 12px;
        font-weight: 600;
        transition: background 0.2s, color 0.2s;
    }

    .nav-icon {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        width: 22px;
        flex-shrink: 0;
        font-size: 17px;
    }

    .nav-link:hover {
        color: var(--primary);
        background: #f1f6ff;
    }

    .nav-link.active {
        color: var(--primary);
        background: #eaf2ff;
        font-weight: 700;
    }

    .nav-link.active .nav-icon {
        color: var(--primary);
    }

    .sidebar-footer {
        padding: 14px 14px 16px;
        border-top: 1px solid var(--border);
        background: #ffffff;
    }

    .sidebar-user {
        display: flex;
        align-items: center;
        gap: 10px;
        padding: 6px 4px 12px;
        min-width: 0;
    }

    .user-avatar {
        width: 38px;
        height: 38px;
        flex-shrink: 0;
        display: flex;
        align-items: center;
        justify-content: center;
        background: #dbeafe;
        color: #1d4ed8;
        border-radius: 50%;
        font-weight: 800;
        font-size: 14px;
    }

    .sidebar-user-details {
        flex: 1;
        min-width: 0;
    }

    .sidebar-user-name {
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
        color: var(--text-primary);
        font-size: 12px;
        font-weight: 700;
    }

    .sidebar-user-role {
        margin-top: 4px;
        color: var(--text-secondary);
        font-size: 10px;
        text-transform: capitalize;
    }

    .logout-link {
        display: flex;
        align-items: center;
        gap: 10px;
        padding: 10px 12px;
        border-radius: 9px;
        color: #dc2626;
        font-size: 12px;
        font-weight: 700;
    }

    .logout-link:hover {
        background: #fef2f2;
    }

    /* ==================================================
       4. TOP HEADER
       ================================================== */

    .header-left {
        display: flex;
        align-items: center;
        gap: 14px;
        min-width: 0;
        flex: 1;
    }

    .header-page-title {
        margin: 0;
        font-size: 19px;
        font-weight: 750;
        color: var(--text-primary);
        white-space: nowrap;
    }

    .header-search {
        width: 100%;
        max-width: 390px;
        position: relative;
    }

    .header-search-form {
        display: flex;
        align-items: center;
        gap: 9px;
        height: 42px;
        padding: 0 12px;
        border: 1px solid var(--border);
        border-radius: 10px;
        background: #f8fafc;
    }

    .header-search-form:focus-within {
        background: #ffffff;
        border-color: var(--primary);
        box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.08);
    }

    .header-search-icon {
        color: #94a3b8;
        font-size: 18px;
        flex-shrink: 0;
    }

    .header-search-input {
        width: 100%;
        min-width: 0;
        border: 0;
        outline: 0;
        background: transparent;
        color: var(--text-primary);
        font-size: 12px;
    }

    .header-search-input::placeholder {
        color: #94a3b8;
    }

    .header-actions {
        display: flex;
        align-items: center;
        justify-content: flex-end;
        gap: 10px;
        flex-shrink: 0;
    }

    .header-divider {
        height: 34px;
        width: 1px;
        background: var(--border);
        margin: 0 3px;
    }

    .notification-dot {
        position: absolute;
        top: 8px;
        right: 8px;
        width: 7px;
        height: 7px;
        background: #ef4444;
        border: 1px solid #ffffff;
        border-radius: 50%;
    }

    .header-profile {
        display: flex;
        align-items: center;
        gap: 10px;
        padding-left: 4px;
        min-width: 0;
    }

    .header-profile-info {
        min-width: 0;
    }

    .header-profile-name {
        max-width: 150px;
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
        font-size: 12px;
        font-weight: 700;
        color: var(--text-primary);
    }

    .header-profile-role {
        margin-top: 4px;
        color: var(--text-secondary);
        font-size: 10px;
        text-transform: capitalize;
    }

    .header-profile .user-avatar {
        width: 38px;
        height: 38px;
    }

    .mobile-menu-btn {
        align-items: center;
        justify-content: center;
        width: 40px;
        height: 40px;
        border: 1px solid var(--border);
        border-radius: 9px;
        background: #ffffff;
        color: var(--text-primary);
        font-size: 20px;
        flex-shrink: 0;
    }

    .header-action-label {
        display: inline;
    }

    /* ==================================================
       5. WELCOME SECTION
       ================================================== */

    .welcome-section {
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 20px;
        margin-top: 12px;
        margin-bottom: 36px;
    }

    .welcome-title {
        margin: 0;
        color: var(--text-primary);
        font-size: 26px;
        font-weight: 800;
        letter-spacing: -0.7px;
        line-height: 1.3;
    }

    .welcome-title .welcome-name {
        color: var(--primary);
    }

    .welcome-description {
        margin: 9px 0 0;
        color: var(--text-secondary);
        font-size: 13px;
        line-height: 1.6;
    }

    .welcome-date {
        display: inline-flex;
        align-items: center;
        gap: 9px;
        flex-shrink: 0;
        padding: 12px 15px;
        border: 1px solid var(--border);
        border-radius: 10px;
        background: #ffffff;
        color: #475569;
        font-size: 12px;
        font-weight: 600;
    }

    .welcome-date-icon {
        color: var(--primary);
        font-size: 18px;
    }

    /* ==================================================
       6. KPI CARDS
       UPDATED: Desktop grid gap reduced to 4px.
       ================================================== */

    .kpi-grid {
        display: grid;
        grid-template-columns: repeat(4, minmax(0, 1fr));
        gap: 4px; /* UPDATED */
        margin-bottom: 24px; /* UPDATED */
    }

    .kpi-card {
        position: relative;
        padding: 20px; /* UPDATED */
        overflow: hidden;
        transition: transform 0.2s ease, box-shadow 0.2s ease;
    }

    .kpi-card:hover {
        transform: translateY(-3px);
        box-shadow: 0 8px 22px rgba(15, 23, 42, 0.07);
    }

    .kpi-top {
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 10px;
        margin-bottom: 21px;
    }

    .kpi-label {
        color: var(--text-secondary);
        font-size: 12px;
        font-weight: 600;
        line-height: 1.5;
    }

    .kpi-icon {
        display: flex;
        align-items: center;
        justify-content: center;
        width: 45px;
        height: 45px;
        flex-shrink: 0;
        border-radius: 12px;
        font-size: 22px;
    }

    .kpi-icon-blue {
        color: #2563eb;
        background: #eaf2ff;
    }

    .kpi-icon-green {
        color: #15803d;
        background: #dcfce7;
    }

    .kpi-icon-orange {
        color: #c2410c;
        background: #ffedd5;
    }

    .kpi-icon-purple {
        color: #7c3aed;
        background: #ede9fe;
    }

    .kpi-value {
        margin: 0;
        color: var(--text-primary);
        font-size: 30px;
        line-height: 1.2;
        font-weight: 800;
        letter-spacing: -0.7px;
        overflow-wrap: anywhere;
    }

    .kpi-description {
        margin-top: 10px;
        color: var(--text-secondary);
        font-size: 11px;
        line-height: 1.5;
    }

    .kpi-footer {
        display: flex;
        align-items: center;
        gap: 6px;
        margin-top: 17px;
        padding-top: 13px;
        border-top: 1px solid #f0f2f6;
        font-size: 11px;
        color: var(--text-secondary);
    }

    .kpi-footer-link {
        color: var(--primary);
        font-weight: 700;
    }

    .kpi-footer-link:hover {
        text-decoration: underline;
    }

    /* ==================================================
       7. ANALYTICS LAYOUT
       UPDATED: Desktop grid gap reduced to 4px.
       ================================================== */

    .analytics-grid {
        display: grid;
        grid-template-columns: minmax(0, 1.7fr) minmax(280px, 1fr);
        gap: 4px; /* UPDATED */
        margin-bottom: 24px; /* UPDATED */
    }

    .analytics-card {
        padding: 20px; /* UPDATED */
        min-width: 0;
    }

    .analytics-toolbar {
        display: flex;
        align-items: center;
        gap: 8px;
    }

    .period-select {
        max-width: 140px;
        min-height: 36px;
        padding: 7px 10px;
        border: 1px solid var(--border);
        border-radius: 8px;
        background: #ffffff;
        color: #475569;
        font-size: 12px;
    }

    .chart-legend {
        display: flex;
        align-items: center;
        gap: 7px;
        margin-top: 18px;
        color: var(--text-secondary);
        font-size: 11px;
    }

    .legend-dot {
        width: 8px;
        height: 8px;
        border-radius: 50%;
        background: #3b82f6;
    }

    .trend-chart {
        display: flex;
        align-items: stretch;
        gap: 10px;
        height: 215px;
        padding: 16px 4px 0;
        border-bottom: 1px solid var(--border);
        background: repeating-linear-gradient(
            to bottom,
            transparent 0,
            transparent 52px,
            #edf1f7 53px,
            transparent 54px
        );
    }

    .trend-column {
        display: flex;
        flex: 1;
        min-width: 0;
        flex-direction: column;
        justify-content: flex-end;
        align-items: center;
        gap: 9px;
    }

    .trend-bar-area {
        display: flex;
        align-items: flex-end;
        justify-content: center;
        width: 100%;
        flex: 1;
        min-height: 0;
    }

    .trend-bar {
        width: min(32px, 75%);
        min-height: 4px;
        border-radius: 6px 6px 0 0;
        background: linear-gradient(180deg, #60a5fa, #2563eb);
        transition: opacity 0.2s, height 0.2s;
    }

    .trend-bar:hover {
        opacity: 0.75;
    }

    .trend-label {
        width: 100%;
        padding-bottom: 10px;
        color: var(--text-secondary);
        font-size: 10px;
        text-align: center;
        overflow-wrap: anywhere;
    }

    .trend-total {
        color: #334155;
        font-size: 11px;
        font-weight: 700;
    }

    /* ==================================================
       8. STATUS SUMMARIES
       ================================================== */

    .summary-list {
        display: flex;
        flex-direction: column;
        gap: 17px;
    }

    .summary-row {
        display: flex;
        flex-direction: column;
        gap: 8px;
    }

    .summary-row-top {
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 12px;
    }

    .summary-label {
        display: flex;
        align-items: center;
        gap: 8px;
        color: #475569;
        font-size: 12px;
    }

    .summary-value {
        color: var(--text-primary);
        font-size: 13px;
        font-weight: 800;
    }

    .summary-track {
        height: 7px;
        width: 100%;
        overflow: hidden;
        border-radius: 20px;
        background: #edf1f7;
    }

    .summary-fill {
        height: 100%;
        min-width: 0;
        border-radius: inherit;
    }

    .fill-blue {
        background: #3b82f6;
    }

    .fill-green {
        background: #22c55e;
    }

    .fill-purple {
        background: #8b5cf6;
    }

    .fill-orange {
        background: #f59e0b;
    }

    .fill-red {
        background: #ef4444;
    }

    .fill-gray {
        background: #94a3b8;
    }

    /* UPDATED: Reduced desktop gap between summary panels. */
    .analytics-bottom {
        display: grid;
        grid-template-columns: repeat(2, minmax(0, 1fr));
        gap: 4px;
        margin-bottom: 24px;
    }

    .emergency-highlight {
        display: flex;
        align-items: center;
        gap: 14px;
        margin-bottom: 22px;
        padding: 15px;
        border-radius: 11px;
        background: #fff7ed;
        border: 1px solid #ffedd5;
    }

    .emergency-highlight-icon {
        display: flex;
        align-items: center;
        justify-content: center;
        width: 44px;
        height: 44px;
        flex-shrink: 0;
        border-radius: 11px;
        background: #ffedd5;
        color: #c2410c;
        font-size: 22px;
    }

    .emergency-highlight-label {
        color: #9a3412;
        font-size: 11px;
        font-weight: 600;
    }

    .emergency-highlight-value {
        margin-top: 4px;
        color: #7c2d12;
        font-size: 24px;
        font-weight: 800;
    }

    /* ==================================================
       9. DOCTOR AND STAFF OVERVIEW
       UPDATED: Desktop grid gap reduced to 4px.
       ================================================== */

    .operations-grid {
        display: grid;
        grid-template-columns: repeat(2, minmax(0, 1fr));
        gap: 4px; /* UPDATED */
        margin-bottom: 24px; /* UPDATED */
    }

    .operations-card {
        padding: 20px; /* UPDATED */
        min-width: 0;
    }

    .operations-stat {
        display: flex;
        align-items: center;
        gap: 15px;
        padding: 17px;
        margin-bottom: 18px;
        border: 1px solid var(--border);
        border-radius: 12px;
        background: #fafcff;
    }

    .operations-stat-icon {
        display: flex;
        align-items: center;
        justify-content: center;
        width: 52px;
        height: 52px;
        flex-shrink: 0;
        border-radius: 13px;
        font-size: 25px;
    }

    .operations-stat-value {
        font-size: 28px;
        font-weight: 800;
        line-height: 1.2;
        color: var(--text-primary);
    }

    .operations-stat-label {
        margin-top: 5px;
        font-size: 12px;
        color: var(--text-secondary);
    }

    .operations-links {
        display: grid;
        grid-template-columns: repeat(2, minmax(0, 1fr));
        gap: 10px;
    }

    .operations-link {
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 10px;
        min-width: 0;
        padding: 13px;
        border: 1px solid var(--border);
        border-radius: 9px;
        background: #ffffff;
        color: #334155;
        font-size: 12px;
        font-weight: 600;
        transition: background 0.2s, border-color 0.2s;
    }

    .operations-link:hover {
        background: var(--primary-light);
        border-color: #bfdbfe;
        color: var(--primary);
    }

    .operations-link span:first-child {
        min-width: 0;
    }

    /* ==================================================
       10. APPOINTMENT SCHEDULE
       ================================================== */

    .schedule-section {
        padding: 22px;
        margin-bottom: 24px;
        min-width: 0;
    }

    .schedule-date-label {
        padding: 8px 12px;
        border: 1px solid var(--border);
        border-radius: 8px;
        background: #ffffff;
        color: var(--text-secondary);
        font-size: 12px;
        white-space: nowrap;
    }

    .schedule-empty {
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        min-height: 180px;
        padding: 25px 16px;
        text-align: center;
        color: var(--text-secondary);
    }

    .schedule-empty-icon {
        display: flex;
        align-items: center;
        justify-content: center;
        width: 50px;
        height: 50px;
        margin-bottom: 12px;
        border-radius: 14px;
        background: var(--primary-light);
        color: var(--primary);
        font-size: 23px;
    }

    .schedule-empty strong {
        margin-bottom: 7px;
        color: var(--text-primary);
        font-size: 14px;
    }

    .schedule-empty p {
        max-width: 400px;
        margin: 0 0 15px;
        font-size: 12px;
        line-height: 1.6;
    }

    /* ==================================================
       11. HOSPITAL RESOURCE PANELS
       UPDATED: Desktop grid gap reduced to 4px.
       ================================================== */

    .resource-grid {
        display: grid;
        grid-template-columns: repeat(3, minmax(0, 1fr));
        gap: 4px; /* UPDATED */
        margin-bottom: 24px; /* UPDATED */
    }

    .resource-card {
        padding: 20px;
        min-width: 0;
    }

    .resource-card-top {
        display: flex;
        align-items: flex-start;
        justify-content: space-between;
        gap: 12px;
        margin-bottom: 18px;
    }

    .resource-icon {
        display: flex;
        align-items: center;
        justify-content: center;
        width: 46px;
        height: 46px;
        flex-shrink: 0;
        border-radius: 12px;
        font-size: 23px;
    }

    .resource-main-value {
        margin: 0;
        font-size: 27px;
        font-weight: 800;
        color: var(--text-primary);
    }

    .resource-main-label {
        margin-top: 5px;
        color: var(--text-secondary);
        font-size: 12px;
    }

    .resource-divider {
        height: 1px;
        background: var(--border);
        margin: 16px 0;
    }

    .resource-link {
        display: flex;
        justify-content: space-between;
        align-items: center;
        gap: 10px;
        color: var(--primary);
        font-size: 12px;
        font-weight: 700;
    }

    .resource-link:hover {
        color: var(--primary-dark);
    }

    .resource-description {
        margin: 0 0 15px;
        color: var(--text-secondary);
        font-size: 12px;
        line-height: 1.7;
    }

    /* UPDATED: Desktop gap reduced to 4px. */
    .operations-wide-grid {
        display: grid;
        grid-template-columns: repeat(2, minmax(0, 1fr));
        gap: 4px;
        margin-bottom: 24px;
    }

    .operations-wide-card {
        padding: 20px;
        min-width: 0;
    }

    .operation-shortcuts {
        display: grid;
        grid-template-columns: repeat(2, minmax(0, 1fr));
        gap: 10px;
    }

    .operation-shortcut {
        display: flex;
        align-items: center;
        gap: 11px;
        min-width: 0;
        padding: 13px;
        border: 1px solid var(--border);
        border-radius: 10px;
        background: #ffffff;
        transition: background 0.2s, border-color 0.2s;
    }

    .operation-shortcut:hover {
        background: var(--primary-light);
        border-color: #bfdbfe;
    }

    .operation-shortcut-icon {
        display: flex;
        align-items: center;
        justify-content: center;
        width: 38px;
        height: 38px;
        flex-shrink: 0;
        border-radius: 10px;
        background: #eaf2ff;
        color: var(--primary);
        font-size: 19px;
    }

    .operation-shortcut-title {
        color: var(--text-primary);
        font-size: 12px;
        font-weight: 700;
        line-height: 1.4;
    }

    .operation-shortcut-description {
        margin-top: 4px;
        color: var(--text-secondary);
        font-size: 10px;
        line-height: 1.4;
    }

    /* ==================================================
       12. EMERGENCY BANNER
       ================================================== */

    .emergency-banner {
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 18px;
        padding: 22px;
        margin-bottom: 24px;
        border: 1px solid #fecaca;
        border-radius: var(--radius);
        background: linear-gradient(110deg, #fff7f7, #ffffff);
    }

    .emergency-banner-content {
        display: flex;
        align-items: center;
        gap: 14px;
        min-width: 0;
    }

    .emergency-banner-icon {
        display: flex;
        align-items: center;
        justify-content: center;
        width: 50px;
        height: 50px;
        flex-shrink: 0;
        border-radius: 13px;
        background: #fee2e2;
        color: #b91c1c;
        font-size: 24px;
    }

    .emergency-banner-title {
        margin: 0;
        color: #991b1b;
        font-size: 16px;
        font-weight: 800;
    }

    .emergency-banner-text {
        margin: 6px 0 0;
        color: #7f1d1d;
        font-size: 12px;
        line-height: 1.6;
    }

    /* ==================================================
       13. EMERGENCY ASSISTANCE POPUP
       ================================================== */

    .emergency-modal {
        display: none;
        position: fixed;
        inset: 0;
        z-index: 500;
        align-items: center;
        justify-content: center;
        padding: 20px;
        background: rgba(15, 23, 42, 0.48);
        backdrop-filter: blur(3px);
    }

    .emergency-modal.modal-open {
        display: flex;
    }

    .emergency-dialog {
        width: 100%;
        max-width: 440px;
        max-height: min(85vh, 650px);
        overflow-y: auto;
        border-radius: 18px;
        background: #ffffff;
        box-shadow: 0 24px 80px rgba(15, 23, 42, 0.24);
        animation: emergencyModalIn 0.18s ease-out;
    }

    @keyframes emergencyModalIn {
        from {
            opacity: 0;
            transform: translateY(8px) scale(0.98);
        }

        to {
            opacity: 1;
            transform: translateY(0) scale(1);
        }
    }

    .emergency-dialog-header {
        display: flex;
        align-items: flex-start;
        justify-content: space-between;
        gap: 12px;
        padding: 22px 22px 18px;
        border-bottom: 1px solid var(--border);
    }

    .emergency-dialog-heading {
        display: flex;
        align-items: center;
        gap: 12px;
    }

    .emergency-dialog-icon {
        display: flex;
        align-items: center;
        justify-content: center;
        width: 46px;
        height: 46px;
        flex-shrink: 0;
        border-radius: 13px;
        background: #fee2e2;
        color: #b91c1c;
        font-size: 23px;
    }

    .emergency-dialog-title {
        margin: 0;
        color: #991b1b;
        font-size: 18px;
        font-weight: 800;
    }

    .emergency-dialog-subtitle {
        margin: 5px 0 0;
        color: var(--text-secondary);
        font-size: 12px;
        line-height: 1.5;
    }

    .emergency-close {
        display: flex;
        align-items: center;
        justify-content: center;
        width: 34px;
        height: 34px;
        flex-shrink: 0;
        border: 1px solid var(--border);
        border-radius: 9px;
        background: #ffffff;
        color: #64748b;
        font-size: 21px;
    }

    .emergency-close:hover {
        background: #f1f5f9;
        color: #0f172a;
    }

    .emergency-dialog-body {
        padding: 20px 22px 22px;
    }

    .emergency-call-card {
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 14px;
        padding: 16px;
        margin-bottom: 18px;
        border: 1px solid #fecaca;
        border-radius: 12px;
        background: #fff7f7;
    }

    .emergency-call-label {
        color: #991b1b;
        font-size: 12px;
        font-weight: 700;
    }

    .emergency-call-number {
        display: block;
        margin-top: 5px;
        color: #991b1b;
        font-size: 27px;
        font-weight: 900;
        letter-spacing: 1px;
    }

    .emergency-call-note {
        margin-top: 5px;
        color: #7f1d1d;
        font-size: 11px;
        line-height: 1.5;
    }

    .emergency-call-button {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        gap: 7px;
        padding: 10px 13px;
        flex-shrink: 0;
        border: 1px solid #dc2626;
        border-radius: 9px;
        background: #dc2626;
        color: #ffffff;
        font-size: 12px;
        font-weight: 800;
    }

    .emergency-call-button:hover {
        background: #b91c1c;
    }

    .emergency-options-title {
        margin: 0 0 12px;
        color: var(--text-primary);
        font-size: 13px;
        font-weight: 800;
    }

    .emergency-option {
        display: flex;
        align-items: center;
        gap: 12px;
        padding: 13px;
        margin-top: 9px;
        border: 1px solid var(--border);
        border-radius: 11px;
        background: #ffffff;
        transition: background 0.2s, border-color 0.2s;
    }

    .emergency-option:hover {
        background: #f8fbff;
        border-color: #bfdbfe;
    }

    .emergency-option-icon {
        display: flex;
        align-items: center;
        justify-content: center;
        width: 40px;
        height: 40px;
        flex-shrink: 0;
        border-radius: 10px;
        background: var(--primary-light);
        color: var(--primary);
        font-size: 20px;
    }

    .emergency-option-text {
        flex: 1;
        min-width: 0;
    }

    .emergency-option-title {
        color: var(--text-primary);
        font-size: 12px;
        font-weight: 800;
    }

    .emergency-option-description {
        margin-top: 4px;
        color: var(--text-secondary);
        font-size: 11px;
        line-height: 1.5;
    }

    .emergency-option-arrow {
        color: var(--primary);
        font-size: 18px;
    }

    .emergency-disclaimer {
        margin: 16px 0 0;
        color: var(--text-secondary);
        font-size: 10px;
        line-height: 1.6;
    }

    /* ==================================================
       14. DASHBOARD FOOTER
       ================================================== */

    .dashboard-footer {
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 14px;
        padding: 18px 0 4px;
        margin-top: 8px;
        border-top: 1px solid var(--border);
        color: var(--text-secondary);
        font-size: 11px;
        line-height: 1.6;
    }

    .dashboard-footer-brand {
        color: var(--text-primary);
        font-weight: 800;
    }

    .dashboard-footer-right {
        display: flex;
        align-items: center;
        justify-content: flex-end;
        gap: 8px;
        flex-wrap: wrap;
    }

    .dashboard-footer-dot {
        width: 7px;
        height: 7px;
        flex-shrink: 0;
        border-radius: 50%;
        background: #22c55e;
    }

    /* ==================================================
       15. RESPONSIVE LAYOUT
       UPDATED: 4px desktop gaps become readable gaps
       on smaller screens.
       ================================================== */

    @media (max-width: 1200px) {
        .page-content {
            padding: 32px 10px 24px 34px;
        }

        .top-header {
            padding: 0 22px;
        }

        /* UPDATED: Maintain modest spacing on tablets. */
        .kpi-grid {
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 10px;
        }

        .analytics-grid {
            grid-template-columns: minmax(0, 1fr);
            gap: 10px;
        }

        .analytics-bottom {
            gap: 10px;
        }

        .operations-grid,
        .operations-wide-grid {
            gap: 10px;
        }

        .resource-grid {
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 10px;
        }
    }

    @media (max-width: 1150px) {
        .header-page-title {
            display: none;
        }

        .header-search {
            max-width: 360px;
        }
    }

    @media (max-width: 900px) {
    	/* UPDATED: Remove desktop spacing on mobile */
		.app-layout {
    		gap: 0px;
		}
        /* FIX: Mobile sidebar starts hidden */
		.sidebar {
    			position: fixed;
		    top: 0;
		    left: 0;
		    width: 210px;
			height: 100vh;
    			z-index: 100;
    			transform: translateX(-100%);
    			transition: transform 0.25s ease;
		}

		/* FIX: Show sidebar when its open class is applied */
		.sidebar.sidebar-open {
    			transform: translateX(0);
		}

		/* FIX: Keep the mobile page aligned */
		.main-area {
    			margin-left: 0;
    			width: 100%;
		}

		/* FIX: Overlay behind the sidebar */
		.sidebar-overlay.overlay-visible {
		    display: block;
		    position: fixed;
		    inset: 0;
		    background: rgba(15, 23, 42, 0.4);
		    z-index: 90;
		}
        .mobile-menu-btn {
            display: inline-flex;
        }

        .top-header {
        		margin-left: 0;
        		width: 100%;
            padding: 0 18px;
        }

        .header-search {
            max-width: 320px;
        }

        .header-actions {
            gap: 7px;
        }

        .header-profile-info,
        .header-profile > .user-avatar {
            display: none;
        }

        .operations-grid,
        .operations-wide-grid {
            grid-template-columns: minmax(0, 1fr);
        }
    }

    @media (max-width: 700px) {
        .analytics-bottom {
            grid-template-columns: minmax(0, 1fr);
            gap: 10px;
        }

        .card-header {
            align-items: flex-start;
            flex-wrap: wrap;
        }

        .trend-chart {
            gap: 5px;
        }

        .trend-label {
            font-size: 9px;
        }
    }

    @media (max-width: 650px) {
        .top-header {
            gap: 8px;
        }

        .header-left {
            flex: 1;
        }

        .header-search {
            max-width: none;
        }

        .header-actions .header-export,
        .header-actions .header-report,
        .header-actions .header-divider {
            display: none;
        }

        .header-actions {
            gap: 5px;
        }
    }

    @media (max-width: 600px) {
        :root {
            --header-height: 64px;
        }

        .top-header {
            gap: 10px;
            padding: 0 12px;
        }

        .page-content {
            padding: 26px 14px 30px;
            padding-right: 10px
        }

        .top-header .header-search {
            display: none;
        }

        .section-title {
            font-size: 16px;
        }

        .btn {
            padding: 8px 10px;
        }

        /* UPDATED: Keep the sidebar compact but readable. */
        .sidebar-brand {
            padding-left: 16px;
            padding-right: 16px;
        }

        .sidebar-nav {
            padding-left: 10px;
            padding-right: 10px;
        }

        /* UPDATED: Responsive welcome spacing; syntax corrected. */
        .welcome-section {
            align-items: flex-start;
            flex-direction: column;
            gap: 14px;
            margin-top: 6px;
            margin-bottom: 24px;
        }

        .welcome-title {
            font-size: 23px;
        }

        .welcome-date {
            padding: 10px 12px;
        }

        /* UPDATED: Small-screen gaps are larger than 4px
           to keep separate cards easy to read and tap. */
        .kpi-grid {
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 10px;
            margin-bottom: 22px;
        }

        .kpi-card {
            padding: 15px;
        }

        .kpi-top {
            align-items: flex-start;
            flex-direction: column-reverse;
            gap: 12px;
            margin-bottom: 15px;
        }

        .kpi-icon {
            width: 38px;
            height: 38px;
            font-size: 19px;
        }

        .kpi-value {
            font-size: 25px;
        }

        .kpi-footer {
            align-items: flex-start;
            flex-wrap: wrap;
        }

        .analytics-grid,
        .analytics-bottom {
            gap: 10px;
            margin-bottom: 24px;
        }

        .analytics-card {
            padding: 15px;
        }

        .operations-grid,
        .resource-grid,
        .operations-wide-grid {
            grid-template-columns: minmax(0, 1fr);
            gap: 10px;
            margin-bottom: 24px;
        }

        .operations-card,
        .schedule-section,
        .operations-wide-card {
            padding: 16px;
        }

        .operations-links,
        .operation-shortcuts {
            grid-template-columns: minmax(0, 1fr);
        }

        .operations-stat-value {
            font-size: 25px;
        }

        .schedule-section .card-header {
            align-items: flex-start;
        }

        .resource-card {
            padding: 16px;
        }

        .emergency-banner {
            align-items: flex-start;
            flex-direction: column;
            padding: 17px;
        }

        .emergency-banner-content {
            align-items: flex-start;
        }

        /* UPDATED: Popup fits smaller screens. */
        .emergency-modal {
            padding: 12px;
        }

        .emergency-dialog-header,
        .emergency-dialog-body {
            padding-left: 16px;
            padding-right: 16px;
        }

        .emergency-call-card {
            align-items: flex-start;
            flex-direction: column;
        }

        .dashboard-footer {
            align-items: flex-start;
            flex-direction: column;
            gap: 8px;
        }

        .dashboard-footer-right {
            justify-content: flex-start;
        }
    }

/* Appointment workflow: additive styles only */
.appointment-workflow {
    margin-bottom: 24px;
    min-width: 0;
}

.appointment-workflow .card-header {
    margin-bottom: 18px;
}

.workflow-actions {
    min-width: 145px;
}

.workflow-actions form {
    display: inline-flex;
    margin: 2px;
}

.workflow-actions .btn {
    min-height: 32px;
    padding: 7px 10px;
    font-size: 11px;
}

.workflow-cancel {
    color: #b91c1c;
    border-color: #fecaca;
}

.workflow-cancel:hover {
    background: #fef2f2;
    border-color: #fca5a5;
}

.workflow-message {
    margin: 0 0 16px;
    padding: 11px 14px;
    border-radius: 9px;
    font-size: 12px;
}

.success-message {
    color: #166534;
    background: #dcfce7;
    border: 1px solid #bbf7d0;
}

.error-message {
    color: #991b1b;
    background: #fee2e2;
    border: 1px solid #fecaca;
}

@media (max-width: 600px) {
    .workflow-actions {
        min-width: 125px;
    }

    .appointment-workflow .data-table th,
    .appointment-workflow .data-table td {
        padding: 10px;
    }
}

</style>

</head>

<body>

<div class="app-layout">

    <!-- Mobile sidebar overlay -->
    <div class="sidebar-overlay" id="sidebarOverlay"></div>

    <!-- ===== LEFT SIDEBAR ===== -->
    <aside class="sidebar" id="sidebar">

        <!-- Hospital branding -->
        <div class="sidebar-brand">
            <div class="brand-logo">+</div>
            <div>
                <h1 class="brand-name">CityCare</h1>
                <div class="brand-subtitle">Hospital Management</div>
            </div>
        </div>

        <!-- Quick search -->
        <div class="sidebar-search">
            <div class="sidebar-search-box">
                <span>⌕</span>
                <input
                    type="text"
                    id="sidebarQuickSearch"
                    placeholder="Quick search..."
                    aria-label="Quick search"
                >
                <span class="shortcut-key">Ctrl K</span>
            </div>
        </div>

        <!-- Navigation -->
        <nav class="sidebar-nav" aria-label="Main navigation">

            <div class="nav-section">Overview</div>

            <a href="<%= contextPath %>/dashboard"
               class="nav-link active">
                <span class="nav-icon">▦</span>
                <span>Dashboard</span>
            </a>

            <div class="nav-section">Clinical Management</div>

            <% if (admin || doctor || receptionist) { %>
            <a href="<%= contextPath %>/doctors" class="nav-link">
                <span class="nav-icon">⚕</span>
                <span>Doctors</span>
            </a>
            <% } %>

            <% if (admin || doctor || receptionist) { %>
            <a href="<%= contextPath %>/patients" class="nav-link">
                <span class="nav-icon">♙</span>
                <span>Patients</span>
            </a>
            <% } %>

            <% if (admin || doctor || receptionist) { %>
            <a href="<%= contextPath %>/appointments" class="nav-link">
                <span class="nav-icon">▣</span>
                <span>Appointments</span>
            </a>
            <% } %>

            <% if (admin || doctor || receptionist) { %>
            <a href="<%= contextPath %>/departments" class="nav-link">
                <span class="nav-icon">⌂</span>
                <span>Departments</span>
            </a>
            <% } %>

            <% if (admin || doctor) { %>
            <a href="<%= contextPath %>/doctor-schedules" class="nav-link">
                <span class="nav-icon">◷</span>
                <span>Doctor Schedules</span>
            </a>
            <% } %>

            <div class="nav-section">Hospital Operations</div>

            <% if (admin || receptionist) { %>
            <a href="<%= contextPath %>/resources" class="nav-link">
                <span class="nav-icon">▤</span>
                <span>Beds &amp; Resources</span>
            </a>
            <% } %>

            <% if (admin || receptionist || doctor) { %>
            <a href="<%= contextPath %>/emergency-requests" class="nav-link">
                <span class="nav-icon">✚</span>
                <span>Emergency Requests</span>
            </a>
            <% } %>

            <% if (admin || receptionist || staff) { %>
            <a href="<%= contextPath %>/emergency-contacts" class="nav-link">
                <span class="nav-icon">☎</span>
                <span>Emergency Contacts</span>
            </a>

            <a href="<%= contextPath %>/ambulances" class="nav-link">
                <span class="nav-icon">🚑</span>
                <span>Ambulances</span>
            </a>
            <% } %>

            <% if (admin || doctor || staff) { %>
            <a href="<%= contextPath %>/ward-rounds" class="nav-link">
                <span class="nav-icon">⌕</span>
                <span>Ward Rounds</span>
            </a>
            <% } %>

            <% if (admin || staff) { %>
            <a href="<%= contextPath %>/staff-assignments" class="nav-link">
                <span class="nav-icon">☷</span>
                <span>Staff Assignments</span>
            </a>
            <% } %>

            <div class="nav-section">Staff Management</div>

            <% if (admin || staff) { %>
            <a href="<%= contextPath %>/staff" class="nav-link">
                <span class="nav-icon">👥</span>
                <span>Staff</span>
            </a>

            <a href="<%= contextPath %>/staff-attendance" class="nav-link">
                <span class="nav-icon">✓</span>
                <span>Attendance</span>
            </a>

            <a href="<%= contextPath %>/staff-shifts" class="nav-link">
                <span class="nav-icon">◷</span>
                <span>Staff Shifts</span>
            </a>
            <% } %>

            <% if (admin) { %>
            <div class="nav-section">Administration</div>

            <a href="<%= contextPath %>/users" class="nav-link">
                <span class="nav-icon">♙</span>
                <span>User Management</span>
            </a>

            <a href="<%= contextPath %>/search" class="nav-link">
                <span class="nav-icon">⌕</span>
                <span>Search Records</span>
            </a>
            <% } %>

        </nav>

        <!-- Logged-in user and logout -->
        <div class="sidebar-footer">

            <div class="sidebar-user">
                <div class="user-avatar">
                    <%= safeUsername.substring(0, 1).toUpperCase() %>
                </div>

                <div class="sidebar-user-details">
                    <div class="sidebar-user-name">
                        <%= safeUsername %>
                    </div>

                    <div class="sidebar-user-role">
                        <%= role.substring(0, 1) + role.substring(1).toLowerCase() %>
                    </div>
                </div>
            </div>

            <a href="<%= contextPath %>/logout" class="logout-link">
                <span class="nav-icon">↪</span>
                <span>Logout</span>
            </a>

        </div>

    </aside>

<!-- ===== MAIN DASHBOARD AREA ===== -->
<main class="main-area">

    <!-- ===== TOP HEADER ===== -->
    <header class="top-header">

        <div class="header-left">

            <button
                type="button"
                class="mobile-menu-btn"
                id="mobileMenuBtn"
                aria-label="Open navigation menu"
                aria-expanded="false">
                ☰
            </button>

            <h2 class="header-page-title">Dashboard</h2>

            <!-- Global record search -->
            <form
                class="header-search"
                action="<%= contextPath %>/search"
                method="get"
                role="search">

                <div class="header-search-form">
                    <span class="header-search-icon">⌕</span>

                    <input
                        type="search"
                        class="header-search-input"
                        id="globalSearch"
                        name="q"
                        maxlength="100"
                        placeholder="Search hospital records..."
                        aria-label="Search hospital records">
                </div>

            </form>

        </div>

        <div class="header-actions">

            <!-- Export action: implemented in a later step -->
            <button
                type="button"
                class="btn header-export"
                id="exportCsvBtn">
                <span>⇩</span>
                <span class="header-action-label">Export CSV</span>
            </button>

            <!-- Report action: implemented in a later step -->
            <button
                type="button"
                class="btn btn-primary header-report"
                id="generateReportBtn">
                <span>▤</span>
                <span class="header-action-label">Generate Report</span>
            </button>

            <div class="header-divider"></div>

            <!-- Notifications placeholder; live notifications come later -->
            <button
                type="button"
                class="icon-btn"
                id="notificationBtn"
                aria-label="Notifications"
                title="Notifications">
                🔔
            </button>

            <!-- Profile shortcut -->
            <a
                href="<%= contextPath %>/dashboard"
                class="header-profile"
                title="Logged-in user">

                <div class="user-avatar">
                    <%= safeUsername.substring(0, 1).toUpperCase() %>
                </div>

                <div class="header-profile-info">
                    <div class="header-profile-name">
                        <%= safeUsername %>
                    </div>

                    <div class="header-profile-role">
                        <%= role.substring(0, 1) + role.substring(1).toLowerCase() %>
                    </div>
                </div>

            </a>

        </div>

    </header>
    
<%
Map<String, Integer> dashboardStats =
    (Map<String, Integer>) request.getAttribute("dashboardStats");

if (dashboardStats == null) {
    dashboardStats = Collections.emptyMap();
}

int totalPatients = dashboardStats.getOrDefault("totalPatients", 0);
int totalAppointments = dashboardStats.getOrDefault("totalAppointments", 0);
int totalEmergencyRequests = dashboardStats.getOrDefault("totalEmergencyRequests", 0);
int availableAmbulances = dashboardStats.getOrDefault("availableAmbulances", 0);

String dashboardDate = new java.text.SimpleDateFormat(
    "EEEE, dd MMMM yyyy"
).format(new java.util.Date());
%>


<%
Map<String, Integer> appointmentSummary =
    (Map<String, Integer>) request.getAttribute("appointmentSummary");

Map<String, Integer> emergencySummary =
    (Map<String, Integer>) request.getAttribute("emergencySummary");

List<Map<String, Object>> patientTrend =
    (List<Map<String, Object>>) request.getAttribute("patientRegistrationTrend");

if (appointmentSummary == null) {
    appointmentSummary = Collections.emptyMap();
}

if (emergencySummary == null) {
    emergencySummary = Collections.emptyMap();
}

if (patientTrend == null) {
    patientTrend = Collections.emptyList();
}

String selectedPeriod = (String) request.getAttribute("selectedPeriod");

if (!"daily".equals(selectedPeriod)
        && !"weekly".equals(selectedPeriod)
        && !"monthly".equals(selectedPeriod)
        && !"yearly".equals(selectedPeriod)) {
    selectedPeriod = "weekly";
}

int requestedAppointments = appointmentSummary.getOrDefault("REQUESTED", 0);
int confirmedAppointments = appointmentSummary.getOrDefault("CONFIRMED", 0);
int checkedInAppointments = appointmentSummary.getOrDefault("CHECKED_IN", 0);
int completedAppointments = appointmentSummary.getOrDefault("COMPLETED", 0);
int cancelledAppointments = appointmentSummary.getOrDefault("CANCELLED", 0);
int noShowAppointments = appointmentSummary.getOrDefault("NO_SHOW", 0);

int activeEmergencies =
    emergencySummary.getOrDefault("REPORTED", 0)
    + emergencySummary.getOrDefault("ACKNOWLEDGED", 0)
    + emergencySummary.getOrDefault("DISPATCHED", 0)
    + emergencySummary.getOrDefault("IN_PROGRESS", 0);

int resolvedEmergencies = emergencySummary.getOrDefault("RESOLVED", 0);
int cancelledEmergencies = emergencySummary.getOrDefault("CANCELLED", 0);

int maxPatientTrend = 0;
for (Map<String, Object> point : patientTrend) {
    Object totalObject = point.get("total");
    int total = totalObject instanceof Number
        ? ((Number) totalObject).intValue() : 0;

    if (total > maxPatientTrend) {
        maxPatientTrend = total;
    }
}

int totalAppointmentStatuses =
    requestedAppointments + confirmedAppointments + checkedInAppointments
    + completedAppointments + cancelledAppointments + noShowAppointments;

int totalEmergencyStatuses =
    activeEmergencies + resolvedEmergencies + cancelledEmergencies;
%>

   
<!-- ===== WELCOME SECTION ===== -->
<section class="welcome-section">

    <div>
        <h1 class="welcome-title">
            Welcome back, <span class="welcome-name"><%= safeUsername %></span>!
        </h1>

        <p class="welcome-description">
            Here's what's happening at CityCare Hospital today.
            Stay informed and keep hospital operations running smoothly.
        </p>
    </div>

    <div class="welcome-date">
        <span class="welcome-date-icon">▦</span>
        <span><%= dashboardDate %></span>
    </div>

</section>

<!-- ===== HOSPITAL KPI CARDS ===== -->
<section class="kpi-grid" aria-label="Hospital summary">

    <!-- Total Patients -->
    <article class="card kpi-card">
        <div class="kpi-top">
            <div class="kpi-label">Total Patients</div>
            <div class="kpi-icon kpi-icon-blue">♙</div>
        </div>

        <h2 class="kpi-value"><%= totalPatients %></h2>

        <div class="kpi-description">
            Registered patients in the hospital database
        </div>

        <div class="kpi-footer">
            <a class="kpi-footer-link"
               href="<%= contextPath %>/patients">
                View patients →
            </a>
        </div>
    </article>

    <!-- Total Appointments -->
    <article class="card kpi-card">
        <div class="kpi-top">
            <div class="kpi-label">Total Appointments</div>
            <div class="kpi-icon kpi-icon-green">▣</div>
        </div>

        <h2 class="kpi-value"><%= totalAppointments %></h2>

        <div class="kpi-description">
            Appointments recorded in the system
        </div>

        <div class="kpi-footer">
            <a class="kpi-footer-link"
               href="<%= contextPath %>/appointments">
                View appointments →
            </a>
        </div>
    </article>

    <!-- Emergency Requests -->
    <article class="card kpi-card">
        <div class="kpi-top">
            <div class="kpi-label">Emergency Requests</div>
            <div class="kpi-icon kpi-icon-orange">✚</div>
        </div>

        <h2 class="kpi-value"><%= totalEmergencyRequests %></h2>

        <div class="kpi-description">
            Emergency requests recorded in the system
        </div>

        <div class="kpi-footer">
            <a class="kpi-footer-link"
               href="<%= contextPath %>/emergency-requests">
                View requests →
            </a>
        </div>
    </article>

    <!-- Available Ambulances -->
    <article class="card kpi-card">
        <div class="kpi-top">
            <div class="kpi-label">Available Ambulances</div>
            <div class="kpi-icon kpi-icon-purple">🚑</div>
        </div>

        <h2 class="kpi-value"><%= availableAmbulances %></h2>

        <div class="kpi-description">
            Ambulances currently marked as available
        </div>

        <div class="kpi-footer">
            <a class="kpi-footer-link"
               href="<%= contextPath %>/ambulances">
                View ambulances →
            </a>
        </div>
    </article>

</section>


<!-- ===== PATIENT TREND AND APPOINTMENT ANALYTICS ===== -->
<section class="analytics-grid">

    <!-- Patient registration trend -->
    <article class="card analytics-card">

        <div class="card-header">
            <div>
                <h2 class="section-title">Patient Registration Trend</h2>
                <p class="section-subtitle">
                    Registration activity across the selected period
                </p>
            </div>

            <form action="<%= contextPath %>/dashboard" method="get">
                <select
                    class="period-select"
                    name="period"
                    aria-label="Patient registration chart period"
                    onchange="this.form.submit()">

                    <option value="daily" <%= "daily".equals(selectedPeriod) ? "selected" : "" %>>
                        Daily
                    </option>

                    <option value="weekly" <%= "weekly".equals(selectedPeriod) ? "selected" : "" %>>
                        Weekly
                    </option>

                    <option value="monthly" <%= "monthly".equals(selectedPeriod) ? "selected" : "" %>>
                        Monthly
                    </option>

                    <option value="yearly" <%= "yearly".equals(selectedPeriod) ? "selected" : "" %>>
                        Yearly
                    </option>
                </select>
            </form>
        </div>

        <% if (patientTrend.isEmpty()) { %>

            <div class="empty-state">
                <strong>No registration trend available</strong>
                Patient registration data will appear here when provided by the dashboard.
            </div>

        <% } else { %>

            <div class="trend-chart" role="img"
                 aria-label="Patient registrations by period">

                <% for (Map<String, Object> point : patientTrend) {
                    Object labelObject = point.get("label");
                    String trendLabel = labelObject == null
                        ? "—" : String.valueOf(labelObject);

                    trendLabel = trendLabel
                        .replace("&", "&amp;")
                        .replace("<", "&lt;")
                        .replace(">", "&gt;")
                        .replace("\"", "&quot;")
                        .replace("'", "&#39;");

                    Object totalObject = point.get("total");
                    int trendTotal = totalObject instanceof Number
                        ? ((Number) totalObject).intValue() : 0;

                    int barHeight = maxPatientTrend > 0
                        ? (int) Math.round(
                            (trendTotal * 100.0) / maxPatientTrend
                          ) : 0;
                %>

                    <div class="trend-column"
                         title="<%= trendLabel %>: <%= trendTotal %> registrations">

                        <span class="trend-total"><%= trendTotal %></span>

                        <div class="trend-bar-area">
                            <div class="trend-bar"
                                 style="height:<%= barHeight %>%">
                            </div>
                        </div>

                        <span class="trend-label"><%= trendLabel %></span>
                    </div>

                <% } %>

            </div>

            <div class="chart-legend">
                <span class="legend-dot"></span>
                <span>Registered patients</span>
            </div>

        <% } %>

    </article>

    <!-- Appointment status summary -->
    <article class="card analytics-card">

        <div class="card-header">
            <div>
                <h2 class="section-title">Appointment Status</h2>
                <p class="section-subtitle">
                    Distribution of recorded appointment statuses
                </p>
            </div>

            <a class="text-link"
               href="<%= contextPath %>/appointments">
                View all →
            </a>
        </div>

        <% if (totalAppointmentStatuses == 0) { %>

            <div class="empty-state">
                <strong>No appointment summary available</strong>
                Appointment status counts will appear here when records are available.
            </div>

        <% } else { %>

            <div class="summary-list">

                <% String[] appointmentLabels = {
                    "Requested", "Confirmed", "Checked In",
                    "Completed", "Cancelled", "No-show"
                };

                String[] appointmentKeys = {
                    "REQUESTED", "CONFIRMED", "CHECKED_IN",
                    "COMPLETED", "CANCELLED", "NO_SHOW"
                };

                String[] appointmentColors = {
                    "fill-orange", "fill-blue", "fill-purple",
                    "fill-green", "fill-red", "fill-gray"
                };

                for (int i = 0; i < appointmentLabels.length; i++) {
                    int count = appointmentSummary.getOrDefault(
                        appointmentKeys[i], 0
                    );

                    int percentage = (int) Math.round(
                        count * 100.0 / totalAppointmentStatuses
                    );
                %>

                    <div class="summary-row">

                        <div class="summary-row-top">
                            <span class="summary-label">
                                <%= appointmentLabels[i] %>
                            </span>

                            <span class="summary-value"><%= count %></span>
                        </div>

                        <div class="summary-track">
                            <div class="summary-fill <%= appointmentColors[i] %>"
                                 style="width:<%= percentage %>%">
                            </div>
                        </div>

                    </div>

                <% } %>

            </div>

        <% } %>

    </article>

</section>

<!-- ===== EMERGENCY ANALYTICS ===== -->
<section class="analytics-bottom">

    <!-- Emergency overview -->
    <article class="card analytics-card">

        <div class="card-header">
            <div>
                <h2 class="section-title">Emergency Overview</h2>
                <p class="section-subtitle">
                    Current recorded emergency request statuses
                </p>
            </div>

            <a class="text-link"
               href="<%= contextPath %>/emergency-requests">
                Manage →
            </a>
        </div>

        <div class="emergency-highlight">
            <div class="emergency-highlight-icon">✚</div>

            <div>
                <div class="emergency-highlight-label">
                    Active Emergency Requests
                </div>

                <div class="emergency-highlight-value">
                    <%= activeEmergencies %>
                </div>
            </div>
        </div>

        <% if (totalEmergencyStatuses == 0) { %>

            <div class="empty-state">
                <strong>No emergency summary available</strong>
                Emergency status counts will appear here when records are available.
            </div>

        <% } else { %>

            <div class="summary-list">

                <div class="summary-row">
                    <div class="summary-row-top">
                        <span class="summary-label">Active</span>
                        <span class="summary-value"><%= activeEmergencies %></span>
                    </div>

                    <div class="summary-track">
                        <div class="summary-fill fill-orange"
                             style="width:<%= (int)Math.round(activeEmergencies * 100.0 / totalEmergencyStatuses) %>%">
                        </div>
                    </div>
                </div>

                <div class="summary-row">
                    <div class="summary-row-top">
                        <span class="summary-label">Resolved</span>
                        <span class="summary-value"><%= resolvedEmergencies %></span>
                    </div>

                    <div class="summary-track">
                        <div class="summary-fill fill-green"
                             style="width:<%= (int)Math.round(resolvedEmergencies * 100.0 / totalEmergencyStatuses) %>%">
                        </div>
                    </div>
                </div>

                <div class="summary-row">
                    <div class="summary-row-top">
                        <span class="summary-label">Cancelled</span>
                        <span class="summary-value"><%= cancelledEmergencies %></span>
                    </div>

                    <div class="summary-track">
                        <div class="summary-fill fill-gray"
                             style="width:<%= (int)Math.round(cancelledEmergencies * 100.0 / totalEmergencyStatuses) %>%">
                        </div>
                    </div>
                </div>

            </div>

        <% } %>

    </article>

    <!-- Appointment quick actions -->
    <article class="card analytics-card">

        <div class="card-header">
            <div>
                <h2 class="section-title">Quick Actions</h2>
                <p class="section-subtitle">
                    Shortcuts to frequently used hospital modules
                </p>
            </div>
        </div>

        <div class="summary-list">

            <% if (admin || receptionist) { %>
            <div class="summary-row">
                <div class="summary-row-top">
                    <span class="summary-label">Appointment Management</span>
                    <a class="text-link"
                       href="<%= contextPath %>/appointments">Open →</a>
                </div>
                <p class="section-subtitle">
                    Review appointments and manage scheduling.
                </p>
            </div>
            <% } %>

            <% if (admin || doctor || receptionist) { %>
            <div class="summary-row">
                <div class="summary-row-top">
                    <span class="summary-label">Patient Records</span>
                    <a class="text-link"
                       href="<%= contextPath %>/patients">Open →</a>
                </div>
                <p class="section-subtitle">
                    Access authorized patient information.
                </p>
            </div>
            <% } %>

            <% if (admin || doctor || receptionist || staff) { %>
            <div class="summary-row">
                <div class="summary-row-top">
                    <span class="summary-label">Emergency Assistance</span>
                    <a class="text-link"
                       href="<%= contextPath %>/emergency-contacts">Open →</a>
                </div>
                <p class="section-subtitle">
                    Access emergency contact information.
                </p>
            </div>
            <% } %>

            <% if (admin || staff) { %>
            <div class="summary-row">
                <div class="summary-row-top">
                    <span class="summary-label">Staff Operations</span>
                    <a class="text-link"
                       href="<%= contextPath %>/staff-assignments">Open →</a>
                </div>
                <p class="section-subtitle">
                    Review staff assignments and operational duties.
                </p>
            </div>
            <% } %>

        </div>

    </article>

</section>


<!-- ===== DOCTOR AND STAFF OVERVIEW ===== -->
<section class="operations-grid">

    <!-- Doctor overview -->
    <article class="card operations-card">

        <div class="card-header">
            <div>
                <h2 class="section-title">Doctor Overview</h2>
                <p class="section-subtitle">
                    Hospital medical team at a glance
                </p>
            </div>

            <span class="kpi-icon kpi-icon-blue">⚕</span>
        </div>

        <div class="operations-stat">
            <div class="operations-stat-icon kpi-icon-blue">♙</div>

            <div>
                <div class="operations-stat-value">
                    <%= dashboardStats.getOrDefault("totalDoctors", 0) %>
                </div>

                <div class="operations-stat-label">
                    Registered doctors
                </div>
            </div>
        </div>

        <div class="operations-links">

            <% if (admin || doctor || receptionist) { %>
            <a class="operations-link"
               href="<%= contextPath %>/doctors">
                <span>View Doctors</span>
                <span>→</span>
            </a>
            <% } %>

            <% if (admin || doctor) { %>
            <a class="operations-link"
               href="<%= contextPath %>/doctor-schedules">
                <span>Doctor Schedules</span>
                <span>→</span>
            </a>
            <% } %>

        </div>

        <p class="section-subtitle" style="margin-top:15px">
            Schedule-based availability will be shown when the relevant
            doctor schedule data is connected.
        </p>

    </article>

    <!-- Staff overview -->
    <article class="card operations-card">

        <div class="card-header">
            <div>
                <h2 class="section-title">Staff Overview</h2>
                <p class="section-subtitle">
                    Hospital workforce and operations
                </p>
            </div>

            <span class="kpi-icon kpi-icon-purple">👥</span>
        </div>

        <div class="operations-stat">
            <div class="operations-stat-icon kpi-icon-purple">♙</div>

            <div>
                <div class="operations-stat-value">
                    <%= dashboardStats.getOrDefault("totalStaff", 0) %>
                </div>

                <div class="operations-stat-label">
                    Registered staff members
                </div>
            </div>
        </div>

        <div class="operations-links">

            <% if (admin || staff) { %>
            <a class="operations-link"
               href="<%= contextPath %>/staff">
                <span>View Staff</span>
                <span>→</span>
            </a>

            <a class="operations-link"
               href="<%= contextPath %>/staff-attendance">
                <span>Attendance</span>
                <span>→</span>
            </a>

            <a class="operations-link"
               href="<%= contextPath %>/staff-shifts">
                <span>Staff Shifts</span>
                <span>→</span>
            </a>
            <% } %>

            <% if (admin || staff) { %>
            <a class="operations-link"
               href="<%= contextPath %>/staff-assignments">
                <span>Assignments</span>
                <span>→</span>
            </a>
            <% } %>

        </div>

        <p class="section-subtitle" style="margin-top:15px">
            On-duty staff and shift summaries will use recorded assignments
            and shift data.
        </p>

    </article>

</section>

<!-- ===== APPOINTMENT SCHEDULE ===== -->
<section class="card schedule-section">

    <div class="card-header">
        <div>
            <h2 class="section-title">Appointment Schedule</h2>
            <p class="section-subtitle">
                View appointments and their current status
            </p>
        </div>
    </div>

    <div class="table-wrap">
        <table class="data-table">
            <thead>
                <tr>
                    <th>Appointment Time</th>
                    <th>Patient</th>
                    <th>Doctor</th>
                    <th>Reason</th>
                    <th>Status</th>
                </tr>
            </thead>

            <tbody>
                <%
                List<com.hospital.model.Appointment> workflowAppointments =
                    (List<com.hospital.model.Appointment>)
                    request.getAttribute("workflowAppointments");

                if (workflowAppointments == null || workflowAppointments.isEmpty()) {
                %>
                    <tr>
                        <td colspan="5">
                            <div class="schedule-empty">
                                <strong>No appointments to display</strong>
                                <p>
                                    Appointments will appear here when records
                                    are available to your account.
                                </p>
                            </div>
                        </td>
                    </tr>
                <%
                } else {
                    for (com.hospital.model.Appointment a : workflowAppointments) {
                %>
                    <tr>
                        <td>
                            <%= a.getAppointmentDatetime() == null
                                ? "—" : a.getAppointmentDatetime() %>
                        </td>
                        <td>
                            <%= a.getPatientName() == null
                                ? "—" : a.getPatientName() %>
                        </td>
                        <td>
                            <%= a.getDoctorName() == null
                                ? "—" : a.getDoctorName() %>
                        </td>
                        <td>
                            <%= a.getReason() == null
                                ? "—" : a.getReason() %>
                        </td>
                        <td>
                            <span class="status-badge">
                                <%= a.getAppointmentStatus() == null
                                    ? "UNKNOWN" : a.getAppointmentStatus() %>
                            </span>
                        </td>
                    </tr>
                <%
                    }
                }
                %>
            </tbody>
        </table>
    </div>

</section>

<!-- ===== HOSPITAL RESOURCES ===== -->
<section>

    <div class="card-header">
        <div>
            <h2 class="section-title">Hospital Resources</h2>
            <p class="section-subtitle">
                Access capacity and resource management
            </p>
        </div>
    </div>

    <div class="resource-grid">

        <!-- Beds and wards -->
        <article class="card resource-card">
            <div class="resource-card-top">
                <div>
                    <h3 class="section-title">Beds &amp; Wards</h3>
                    <p class="section-subtitle">Bed management</p>
                </div>
                <div class="resource-icon kpi-icon-blue">▤</div>
            </div>

            <p class="resource-description">
                Review bed records, ward allocations, and resource status.
            </p>

            <div class="resource-divider"></div>

            <% if (admin || receptionist) { %>
            <a class="resource-link" href="<%= contextPath %>/resources">
                <span>Manage Resources</span>
                <span>→</span>
            </a>
            <% } else { %>
            <span class="muted">Resource access depends on your role.</span>
            <% } %>
        </article>

        <!-- ICU and ventilators -->
        <article class="card resource-card">
            <div class="resource-card-top">
                <div>
                    <h3 class="section-title">ICU &amp; Ventilators</h3>
                    <p class="section-subtitle">Critical care resources</p>
                </div>
                <div class="resource-icon kpi-icon-green">✚</div>
            </div>

            <p class="resource-description">
                Access the resource management module for recorded critical
                care equipment and availability information.
            </p>

            <div class="resource-divider"></div>

            <% if (admin || receptionist) { %>
            <a class="resource-link" href="<%= contextPath %>/resources">
                <span>View Resource Records</span>
                <span>→</span>
            </a>
            <% } else { %>
            <span class="muted">Resource access depends on your role.</span>
            <% } %>
        </article>

        <!-- Operation theatres -->
        <article class="card resource-card">
            <div class="resource-card-top">
                <div>
                    <h3 class="section-title">Operation Theatres</h3>
                    <p class="section-subtitle">OT and scheduling</p>
                </div>
                <div class="resource-icon kpi-icon-purple">⌘</div>
            </div>

            <p class="resource-description">
                Access hospital resource records. OT schedules and theatre
                status can be displayed once their data is connected.
            </p>

            <div class="resource-divider"></div>

            <% if (admin || receptionist) { %>
            <a class="resource-link" href="<%= contextPath %>/resources">
                <span>Open Resource Management</span>
                <span>→</span>
            </a>
            <% } else { %>
            <span class="muted">Resource access depends on your role.</span>
            <% } %>
        </article>

    </div>

</section>

<!-- ===== HOSPITAL OPERATIONS SHORTCUTS ===== -->
<section class="operations-wide-grid">

    <!-- Emergency and ambulance management -->
    <article class="card operations-wide-card">

        <div class="card-header">
            <div>
                <h2 class="section-title">Emergency Operations</h2>
                <p class="section-subtitle">
                    Emergency coordination and ambulance access
                </p>
            </div>

            <div class="resource-icon kpi-icon-orange">✚</div>
        </div>

        <div class="operation-shortcuts">

            <% if (admin || doctor || receptionist) { %>
            <a class="operation-shortcut"
               href="<%= contextPath %>/emergency-requests">

                <span class="operation-shortcut-icon">✚</span>

                <span>
                    <span class="operation-shortcut-title">
                        Emergency Requests
                    </span>
                    <span class="operation-shortcut-description">
                        Review emergency records
                    </span>
                </span>
            </a>
            <% } %>

            <% if (admin || receptionist || staff) { %>
            <a class="operation-shortcut"
               href="<%= contextPath %>/ambulances">

                <span class="operation-shortcut-icon">🚑</span>

                <span>
                    <span class="operation-shortcut-title">
                        Ambulances
                    </span>
                    <span class="operation-shortcut-description">
                        Access ambulance records
                    </span>
                </span>
            </a>

            <a class="operation-shortcut"
               href="<%= contextPath %>/emergency-contacts">

                <span class="operation-shortcut-icon">☎</span>

                <span>
                    <span class="operation-shortcut-title">
                        Emergency Contacts
                    </span>
                    <span class="operation-shortcut-description">
                        Find emergency contact details
                    </span>
                </span>
            </a>
            <% } %>

            <% if (admin || doctor || staff) { %>
            <a class="operation-shortcut"
               href="<%= contextPath %>/ward-rounds">

                <span class="operation-shortcut-icon">◷</span>

                <span>
                    <span class="operation-shortcut-title">
                        Ward Rounds
                    </span>
                    <span class="operation-shortcut-description">
                        Access ward-round records
                    </span>
                </span>
            </a>
            <% } %>

        </div>

    </article>

    <!-- Staff operations -->
    <article class="card operations-wide-card">

        <div class="card-header">
            <div>
                <h2 class="section-title">Staff Operations</h2>
                <p class="section-subtitle">
                    Workforce management shortcuts
                </p>
            </div>

            <div class="resource-icon kpi-icon-blue">👥</div>
        </div>

        <div class="operation-shortcuts">

            <% if (admin || staff) { %>
            <a class="operation-shortcut"
               href="<%= contextPath %>/staff-assignments">

                <span class="operation-shortcut-icon">☷</span>

                <span>
                    <span class="operation-shortcut-title">
                        Staff Assignments
                    </span>
                    <span class="operation-shortcut-description">
                        Review assigned duties
                    </span>
                </span>
            </a>

            <a class="operation-shortcut"
               href="<%= contextPath %>/staff-attendance">

                <span class="operation-shortcut-icon">✓</span>

                <span>
                    <span class="operation-shortcut-title">
                        Attendance
                    </span>
                    <span class="operation-shortcut-description">
                        Access attendance records
                    </span>
                </span>
            </a>

            <a class="operation-shortcut"
               href="<%= contextPath %>/staff-shifts">

                <span class="operation-shortcut-icon">◷</span>

                <span>
                    <span class="operation-shortcut-title">
                        Staff Shifts
                    </span>
                    <span class="operation-shortcut-description">
                        Review shift schedules
                    </span>
                </span>
            </a>

            <a class="operation-shortcut"
               href="<%= contextPath %>/staff">

                <span class="operation-shortcut-icon">♙</span>

                <span>
                    <span class="operation-shortcut-title">
                        Staff Directory
                    </span>
                    <span class="operation-shortcut-description">
                        View staff records
                    </span>
                </span>
            </a>
            <% } else { %>

            <div class="empty-state">
                <strong>Staff management</strong>
                Your dashboard access is based on your assigned role.
            </div>

            <% } %>

        </div>

    </article>

</section>

<!-- ===== EMERGENCY ASSISTANCE BANNER ===== -->
<section class="emergency-banner">

    <div class="emergency-banner-content">

        <div class="emergency-banner-icon">✚</div>

        <div>
            <h2 class="emergency-banner-title">
                Need Emergency Assistance?
            </h2>

            <p class="emergency-banner-text">
                Quickly access emergency contacts and ambulance information.
                For immediate emergencies in India, call 112.
            </p>
        </div>

    </div>

    <button type="button"
            class="btn"
            id="openEmergencyAssistant">
        Emergency Assistance →
    </button>

</section>


<!-- ===== EMERGENCY ASSISTANCE MODAL ===== -->
<div
    class="emergency-modal"
    id="emergencyModal"
    aria-hidden="true">

    <section
        class="emergency-dialog"
        role="dialog"
        aria-modal="true"
        aria-labelledby="emergencyDialogTitle">

        <header class="emergency-dialog-header">

            <div class="emergency-dialog-heading">
                <div class="emergency-dialog-icon">✚</div>

                <div>
                    <h2 class="emergency-dialog-title"
                        id="emergencyDialogTitle">
                        Emergency Assistance
                    </h2>

                    <p class="emergency-dialog-subtitle">
                        Quick access to emergency support.
                    </p>
                </div>
            </div>

            <button
                type="button"
                class="emergency-close"
                id="closeEmergencyModal"
                aria-label="Close emergency assistance">
                &times;
            </button>

        </header>

        <div class="emergency-dialog-body">

            <!-- India emergency number -->
            <div class="emergency-call-card">

                <div>
                    <div class="emergency-call-label">
                        India's Emergency Helpline
                    </div>

                    <a href="tel:112" class="emergency-call-number">
                        112
                    </a>

                    <div class="emergency-call-note">
                        For immediate emergencies in India.
                    </div>
                </div>

                <a href="tel:112" class="emergency-call-button">
                    ☎ Call 112
                </a>

            </div>

            <h3 class="emergency-options-title">
                Hospital Emergency Resources
            </h3>

            <!-- Emergency contacts -->
            <a
                class="emergency-option"
                href="<%= contextPath %>/emergency-contacts">

                <span class="emergency-option-icon">☎</span>

                <span class="emergency-option-text">
                    <span class="emergency-option-title">
                        Emergency Contacts
                    </span>

                    <span class="emergency-option-description">
                        Access the hospital's recorded emergency contacts.
                    </span>
                </span>

                <span class="emergency-option-arrow">→</span>

            </a>

            <!-- Ambulances -->
            <a
                class="emergency-option"
                href="<%= contextPath %>/ambulances">

                <span class="emergency-option-icon">🚑</span>

                <span class="emergency-option-text">
                    <span class="emergency-option-title">
                        Ambulance Information
                    </span>

                    <span class="emergency-option-description">
                        Open the ambulance management module.
                    </span>
                </span>

                <span class="emergency-option-arrow">→</span>

            </a>

            <!-- Emergency requests -->
            <% if (admin || doctor || receptionist) { %>
            <a
                class="emergency-option"
                href="<%= contextPath %>/emergency-requests">

                <span class="emergency-option-icon">✚</span>

                <span class="emergency-option-text">
                    <span class="emergency-option-title">
                        Emergency Requests
                    </span>

                    <span class="emergency-option-description">
                        Access recorded emergency requests.
                    </span>
                </span>

                <span class="emergency-option-arrow">→</span>

            </a>
            <% } %>

            <p class="emergency-disclaimer">
                This panel provides shortcuts to existing hospital modules.
                It does not dispatch an ambulance or notify hospital staff
                automatically. For an immediate emergency, call 112.
            </p>

        </div>

    </section>

</div>
<!-- ===== DASHBOARD FOOTER ===== -->
<footer class="dashboard-footer">

    <div>
        <span class="dashboard-footer-brand">CityCare Hospital</span>
        <span> &copy; <%= java.time.Year.now() %>. Hospital Management System.</span>
    </div>

    <div class="dashboard-footer-right">
        <span class="dashboard-footer-dot"></span>
        <span>Hospital management workspace</span>
        <span>&bull;</span>
        <span>Signed in as <%= safeUsername %></span>
    </div>

</footer>
</main>

</div>


<script>
(function () {
    const sidebar = document.getElementById("sidebar");
    const overlay = document.getElementById("sidebarOverlay");
    const menuButton = document.getElementById("mobileMenuBtn");
    const quickSearch = document.getElementById("sidebarQuickSearch");
    const globalSearch = document.getElementById("globalSearch");

    function openSidebar() {
        if (!sidebar || !overlay || !menuButton) return;

        sidebar.classList.add("sidebar-open");
        overlay.classList.add("overlay-visible");
        menuButton.setAttribute("aria-expanded", "true");
    }

    function closeSidebar() {
        if (!sidebar || !overlay || !menuButton) return;

        sidebar.classList.remove("sidebar-open");
        overlay.classList.remove("overlay-visible");
        menuButton.setAttribute("aria-expanded", "false");
    }

    if (menuButton) {
        menuButton.addEventListener("click", function () {
            if (sidebar.classList.contains("sidebar-open")) {
                closeSidebar();
            } else {
                openSidebar();
            }
        });
    }

    if (overlay) {
        overlay.addEventListener("click", closeSidebar);
    }

    document.addEventListener("keydown", function (event) {
        if (event.key === "Escape") {
            closeSidebar();
        }

        if ((event.ctrlKey || event.metaKey) &&
            event.key.toLowerCase() === "k") {
            event.preventDefault();

            if (window.matchMedia("(max-width: 600px)").matches) {
                if (quickSearch) {
                    quickSearch.focus();
                }
            } else if (globalSearch) {
                globalSearch.focus();
            }
        }
    });

    // Quick-search text is transferred to the existing global search form.
    if (quickSearch && globalSearch) {
        quickSearch.addEventListener("keydown", function (event) {
            if (event.key === "Enter") {
                event.preventDefault();
                globalSearch.value = quickSearch.value.trim();

                if (globalSearch.value) {
                    globalSearch.form.submit();
                } else {
                    globalSearch.focus();
                }
            }
        });
    }

    // Highlight the current navigation destination.
    const currentPath = window.location.pathname;

    document.querySelectorAll(".sidebar-nav .nav-link").forEach(function (link) {
        const linkPath = new URL(link.href, window.location.origin).pathname;

        if (linkPath === currentPath) {
            document.querySelectorAll(".sidebar-nav .nav-link")
                .forEach(function (item) {
                    item.classList.remove("active");
                });

            link.classList.add("active");
        }
    });
})();


document.addEventListener("DOMContentLoaded", function () {
    const reportButton =
        document.getElementById("generateReportBtn");

    if (reportButton) {
        reportButton.addEventListener("click", function () {
            window.open(
                "${pageContext.request.contextPath}/generate-report",
                "_blank"
            );
        });
    }
});


(function () {
    const modal = document.getElementById("emergencyModal");
    const openButton = document.getElementById("openEmergencyAssistant");
    const closeButton = document.getElementById("closeEmergencyModal");

    if (!modal || !openButton || !closeButton) {
        return;
    }

    let previousFocus = null;

    function openEmergencyModal() {
        previousFocus = document.activeElement;

        modal.classList.add("modal-open");
        modal.setAttribute("aria-hidden", "false");

        document.body.style.overflow = "hidden";

        closeButton.focus();
    }

    function closeEmergencyModal() {
        modal.classList.remove("modal-open");
        modal.setAttribute("aria-hidden", "true");

        document.body.style.overflow = "";

        if (previousFocus && typeof previousFocus.focus === "function") {
            previousFocus.focus();
        }
    }

    openButton.addEventListener("click", openEmergencyModal);

    closeButton.addEventListener("click", closeEmergencyModal);

    modal.addEventListener("click", function (event) {
        if (event.target === modal) {
            closeEmergencyModal();
        }
    });

    document.addEventListener("keydown", function (event) {
        if (event.key === "Escape" &&
            modal.classList.contains("modal-open")) {
            closeEmergencyModal();
        }
    });
})();
</script>
</body>
</html>