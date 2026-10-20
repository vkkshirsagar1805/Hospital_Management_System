
USE hospital_db;

-- 1. Hospital departments
CREATE TABLE IF NOT EXISTS departments (
    department_id INT AUTO_INCREMENT PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL UNIQUE,
    description VARCHAR(500),
    location VARCHAR(150),
    status ENUM('ACTIVE', 'INACTIVE') NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 2. Application login accounts
CREATE TABLE IF NOT EXISTS users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(60) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM(
        'ADMIN',
        'DOCTOR',
        'STAFF',
        'RECEPTIONIST'
    ) NOT NULL,
    account_status ENUM(
        'ACTIVE',
        'DISABLED',
        'LOCKED'
    ) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 3. Patient registration records
CREATE TABLE IF NOT EXISTS patients (
    patient_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNIQUE,
    full_name VARCHAR(120) NOT NULL,
    date_of_birth DATE,
    gender ENUM(
        'MALE',
        'FEMALE',
        'OTHER',
        'UNSPECIFIED'
    ) NOT NULL DEFAULT 'UNSPECIFIED',
    phone VARCHAR(20),
    email VARCHAR(150),
    address VARCHAR(500),
    registration_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_status ENUM(
        'ACTIVE',
        'INACTIVE'
    ) NOT NULL DEFAULT 'ACTIVE',

    CONSTRAINT fk_patients_user
        FOREIGN KEY (user_id)
        REFERENCES users(user_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,

    INDEX idx_patients_name (full_name),
    INDEX idx_patients_phone (phone)
) ENGINE=InnoDB;

-- 4. Doctor profiles
CREATE TABLE IF NOT EXISTS doctors (
    doctor_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNIQUE,
    department_id INT NOT NULL,
    full_name VARCHAR(120) NOT NULL,
    specialization VARCHAR(120) NOT NULL,
    qualification VARCHAR(200),
    phone VARCHAR(20),
    email VARCHAR(150),
    employment_status ENUM(
        'ACTIVE',
        'ON_LEAVE',
        'INACTIVE'
    ) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_doctors_user
        FOREIGN KEY (user_id)
        REFERENCES users(user_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,

    CONSTRAINT fk_doctors_department
        FOREIGN KEY (department_id)
        REFERENCES departments(department_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    INDEX idx_doctors_name (full_name),
    INDEX idx_doctors_department (department_id)
) ENGINE=InnoDB;

-- 5. Hospital staff
CREATE TABLE IF NOT EXISTS staff (
    staff_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNIQUE,
    department_id INT NOT NULL,
    supervisor_staff_id INT,
    supervisor_doctor_id INT,
    full_name VARCHAR(120) NOT NULL,
    designation VARCHAR(100) NOT NULL,
    staff_type ENUM(
        'NURSE',
        'RESIDENT',
        'CONSULTANT',
        'TECHNICIAN',
        'ADMINISTRATIVE',
        'OTHER'
    ) NOT NULL DEFAULT 'OTHER',
    phone VARCHAR(20),
    email VARCHAR(150),
    employment_status ENUM(
        'ACTIVE',
        'ON_LEAVE',
        'INACTIVE'
    ) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_staff_user
        FOREIGN KEY (user_id)
        REFERENCES users(user_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,

    CONSTRAINT fk_staff_department
        FOREIGN KEY (department_id)
        REFERENCES departments(department_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_staff_supervisor
        FOREIGN KEY (supervisor_staff_id)
        REFERENCES staff(staff_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,

    CONSTRAINT fk_staff_supervisor_doctor
        FOREIGN KEY (supervisor_doctor_id)
        REFERENCES doctors(doctor_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,

    INDEX idx_staff_name (full_name),
    INDEX idx_staff_department (department_id),
    INDEX idx_staff_supervisor (supervisor_staff_id)
) ENGINE=InnoDB;
