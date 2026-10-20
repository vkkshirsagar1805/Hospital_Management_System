
<%@ page language="java"
         contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>
<%
    String hospitalName = "CityCare Hospital";
    String currentTime = java.time.LocalDateTime.now()
            .format(java.time.format.DateTimeFormatter
            .ofPattern("dd-MM-yyyy HH:mm:ss"));
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">
    <title>Hospital Management System</title>

    <style>
        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            font-family: Arial, sans-serif;
            background: #f2f6fc;
            color: #243247;
        }

        header {
            background: #1256a0;
            color: white;
            padding: 22px 8%;
        }

        header h1 {
            margin: 0 0 8px;
        }

        main {
            max-width: 850px;
            margin: 55px auto;
            padding: 0 20px;
        }

        .panel {
            background: white;
            padding: 32px;
            border-radius: 12px;
            box-shadow: 0 5px 20px
                        rgba(20, 50, 90, 0.08);
        }

        .success {
            color: #167446;
            font-weight: bold;
        }

        .info {
            background: #edf5ff;
            padding: 15px;
            border-radius: 8px;
            margin-top: 22px;
        }

        footer {
            text-align: center;
            color: #66758a;
            padding: 25px;
        }
    </style>
</head>

<body>
    <header>
        <h1><%= hospitalName %></h1>
        <div>Hospital Management &amp; Emergency Coordination</div>
    </header>

    <main>
        <section class="panel">
            <h2>Welcome to the Hospital Management System</h2>

            <p class="success">
                JSP page loaded successfully!
            </p>

            <p>
                This page is being rendered by Apache Tomcat.
            </p>

            <div class="info">
                <strong>Project status:</strong> Phase 1 verification<br>
                <strong>Java version:</strong>
                <%= System.getProperty("java.version") %><br>
                <strong>Server time:</strong>
                <%= currentTime %>
            </div>
				<a class="button"
				href="http://localhost:8080/HospitalManagementSystem/hello">
				Test Servelt
			</a>
        </section>
    </main>

    <footer>
        Academic project demonstration — sample interface only.
    </footer>
</body>
</html>
