
USE hospital_db;

CREATE TABLE IF NOT EXISTS audit_logs (
    audit_log_id INT AUTO_INCREMENT PRIMARY KEY,

    user_id INT NULL,

    action_type ENUM(
        'CREATE', 'UPDATE', 'DELETE',
        'LOGIN', 'LOGOUT', 'ALLOCATE',
        'RELEASE', 'STATUS_CHANGE', 'OTHER'
    ) NOT NULL DEFAULT 'OTHER',

    entity_type VARCHAR(100) NOT NULL,
    entity_id INT NULL,

    action_description VARCHAR(1000) NULL,
    ip_address VARCHAR(45) NULL,

    action_status ENUM(
        'SUCCESS', 'FAILURE'
    ) NOT NULL DEFAULT 'SUCCESS',

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_audit_user
        FOREIGN KEY (user_id)
        REFERENCES users(user_id)
        ON DELETE SET NULL,

    INDEX idx_audit_user_time (user_id, created_at),
    INDEX idx_audit_entity (entity_type, entity_id),
    INDEX idx_audit_action_time (action_type, created_at),
    INDEX idx_audit_status (action_status, created_at)
) ENGINE=InnoDB;
