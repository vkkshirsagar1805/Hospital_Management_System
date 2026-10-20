
USE hospital_db;

-- DEMONSTRATION DATA ONLY.
-- All names and contact details below are fictional.

-- 1. Demonstration doctors
INSERT INTO doctors
    (department_id, full_name, specialization, qualification,
     phone, email, employment_status)
SELECT
    d.department_id,
    'Demo Doctor One',
    'General Medicine',
    'MBBS',
    '0000000101',
    'demo.doctor1@example.invalid',
    'ACTIVE'
FROM departments d
WHERE d.department_name = 'DEMO - General Medicine'
  AND NOT EXISTS (
      SELECT 1 FROM doctors
      WHERE email = 'demo.doctor1@example.invalid'
  );

INSERT INTO doctors
    (department_id, full_name, specialization, qualification,
     phone, email, employment_status)
SELECT
    d.department_id,
    'Demo Doctor Two',
    'Cardiology',
    'MBBS, MD',
    '0000000102',
    'demo.doctor2@example.invalid',
    'ACTIVE'
FROM departments d
WHERE d.department_name = 'DEMO - Cardiology'
  AND NOT EXISTS (
      SELECT 1 FROM doctors
      WHERE email = 'demo.doctor2@example.invalid'
  );


-- 2. Demonstration patients
INSERT INTO patients
    (full_name, date_of_birth, gender, phone, email,
     address, registration_date, record_status)
SELECT
    'Demo Patient One',
    '1995-05-10',
    'MALE',
    '0000000201',
    'demo.patient1@example.invalid',
    'DEMO - Address One',
    CURRENT_DATE,
    'ACTIVE'
WHERE NOT EXISTS (
    SELECT 1 FROM patients
    WHERE email = 'demo.patient1@example.invalid'
);

INSERT INTO patients
    (full_name, date_of_birth, gender, phone, email,
     address, registration_date, record_status)
SELECT
    'Demo Patient Two',
    '2000-08-15',
    'FEMALE',
    '0000000202',
    'demo.patient2@example.invalid',
    'DEMO - Address Two',
    CURRENT_DATE,
    'ACTIVE'
WHERE NOT EXISTS (
    SELECT 1 FROM patients
    WHERE email = 'demo.patient2@example.invalid'
);


-- 3. Demonstration staff
INSERT INTO staff
    (department_id, full_name, designation, staff_type,
     phone, email, employment_status)
SELECT
    d.department_id,
    'Demo Nurse One',
    'Staff Nurse',
    'NURSE',
    '0000000301',
    'demo.nurse1@example.invalid',
    'ACTIVE'
FROM departments d
WHERE d.department_name = 'DEMO - General Medicine'
  AND NOT EXISTS (
      SELECT 1 FROM staff
      WHERE email = 'demo.nurse1@example.invalid'
  );

INSERT INTO staff
    (department_id, full_name, designation, staff_type,
     phone, email, employment_status)
SELECT
    d.department_id,
    'Demo Technician One',
    'Medical Equipment Technician',
    'TECHNICIAN',
    '0000000302',
    'demo.technician1@example.invalid',
    'ACTIVE'
FROM departments d
WHERE d.department_name = 'DEMO - Emergency'
  AND NOT EXISTS (
      SELECT 1 FROM staff
      WHERE email = 'demo.technician1@example.invalid'
  );
