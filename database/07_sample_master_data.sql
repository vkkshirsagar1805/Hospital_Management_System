
USE hospital_db;

-- DEMONSTRATION DATA ONLY.
-- Do not use these records for real hospital operations.

-- 1. Departments
INSERT IGNORE INTO departments
    (department_name, description, location, status)
VALUES
    ('DEMO - General Medicine',
     'Demonstration department', 'Block A', 'ACTIVE'),
    ('DEMO - Emergency',
     'Demonstration department', 'Ground Floor', 'ACTIVE'),
    ('DEMO - Cardiology',
     'Demonstration department', 'Block B', 'ACTIVE'),
    ('DEMO - Orthopedics',
     'Demonstration department', 'Block C', 'ACTIVE');


-- 2. Beds
INSERT IGNORE INTO beds
    (bed_number, ward_name, bed_type, bed_status,
     floor_number, daily_charge, notes)
VALUES
    ('DEMO-GEN-01', 'DEMO - General Ward',
     'GENERAL', 'AVAILABLE', 1, 500.00, 'Sample record'),
    ('DEMO-GEN-02', 'DEMO - General Ward',
     'GENERAL', 'AVAILABLE', 1, 500.00, 'Sample record'),
    ('DEMO-ICU-01', 'DEMO - ICU',
     'ICU', 'AVAILABLE', 2, 2500.00, 'Sample record'),
    ('DEMO-ISO-01', 'DEMO - Isolation Ward',
     'ISOLATION', 'AVAILABLE', 2, 1200.00, 'Sample record'),
    ('DEMO-EMR-01', 'DEMO - Emergency Ward',
     'EMERGENCY', 'AVAILABLE', 0, 800.00, 'Sample record');


-- 3. Medical equipment and resource inventory
INSERT INTO resource_units
    (resource_name, resource_category, tracking_mode,
     total_quantity, available_quantity, resource_location,
     resource_status, notes)
SELECT
    'DEMO - Ventilator',
    'VENTILATOR', 'QUANTITY',
    5, 5, 'DEMO - ICU', 'ACTIVE', 'Sample inventory'
WHERE NOT EXISTS (
    SELECT 1 FROM resource_units
    WHERE resource_name = 'DEMO - Ventilator'
);

INSERT INTO resource_units
    (resource_name, resource_category, tracking_mode,
     total_quantity, available_quantity, resource_location,
     resource_status, notes)
SELECT
    'DEMO - Patient Monitor',
    'MONITOR', 'QUANTITY',
    10, 10, 'DEMO - ICU', 'ACTIVE', 'Sample inventory'
WHERE NOT EXISTS (
    SELECT 1 FROM resource_units
    WHERE resource_name = 'DEMO - Patient Monitor'
);

INSERT INTO resource_units
    (resource_name, resource_category, tracking_mode,
     total_quantity, available_quantity, resource_location,
     resource_status, notes)
SELECT
    'DEMO - Wheelchair',
    'WHEELCHAIR', 'QUANTITY',
    8, 8, 'DEMO - Main Store', 'ACTIVE', 'Sample inventory'
WHERE NOT EXISTS (
    SELECT 1 FROM resource_units
    WHERE resource_name = 'DEMO - Wheelchair'
);


-- 4. Operation theatres
INSERT IGNORE INTO operation_theatres
    (ot_name, location, ot_type, ot_status, notes)
VALUES
    ('DEMO - OT 1', 'Block B, Floor 2',
     'GENERAL', 'AVAILABLE', 'Sample theatre'),
    ('DEMO - OT 2', 'Block B, Floor 2',
     'ORTHOPEDIC', 'AVAILABLE', 'Sample theatre'),
    ('DEMO - Emergency OT', 'Emergency Block',
     'EMERGENCY', 'AVAILABLE', 'Sample theatre');


-- 5. Emergency contacts
INSERT INTO emergency_contacts
    (contact_name, contact_type, phone, address,
     operating_hours, contact_status, notes)
SELECT
    'DEMO - Hospital Emergency Desk',
    'HOSPITAL', '0000000000',
    'DEMO - Main Building', '24 hours',
    'ACTIVE', 'Fictional demonstration contact'
WHERE NOT EXISTS (
    SELECT 1 FROM emergency_contacts
    WHERE contact_name = 'DEMO - Hospital Emergency Desk'
);

INSERT INTO emergency_contacts
    (contact_name, contact_type, phone, address,
     operating_hours, contact_status, notes)
SELECT
    'DEMO - Ambulance Service',
    'AMBULANCE_SERVICE', '0000000001',
    'DEMO - Transport Office', '24 hours',
    'ACTIVE', 'Fictional demonstration contact'
WHERE NOT EXISTS (
    SELECT 1 FROM emergency_contacts
    WHERE contact_name = 'DEMO - Ambulance Service'
);


-- 6. Ambulances
INSERT IGNORE INTO ambulances
    (vehicle_number, ambulance_type, driver_name,
     driver_phone, current_location, ambulance_status, notes)
VALUES
    ('DEMO-AMB-01', 'BASIC',
     'Demo Driver One', '0000000002',
     'DEMO - Hospital Campus', 'AVAILABLE',
     'Fictional ambulance record'),
    ('DEMO-AMB-02', 'ADVANCED_LIFE_SUPPORT',
     'Demo Driver Two', '0000000003',
     'DEMO - Hospital Campus', 'AVAILABLE',
     'Fictional ambulance record');
