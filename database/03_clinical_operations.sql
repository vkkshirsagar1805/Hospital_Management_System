
USE hospital_db;

-- 1. Doctor schedules
CREATE TABLE IF NOT EXISTS doctor_schedules (
    schedule_id INT AUTO_INCREMENT PRIMARY KEY,
    doctor_id INT NOT NULL,
    day_of_week ENUM(
        'MONDAY', 'TUESDAY', 'WEDNESDAY',
        'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY'
    ) NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    valid_from DATE NOT NULL,
    valid_until DATE NULL,
    schedule_status ENUM('ACTIVE', 'INACTIVE')
        NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_schedule_doctor
        FOREIGN KEY (doctor_id)
        REFERENCES doctors(doctor_id)
        ON DELETE RESTRICT,

    CONSTRAINT chk_schedule_time
        CHECK (end_time > start_time),

    CONSTRAINT chk_schedule_dates
        CHECK (valid_until IS NULL OR valid_until >= valid_from),

    INDEX idx_schedule_doctor_day (doctor_id, day_of_week),
    INDEX idx_schedule_status (schedule_status)
) ENGINE=InnoDB;


-- 2. Patient appointments
CREATE TABLE IF NOT EXISTS appointments (
    appointment_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    schedule_id INT NULL,
    appointment_datetime DATETIME NOT NULL,
    reason VARCHAR(500) NULL,
    appointment_status ENUM(
        'REQUESTED', 'CONFIRMED', 'CHECKED_IN',
        'COMPLETED', 'CANCELLED', 'NO_SHOW'
    ) NOT NULL DEFAULT 'REQUESTED',
    created_by INT NULL,
    notes VARCHAR(1000) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_appointment_patient
        FOREIGN KEY (patient_id)
        REFERENCES patients(patient_id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_appointment_doctor
        FOREIGN KEY (doctor_id)
        REFERENCES doctors(doctor_id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_appointment_schedule
        FOREIGN KEY (schedule_id)
        REFERENCES doctor_schedules(schedule_id)
        ON DELETE SET NULL,

    CONSTRAINT fk_appointment_creator
        FOREIGN KEY (created_by)
        REFERENCES users(user_id)
        ON DELETE SET NULL,

    INDEX idx_appointment_patient (patient_id),
    INDEX idx_appointment_doctor_time (doctor_id, appointment_datetime),
    INDEX idx_appointment_status_time (appointment_status, appointment_datetime)
) ENGINE=InnoDB;


-- 3. Ward rounds
CREATE TABLE IF NOT EXISTS ward_rounds (
    ward_round_id INT AUTO_INCREMENT PRIMARY KEY,
    doctor_id INT NOT NULL,
    round_date DATE NOT NULL,
    start_time TIME NULL,
    end_time TIME NULL,
    ward_name VARCHAR(100) NOT NULL,
    notes TEXT NULL,
    round_status ENUM(
        'PLANNED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED'
    ) NOT NULL DEFAULT 'PLANNED',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_ward_round_doctor
        FOREIGN KEY (doctor_id)
        REFERENCES doctors(doctor_id)
        ON DELETE RESTRICT,

    CONSTRAINT chk_ward_round_time
        CHECK (
            start_time IS NULL
            OR end_time IS NULL
            OR end_time > start_time
        ),

    INDEX idx_ward_round_date (round_date),
    INDEX idx_ward_round_doctor_date (doctor_id, round_date)
) ENGINE=InnoDB;


-- 4. Staff duty assignments
CREATE TABLE IF NOT EXISTS staff_assignments (
    assignment_id INT AUTO_INCREMENT PRIMARY KEY,
    staff_id INT NOT NULL,
    department_id INT NOT NULL,
    assigned_by INT NULL,
    assignment_title VARCHAR(150) NOT NULL,
    duty_location VARCHAR(150) NULL,
    shift_start DATETIME NOT NULL,
    shift_end DATETIME NOT NULL,
    assignment_status ENUM(
        'SCHEDULED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED'
    ) NOT NULL DEFAULT 'SCHEDULED',
    notes VARCHAR(500) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_assignment_staff
        FOREIGN KEY (staff_id)
        REFERENCES staff(staff_id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_assignment_department
        FOREIGN KEY (department_id)
        REFERENCES departments(department_id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_assignment_user
        FOREIGN KEY (assigned_by)
        REFERENCES users(user_id)
        ON DELETE SET NULL,

    CONSTRAINT chk_assignment_time
        CHECK (shift_end > shift_start),

    INDEX idx_assignment_staff_shift (staff_id, shift_start),
    INDEX idx_assignment_department_shift (department_id, shift_start),
    INDEX idx_assignment_status (assignment_status)
) ENGINE=InnoDB;


-- 5. Staff participating in ward rounds
CREATE TABLE IF NOT EXISTS round_staff_assignments (
    ward_round_id INT NOT NULL,
    staff_id INT NOT NULL,
    assigned_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    participation_notes VARCHAR(300) NULL,

    PRIMARY KEY (ward_round_id, staff_id),

    CONSTRAINT fk_round_staff_round
        FOREIGN KEY (ward_round_id)
        REFERENCES ward_rounds(ward_round_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_round_staff_staff
        FOREIGN KEY (staff_id)
        REFERENCES staff(staff_id)
        ON DELETE RESTRICT,

    INDEX idx_round_staff_staff (staff_id)
) ENGINE=InnoDB;
