-- ===============================
-- RFID Attendance DB (6-hour Timer System + Email + Percentage + Corrections)
-- ===============================

SET FOREIGN_KEY_CHECKS = 0;
CREATE DATABASE IF NOT EXISTS rfid_system;
USE rfid_system;


DROP TABLE IF EXISTS email_events;
DROP TABLE IF EXISTS attendance_correction_log;
DROP TABLE IF EXISTS attendance_corrections;
DROP TABLE IF EXISTS attendance;
DROP TABLE IF EXISTS rfid_cards;
SET FOREIGN_KEY_CHECKS = 1;

-- ===============================
-- RFID CARDS (Master Table)
-- ===============================
CREATE TABLE rfid_cards (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  uid VARCHAR(100) NOT NULL UNIQUE,
  name VARCHAR(150) NOT NULL,
  email VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ===============================
-- ATTENDANCE TABLE (6 HOUR TIMER)
-- ===============================
CREATE TABLE attendance (
  id INT AUTO_INCREMENT PRIMARY KEY,
  uid VARCHAR(100) NOT NULL,
  name VARCHAR(100) NOT NULL,

  -- TIMER START (first scan)
  session_start TIMESTAMP NULL,

  -- TIMER STOP (second scan)
  session_end TIMESTAMP NULL,

  -- FINAL CONFIRMATION TIME (IMPORTANT)
  confirmed_at TIMESTAMP NULL,

  -- AUTO CALCULATED HOURS
  duration_hours DECIMAL(5,2) GENERATED ALWAYS AS (
      IF(session_start IS NOT NULL AND session_end IS NOT NULL,
         TIMESTAMPDIFF(SECOND, session_start, session_end) / 3600,
         0)
  ) STORED,

  -- FINAL ATTENDANCE TIME
  time_in TIMESTAMP NULL,

  -- DATE FOR UNIQUE PER DAY
  date_in DATE AS (DATE(COALESCE(time_in, session_start))) STORED,

  status ENUM('PENDING','PRESENT','ABSENT','LEAVE')
       NOT NULL DEFAULT 'PENDING',

  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  FOREIGN KEY (uid) REFERENCES rfid_cards(uid)
      ON UPDATE CASCADE
      ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE INDEX idx_att_uid  ON attendance(uid);
CREATE INDEX idx_att_time ON attendance(time_in);

-- UNIQUE PER DAY PER STUDENT
ALTER TABLE attendance
  ADD CONSTRAINT uq_attendance_uid_day UNIQUE (uid, date_in);

-- ===============================
-- ATTENDANCE CORRECTIONS
-- ===============================
CREATE TABLE attendance_corrections (
  id INT AUTO_INCREMENT PRIMARY KEY,
  attendance_id INT NOT NULL,
  old_status VARCHAR(10) NOT NULL,
  new_status VARCHAR(10) NOT NULL,
  requested_by VARCHAR(100) NOT NULL,
  requested_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  approved ENUM('PENDING', 'APPROVED', 'REJECTED') DEFAULT 'PENDING',
  approved_by VARCHAR(100),
  approved_at TIMESTAMP NULL,
  reason VARCHAR(255),
  remarks TEXT,
  FOREIGN KEY (attendance_id) REFERENCES attendance(id)
) ENGINE=InnoDB;

CREATE INDEX idx_corrections_status ON attendance_corrections(approved);

-- ===============================
-- ATTENDANCE CORRECTION LOG
-- ===============================
CREATE TABLE attendance_correction_log (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  correction_id INT NOT NULL,
  action VARCHAR(20) NOT NULL,
  action_by VARCHAR(100),
  action_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  comment TEXT,
  FOREIGN KEY (correction_id) REFERENCES attendance_corrections(id)
) ENGINE=InnoDB;

-- ===============================
-- EMAIL EVENTS
-- ===============================
CREATE TABLE email_events (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,

  uid VARCHAR(100) NOT NULL,
  email_to VARCHAR(255) NOT NULL,

  subject VARCHAR(255) NOT NULL,
  body TEXT NOT NULL,

  status ENUM('SENT','FAILED') NOT NULL,
  error_text VARCHAR(500),

  sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE INDEX idx_email_uid_time ON email_events(uid, sent_at);


-- ===============================
CREATE TABLE tasks (
  id INT AUTO_INCREMENT PRIMARY KEY,

  uid VARCHAR(100) NOT NULL,
  title VARCHAR(200) NOT NULL,
  description TEXT NOT NULL,

  assigned_date DATE NOT NULL,

  status ENUM('PENDING','COMPLETED') 
         NOT NULL DEFAULT 'PENDING',

  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  FOREIGN KEY (uid) REFERENCES rfid_cards(uid)
      ON UPDATE CASCADE
      ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE INDEX idx_tasks_uid_date ON tasks(uid, assigned_date);
-- ===============================
-- SEED DATA
-- ===============================
INSERT INTO rfid_cards (uid, name, email) VALUES
('626C1001','Nikhil Maurya','nikhil6.maurya@gmail.com'),
('92901001','Yash Singh','hellownoob999@gmail.com'),
('82AA1001','Aman Verma','aman@example.com'),
('B24C0701','Neha Patel','neha@example.com');

SELECT * FROM email_events
ORDER BY sent_at DESC;
SELECT * FROM email_events ORDER BY sent_at DESC;

-- ===============================
-- DASHBOARD VIEW
-- ===============================
CREATE OR REPLACE VIEW v_attendance_dashboard AS
SELECT
  ROW_NUMBER() OVER (ORDER BY a.id DESC) AS serial,
  a.id, a.uid, a.name,
  DATE_FORMAT(a.time_in, '%Y-%m-%d %H:%i:%s') AS time_in,
  a.status,
  a.duration_hours
FROM attendance a
ORDER BY a.id DESC;

-- ===============================
-- DAILY / WEEKLY / MONTHLY VIEWS
-- ===============================
-- =========================
-- DAILY (TODAY)
-- =========================
CREATE OR REPLACE VIEW v_student_daily_report AS
SELECT
  uid,
  name,
  COUNT(DISTINCT DATE(confirmed_at)) AS total_days,
  SUM(CASE WHEN status='PRESENT' THEN 1 ELSE 0 END) AS present_days,
  ROUND(
    SUM(CASE WHEN status='PRESENT' THEN 1 ELSE 0 END) * 100.0 /
    COUNT(DISTINCT DATE(confirmed_at)),
    2
  ) AS attendance_percentage
FROM attendance
WHERE DATE(confirmed_at) = CURDATE()
GROUP BY uid, name;
-- =========================
-- WEEKLY (LAST 7 DAYS)
-- =========================
CREATE OR REPLACE VIEW v_student_weekly_report AS
SELECT
  uid,
  name,
  COUNT(DISTINCT DATE(confirmed_at)) AS total_days,
  SUM(CASE WHEN status='PRESENT' THEN 1 ELSE 0 END) AS present_days,
  ROUND(
    SUM(CASE WHEN status='PRESENT' THEN 1 ELSE 0 END) * 100.0 /
    COUNT(DISTINCT DATE(confirmed_at)),
    2
  ) AS attendance_percentage
FROM attendance
WHERE confirmed_at >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
GROUP BY uid, name;
-- =========================
-- MONTHLY (CURRENT MONTH)
-- =========================
CREATE OR REPLACE VIEW v_student_monthly_report AS
SELECT
  uid,
  name,
  COUNT(DISTINCT DATE(confirmed_at)) AS total_days,
  SUM(CASE WHEN status='PRESENT' THEN 1 ELSE 0 END) AS present_days,
  ROUND(
    SUM(CASE WHEN status='PRESENT' THEN 1 ELSE 0 END) * 100.0 /
    COUNT(DISTINCT DATE(confirmed_at)),
    2
  ) AS attendance_percentage
FROM attendance
WHERE
  MONTH(confirmed_at) = MONTH(CURDATE())
  AND YEAR(confirmed_at) = YEAR(CURDATE())
GROUP BY uid, name;
-- =========================
-- YEARLY (CURRENT YEAR)
-- =========================
CREATE OR REPLACE VIEW v_student_yearly_report AS
SELECT
  uid,
  name,
  COUNT(DISTINCT DATE(confirmed_at)) AS total_days,
  SUM(CASE WHEN status='PRESENT' THEN 1 ELSE 0 END) AS present_days,
  ROUND(
    SUM(CASE WHEN status='PRESENT' THEN 1 ELSE 0 END) * 100.0 /
    COUNT(DISTINCT DATE(confirmed_at)),
    2
  ) AS attendance_percentage
FROM attendance
WHERE YEAR(confirmed_at) = YEAR(CURDATE())
GROUP BY uid, name;

SELECT * FROM v_student_daily_report;
SELECT * FROM v_student_weekly_report;
SELECT * FROM v_student_monthly_report;
SELECT * FROM v_student_yearly_report;


-- ===============================
-- PRIVILEGES
-- ===============================
GRANT ALL PRIVILEGES ON rfid_system.* TO 'nikhil'@'localhost';
FLUSH PRIVILEGES;
SELECT id, uid, name, date_in, status
FROM attendance
ORDER BY id DESC;

select* from tasks;
select* from email_events order by sent_at desc;
select*from rfid_cards;


DELETE FROM rfid_cards WHERE uid='52FD2001';
