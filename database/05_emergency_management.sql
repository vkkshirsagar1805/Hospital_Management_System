
USE hospital_db;

-- 1. Emergency contacts
CREATE TABLE IF NOT EXISTS emergency_contacts (
    contact_id INT AUTO_INCREMENT PRIMARY KEY,
    contact_name VARCHAR(150) NOT NULL,
    contact_type ENUM(
        'HOSPITAL', 'AMBULANCE_SERVICE', 'FIRE',
        'POLICE', 'BLOOD_BANK', 'OTHER'
    ) NOT NULL DEFAULT 'OTHER',
    phone VARCHAR(25) NOT NULL,
    alternate_phone VARCHAR(25) NULL,
    address VARCHAR(300) NULL,
    operating_hours VARCHAR(100) NULL,
    contact_status ENUM('ACTIVE', 'INACTIVE')
        NOT NULL DEFAULT 'ACTIVE',
    notes VARCHAR(500) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    INDEX idx_emergency_contact_type (contact_type, contact_status)
) ENGINE=InnoDB;


-- 2. Ambulance records
CREATE TABLE IF NOT EXISTS ambulances (
    ambulance_id INT AUTO_INCREMENT PRIMARY KEY,
    vehicle_number VARCHAR(30) NOT NULL UNIQUE,
    ambulance_type ENUM(
        'BASIC', 'ADVANCED_LIFE_SUPPORT',
        'PATIENT_TRANSPORT', 'OTHER'
    ) NOT NULL DEFAULT 'BASIC',
    driver_name VARCHAR(150) NULL,
    driver_phone VARCHAR(25) NULL,
    current_location VARCHAR(255) NULL,
    ambulance_status ENUM(
        'AVAILABLE', 'ASSIGNED', 'ON_TRIP',
        'MAINTENANCE', 'OUT_OF_SERVICE'
    ) NOT NULL DEFAULT 'AVAILABLE',
    last_status_update TIMESTAMP NOT NULL
        DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,
    notes VARCHAR(500) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    INDEX idx_ambulance_status (ambulance_status),
    INDEX idx_ambulance_type_status (ambulance_type, ambulance_status)
) ENGINE=InnoDB;


-- 3. Emergency requests
CREATE TABLE IF NOT EXISTS emergency_requests (
    emergency_request_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NULL,
    ambulance_id INT NULL,
    reported_by INT NULL,
    emergency_type ENUM(
        'MEDICAL', 'ACCIDENT', 'CARDIAC',
        'RESPIRATORY', 'TRAUMA', 'OTHER'
    ) NOT NULL DEFAULT 'MEDICAL',
    severity ENUM('LOW', 'MEDIUM', 'HIGH', 'CRITICAL')
        NOT NULL DEFAULT 'MEDIUM',
    request_location VARCHAR(300) NOT NULL,
    request_description TEXT NULL,
    request_status ENUM(
        'REPORTED', 'ACKNOWLEDGED', 'DISPATCHED',
        'IN_PROGRESS', 'RESOLVED', 'CANCELLED'
    ) NOT NULL DEFAULT 'REPORTED',
    requested_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    dispatched_at DATETIME NULL,
    resolved_at DATETIME NULL,
    resolution_notes VARCHAR(500) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_emergency_patient
        FOREIGN KEY (patient_id)
        REFERENCES patients(patient_id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_emergency_ambulance
        FOREIGN KEY (ambulance_id)
        REFERENCES ambulances(ambulance_id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_emergency_reporter
        FOREIGN KEY (reported_by)
        REFERENCES users(user_id)
        ON DELETE SET NULL,

    CONSTRAINT chk_emergency_resolution_time
        CHECK (
            resolved_at IS NULL
            OR resolved_at >= requested_at
        ),

    INDEX idx_emergency_status_time (request_status, requested_at),
    INDEX idx_emergency_severity_status (severity, request_status),
    INDEX idx_emergency_patient (patient_id)
) ENGINE=InnoDB;
