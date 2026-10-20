
CREATE DATABASE IF NOT EXISTS hospital_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE hospital_db;

SELECT DATABASE() AS current_database;

SELECT VERSION() AS mysql_server_version;
