-- ============================================================
-- SafeOps Toolkit Database
-- ============================================================
USE master;
GO

IF EXISTS (SELECT name FROM sys.databases WHERE name = 'SafeOpsToolkit')
    DROP DATABASE SafeOpsToolkit;
GO

CREATE DATABASE SafeOpsToolkit;
GO
USE SafeOpsToolkit;
GO

-- --------------------------------------------------------
-- Tables
-- --------------------------------------------------------

CREATE TABLE Departments (
    DepartmentID   INT PRIMARY KEY IDENTITY,
    Name           NVARCHAR(100) NOT NULL,
    Location       NVARCHAR(100)
);

CREATE TABLE Employees (
    EmployeeID     INT PRIMARY KEY IDENTITY,
    FirstName      NVARCHAR(50) NOT NULL,
    LastName       NVARCHAR(50) NOT NULL,
    Email          NVARCHAR(100),
    DepartmentID   INT REFERENCES Departments(DepartmentID),
    Role           NVARCHAR(100),
    HireDate       DATE
);

CREATE TABLE IncidentTypes (
    TypeID         INT PRIMARY KEY IDENTITY,
    TypeName       NVARCHAR(100) NOT NULL,
    Severity       NVARCHAR(20) CHECK (Severity IN ('Low','Medium','High','Critical'))
);

CREATE TABLE Incidents (
    IncidentID     INT PRIMARY KEY IDENTITY,
    Title          NVARCHAR(200) NOT NULL,
    Description    NVARCHAR(MAX),
    TypeID         INT REFERENCES IncidentTypes(TypeID),
    ReportedBy     INT REFERENCES Employees(EmployeeID),
    AssignedTo     INT REFERENCES Employees(EmployeeID),
    Location       NVARCHAR(200),
    Status         NVARCHAR(30) CHECK (Status IN ('Open','In Progress','Resolved','Closed')) DEFAULT 'Open',
    ReportedDate   DATETIME DEFAULT GETDATE(),
    ResolvedDate   DATETIME
);

CREATE TABLE SafetyChecks (
    CheckID        INT PRIMARY KEY IDENTITY,
    CheckName      NVARCHAR(200) NOT NULL,
    DepartmentID   INT REFERENCES Departments(DepartmentID),
    PerformedBy    INT REFERENCES Employees(EmployeeID),
    CheckDate      DATE NOT NULL,
    Passed         BIT NOT NULL,
    Notes          NVARCHAR(MAX)
);

CREATE TABLE Equipment (
    EquipmentID    INT PRIMARY KEY IDENTITY,
    Name           NVARCHAR(100) NOT NULL,
    SerialNumber   NVARCHAR(50),
    DepartmentID   INT REFERENCES Departments(DepartmentID),
    Status         NVARCHAR(30) CHECK (Status IN ('Operational','Maintenance','Decommissioned')) DEFAULT 'Operational',
    LastInspected  DATE,
    NextInspection DATE
);

CREATE TABLE RiskAssessments (
    AssessmentID   INT PRIMARY KEY IDENTITY,
    Title          NVARCHAR(200) NOT NULL,
    DepartmentID   INT REFERENCES Departments(DepartmentID),
    AssessedBy     INT REFERENCES Employees(EmployeeID),
    RiskLevel      NVARCHAR(20) CHECK (RiskLevel IN ('Low','Medium','High','Critical')),
    AssessmentDate DATE,
    ReviewDate     DATE,
    Mitigations    NVARCHAR(MAX)
);

-- --------------------------------------------------------
-- Sample Data
-- --------------------------------------------------------

INSERT INTO Departments (Name, Location) VALUES
('Operations',       'Building A - Floor 1'),
('Field Safety',     'Building B - Floor 2'),
('IT Security',      'Building C - Floor 3'),
('Compliance',       'Building A - Floor 4'),
('Maintenance',      'Building D - Ground Floor');

INSERT INTO Employees (FirstName, LastName, Email, DepartmentID, Role, HireDate) VALUES
('James',   'Carter',   'j.carter@safeops.com',   1, 'Operations Manager',    '2019-03-15'),
('Sara',    'Mitchell', 's.mitchell@safeops.com',  2, 'Field Safety Officer',  '2020-06-01'),
('Raj',     'Patel',    'r.patel@safeops.com',     3, 'IT Security Analyst',   '2021-01-10'),
('Linda',   'Nguyen',   'l.nguyen@safeops.com',    4, 'Compliance Lead',       '2018-09-22'),
('Tom',     'Brooks',   't.brooks@safeops.com',    5, 'Maintenance Tech',      '2022-04-05'),
('Aisha',   'Khan',     'a.khan@safeops.com',      2, 'Safety Inspector',      '2021-11-18'),
('Derek',   'Walsh',    'd.walsh@safeops.com',     1, 'Operations Analyst',    '2023-02-28'),
('Priya',   'Sharma',   'p.sharma@safeops.com',    3, 'Security Engineer',     '2020-07-14');

INSERT INTO IncidentTypes (TypeName, Severity) VALUES
('Slip and Fall',           'Medium'),
('Equipment Failure',       'High'),
('Chemical Spill',          'Critical'),
('Cyber Security Breach',   'Critical'),
('Near Miss',               'Low'),
('Fire Hazard',             'High'),
('Ergonomic Issue',         'Low');

INSERT INTO Incidents (Title, Description, TypeID, ReportedBy, AssignedTo, Location, Status, ReportedDate, ResolvedDate) VALUES
('Wet floor in corridor B',         'Employee slipped near restroom entrance',                      1, 2, 5, 'Building B - Corridor B', 'Resolved',     '2026-01-05', '2026-01-06'),
('Generator unit malfunction',      'Backup generator failed during scheduled test',                2, 1, 5, 'Building D - Generator Room', 'Closed',    '2026-01-12', '2026-01-20'),
('Solvent spill in lab',            'Small chemical spill during equipment cleaning',               3, 6, 2, 'Building B - Lab 3',      'Resolved',     '2026-02-03', '2026-02-03'),
('Phishing attack detected',        'Employee received and clicked suspicious email link',          4, 3, 8, 'IT - Endpoint #47',        'In Progress',  '2026-03-10', NULL),
('Near miss at loading dock',       'Forklift came within 1m of pedestrian walkway',               5, 7, 2, 'Building D - Loading Dock','Closed',       '2026-03-18', '2026-03-19'),
('Electrical panel overheating',    'Panel in Server Room showing elevated temperature readings',   6, 3, 5, 'Building C - Server Room', 'Open',         '2026-04-01', NULL),
('Repetitive strain complaint',     'Data entry employee reported wrist pain',                     7, 4, 2, 'Building A - Office 12',   'In Progress',  '2026-04-15', NULL);

INSERT INTO SafetyChecks (CheckName, DepartmentID, PerformedBy, CheckDate, Passed, Notes) VALUES
('Monthly Fire Extinguisher Inspection',    1, 6, '2026-01-10', 1, 'All units fully charged'),
('Quarterly Electrical Safety Audit',       3, 3, '2026-01-15', 0, 'Panel C3 flagged for maintenance'),
('PPE Compliance Check',                    2, 2, '2026-02-01', 1, 'All staff compliant'),
('Server Room Climate Check',               3, 8, '2026-02-20', 1, 'Temp and humidity within range'),
('Loading Dock Safety Walk',                5, 6, '2026-03-05', 0, 'Signage missing at two entry points'),
('Chemical Storage Inspection',             2, 2, '2026-03-22', 1, 'All containers properly labelled'),
('Ergonomics Workstation Review',           4, 4, '2026-04-10', 1, '3 desks adjusted for compliance');

INSERT INTO Equipment (Name, SerialNumber, DepartmentID, Status, LastInspected, NextInspection) VALUES
('Backup Generator',        'GEN-2201',  1, 'Maintenance',   '2026-01-12', '2026-04-12'),
('Fire Suppression System', 'FSS-0091',  2, 'Operational',   '2026-01-10', '2026-07-10'),
('CCTV Network Array',      'CCTV-5543', 3, 'Operational',   '2026-02-20', '2026-08-20'),
('Forklift Unit 1',         'FLT-1102',  5, 'Operational',   '2026-03-01', '2026-06-01'),
('Air Quality Monitor',     'AQM-3310',  2, 'Operational',   '2026-02-15', '2026-05-15'),
('Electrical Panel C3',     'EP-C3-008', 3, 'Maintenance',   '2026-04-01', '2026-04-15');

INSERT INTO RiskAssessments (Title, DepartmentID, AssessedBy, RiskLevel, AssessmentDate, ReviewDate, Mitigations) VALUES
('Chemical Handling Procedures',    2, 4, 'Medium',   '2026-01-20', '2026-07-20', 'Mandatory PPE, spill kits on site, monthly drills'),
('Cyber Threat Landscape Q1',       3, 3, 'High',     '2026-02-01', '2026-05-01', 'Phishing training, MFA enforced, endpoint monitoring'),
('Loading Dock Pedestrian Safety',  5, 2, 'High',     '2026-03-18', '2026-06-18', 'Dedicated walkways, new signage, speed limits'),
('Office Ergonomics Assessment',    4, 4, 'Low',      '2026-04-10', '2026-10-10', 'Adjustable desks, training materials distributed'),
('Server Room Power Redundancy',    3, 8, 'Critical', '2026-04-02', '2026-04-30', 'Generator audit scheduled, UPS battery check pending');
GO
