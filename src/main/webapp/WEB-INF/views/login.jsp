
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hospital Management System - Login</title>

    <style>
        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            font-family: Arial, sans-serif;
            background: #eef3f8;
            color: #243247;
        }

        .login-card {
            width: 100%;
            max-width: 420px;
            padding: 35px;
            margin: 20px;
            background: white;
            border-radius: 12px;
            box-shadow: 0 8px 28px rgba(0, 0, 0, 0.10);
        }

        .brand {
            text-align: center;
            margin-bottom: 28px;
        }

        .brand h1 {
            margin-bottom: 8px;
            color: #1261a0;
            font-size: 25px;
        }

        .brand p {
            margin: 0;
            color: #65758b;
            font-size: 14px;
        }

        label {
            display: block;
            margin: 16px 0 7px;
            font-weight: bold;
            font-size: 14px;
        }

        input {
            width: 100%;
            padding: 12px;
            border: 1px solid #cbd5e1;
            border-radius: 6px;
            font-size: 15px;
        }

        input:focus {
            outline: 2px solid #9bc9f0;
            border-color: #1261a0;
        }

        button {
            width: 100%;
            margin-top: 24px;
            padding: 13px;
            border: none;
            border-radius: 6px;
            background: #1261a0;
            color: white;
            font-size: 16px;
            font-weight: bold;
            cursor: pointer;
        }

        button:hover {
            background: #0b497b;
        }

        .message {
            padding: 11px;
            border-radius: 6px;
            margin-bottom: 15px;
            font-size: 14px;
        }

        .error {
            color: #9b1c1c;
            background: #fee2e2;
        }

        .notice {
            color: #854d0e;
            background: #fef3c7;
        }

        .footer {
            text-align: center;
            color: #718096;
            font-size: 12px;
            margin-top: 24px;
        }
    </style>
</head>

<body>

<div class="login-card">

    <div class="brand">
        <h1>Hospital Management System</h1>
        <p>Sign in to access your account</p>
    </div>

    <% if ("1".equals(request.getParameter("error"))) { %>
        <div class="message error">
            Invalid username or password.
        </div>
    <% } %>

    <% if ("disabled".equals(request.getParameter("error"))) { %>
        <div class="message notice">
            This account is unavailable. Contact your administrator.
        </div>
    <% } %>

    <% if ("1".equals(request.getParameter("logout"))) { %>
        <div class="message">
            You have been logged out successfully.
        </div>
    <% } %>

    <form action="<%= request.getContextPath() %>/login"
          method="post">

        <label for="username">Username</label>
        <input type="text"
               id="username"
               name="username"
               maxlength="60"
               autocomplete="username"
               required>

        <label for="password">Password</label>
        <input type="password"
               id="password"
               name="password"
               autocomplete="current-password"
               required>

        <button type="submit">Sign In</button>

    </form>

    <div class="footer">
        Authorized users only
    </div>

</div>

</body>
</html>
