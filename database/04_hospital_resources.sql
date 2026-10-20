
USE hospital_db;

-- 1. Physical beds, including general ward and ICU beds
CREATE TABLE IF NOT EXISTS beds (
    bed_id INT AUTO_INCREMENT PRIMARY KEY,
    bed_number VARCHAR(30) NOT NULL UNIQUE,
    ward_name VARCHAR(100) NOT NULL,
    bed_type ENUM(
        'GENERAL', 'PRIVATE', 'ICU', 'ISOLATION', 'EMERGENCY'
    ) NOT NULL DEFAULT 'GENERAL',
    bed_status ENUM(
        'AVAILABLE', 'OCCUPIED', 'MAINTENANCE', 'RESERVED'
    ) NOT NULL DEFAULT 'AVAILABLE',
    floor_number INT NULL,
    daily_charge DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    notes VARCHAR(500) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_bed_charge
        CHECK (daily_charge >= 0),

    INDEX idx_bed_ward_status (ward_name, bed_status),
    INDEX idx_bed_type_status (bed_type, bed_status)
) ENGINE=InnoDB;


-- 2. Count-based or individually tracked hospital resources
CREATE TABLE IF NOT EXISTS resource_units (
    resource_id INT AUTO_INCREMENT PRIMARY KEY,
    resource_name VARCHAR(150) NOT NULL,
    resource_category ENUM(
        'VENTILATOR', 'OXYGEN', 'MONITOR',
        'WHEELCHAIR', 'STRETCHER', 'OTHER'
    ) NOT NULL DEFAULT 'OTHER',
    tracking_mode ENUM('QUANTITY', 'INDIVIDUAL')
        NOT NULL DEFAULT 'QUANTITY',
    total_quantity INT NOT NULL DEFAULT 0,
    available_quantity INT NOT NULL DEFAULT 0,
    resource_location VARCHAR(150) NULL,
    resource_status ENUM(
        'ACTIVE', 'INACTIVE', 'MAINTENANCE'
    ) NOT NULL DEFAULT 'ACTIVE',
    notes VARCHAR(500) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT chk_resource_quantities
        CHECK (
            total_quantity >= 0
            AND available_quantity >= 0
            AND available_quantity <= total_quantity
        ),

    INDEX idx_resource_category_status (resource_category, resource_status)
) ENGINE=InnoDB;


-- 3. Operation theatres
CREATE TABLE IF NOT EXISTS operation_theatres (
    ot_id INT AUTO_INCREMENT PRIMARY KEY,
    ot_name VARCHAR(100) NOT NULL UNIQUE,
    location VARCHAR(150) NULL,
    ot_type ENUM(
        'GENERAL', 'CARDIAC', 'NEUROLOGY',
        'ORTHOPEDIC', 'EMERGENCY', 'OTHER'
    ) NOT NULL DEFAULT 'GENERAL',
    ot_status ENUM(
        'AVAILABLE', 'IN_USE', 'MAINTENANCE', 'INACTIVE'
    ) NOT NULL DEFAULT 'AVAILABLE',
    notes VARCHAR(500) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    INDEX idx_ot_status_type (ot_status, ot_type)
) ENGINE=InnoDB;


-- 4. Operation theatre schedules
CREATE TABLE IF NOT EXISTS ot_schedules (
    ot_schedule_id INT AUTO_INCREMENT PRIMARY KEY,
    ot_id INT NOT NULL,
    doctor_id INT NOT NULL,
    procedure_name VARCHAR(200) NOT NULL,
    scheduled_start DATETIME NOT NULL,
    scheduled_end DATETIME NOT NULL,
    schedule_status ENUM(
        'SCHEDULED', 'IN_PROGRESS',
        'COMPLETED', 'CANCELLED'
    ) NOT NULL DEFAULT 'SCHEDULED',
    notes VARCHAR(500) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_ot_schedule_theatre
        FOREIGN KEY (ot_id)
        REFERENCES operation_theatres(ot_id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_ot_schedule_doctor
        FOREIGN KEY (doctor_id)
        REFERENCES doctors(doctor_id)
        ON DELETE RESTRICT,

    CONSTRAINT chk_ot_schedule_time
        CHECK (scheduled_end > scheduled_start),

    INDEX idx_ot_schedule_theatre_time (ot_id, scheduled_start),
    INDEX idx_ot_schedule_doctor_time (doctor_id, scheduled_start),
    INDEX idx_ot_schedule_status (schedule_status)
) ENGINE=InnoDB;


-- 5. Allocations of beds or other resource units
CREATE TABLE IF NOT EXISTS resource_allocations (
    allocation_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NULL,
    bed_id INT NULL,
    resource_id INT NULL,
    allocated_quantity INT NOT NULL DEFAULT 1,
    allocated_by INT NULL,
    allocation_start DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    allocation_end DATETIME NULL,
    allocation_status ENUM(
        'ACTIVE', 'RELEASED', 'CANCELLED'
    ) NOT NULL DEFAULT 'ACTIVE',
    notes VARCHAR(500) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_allocation_patient
        FOREIGN KEY (patient_id)
        REFERENCES patients(patient_id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_allocation_bed
        FOREIGN KEY (bed_id)
        REFERENCES beds(bed_id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_allocation_resource
        FOREIGN KEY (resource_id)
        REFERENCES resource_units(resource_id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_allocation_user
        FOREIGN KEY (allocated_by)
        REFERENCES users(user_id)
        ON DELETE SET NULL,

    CONSTRAINT chk_allocation_target
        CHECK (bed_id IS NOT NULL OR resource_id IS NOT NULL),

    CONSTRAINT chk_allocation_quantity
        CHECK (allocated_quantity > 0),

    CONSTRAINT chk_allocation_dates
        CHECK (
            allocation_end IS NULL
            OR allocation_end >= allocation_start
        ),

    INDEX idx_allocation_patient_status (patient_id, allocation_status),
    INDEX idx_allocation_bed_status (bed_id, allocation_status),
    INDEX idx_allocation_resource_status (resource_id, allocation_status)
) ENGINE=InnoDB;
