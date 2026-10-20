
# Build the Maven WAR using Java 21
FROM maven:3.9-eclipse-temurin-21 AS build

WORKDIR /app
COPY pom.xml .
COPY src ./src

RUN mvn clean package -DskipTests

# Run the application on Tomcat 10.1
FROM tomcat:10.1-jdk21-temurin

RUN rm -rf /usr/local/tomcat/webapps/*

COPY --from=build /app/target/HospitalManagementSystem.war /usr/local/tomcat/webapps/HospitalManagementSystem.war

# Render provides the PORT environment variable.
# Configure Tomcat to use it when the container starts.
CMD ["sh", "-c", "sed -i 's/port=\"8080\"/port=\"${PORT:-8080}\"/' /usr/local/tomcat/conf/server.xml && catalina.sh run"]
