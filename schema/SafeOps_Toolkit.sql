USE master;
GO

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'SafeOps_Toolkit')
    CREATE DATABASE SafeOps_Toolkit;
GO

USE SafeOps_Toolkit;
GO

CREATE TABLE Users (
    UserID          INT IDENTITY(1,1) PRIMARY KEY,
    Username        NVARCHAR(100)   NOT NULL,
    FullName        NVARCHAR(150)   NOT NULL,
    Email           NVARCHAR(200)   NOT NULL UNIQUE,
    Department      NVARCHAR(100),
    Role            NVARCHAR(50)    NOT NULL,
    AccessLevel     NVARCHAR(20)    NOT NULL,
    AccountStatus   NVARCHAR(20)    NOT NULL DEFAULT 'Active',
    CreatedAt       DATETIME        NOT NULL DEFAULT GETDATE(),
    LastLogin       DATETIME
);
GO

CREATE TABLE Assets (
    AssetID         INT IDENTITY(1,1) PRIMARY KEY,
    AssetName       NVARCHAR(150)   NOT NULL,
    AssetType       NVARCHAR(50)    NOT NULL,
    IPAddress       NVARCHAR(45),
    OperatingSystem NVARCHAR(100),
    Department      NVARCHAR(100),
    Criticality     NVARCHAR(20)    NOT NULL,
    Status          NVARCHAR(20)    NOT NULL DEFAULT 'Active',
    Owner           NVARCHAR(150),
    LastScanned     DATETIME,
    RegisteredAt    DATETIME        NOT NULL DEFAULT GETDATE()
);
GO

CREATE TABLE Incidents (
    IncidentID      INT IDENTITY(1,1) PRIMARY KEY,
    Title           NVARCHAR(200)   NOT NULL,
    Description     NVARCHAR(MAX),
    Category        NVARCHAR(100)   NOT NULL,
    Severity        NVARCHAR(20)    NOT NULL,
    Status          NVARCHAR(30)    NOT NULL DEFAULT 'Open',
    AssignedTo      INT             FOREIGN KEY REFERENCES Users(UserID),
    AffectedAssetID INT             FOREIGN KEY REFERENCES Assets(AssetID),
    DetectedAt      DATETIME        NOT NULL DEFAULT GETDATE(),
    ResolvedAt      DATETIME,
    MTTD_Minutes    INT,
    MTTR_Minutes    INT,
    RootCause       NVARCHAR(MAX),
    RemediationNotes NVARCHAR(MAX)
);
GO

CREATE TABLE AccessLogs (
    LogID           INT IDENTITY(1,1) PRIMARY KEY,
    UserID          INT             NOT NULL FOREIGN KEY REFERENCES Users(UserID),
    AssetID         INT             FOREIGN KEY REFERENCES Assets(AssetID),
    EventType       NVARCHAR(50)    NOT NULL,
    EventStatus     NVARCHAR(20)    NOT NULL,
    IPAddress       NVARCHAR(45),
    Location        NVARCHAR(100),
    EventTimestamp  DATETIME        NOT NULL DEFAULT GETDATE(),
    RiskScore       INT             CHECK (RiskScore BETWEEN 0 AND 100),
    FlaggedAsSuspicious BIT         DEFAULT 0,
    Notes           NVARCHAR(500)
);
GO

CREATE TABLE Vulnerabilities (
    VulnID          INT IDENTITY(1,1) PRIMARY KEY,
    AssetID         INT             NOT NULL FOREIGN KEY REFERENCES Assets(AssetID),
    CVE_ID          NVARCHAR(20),
    Title           NVARCHAR(200)   NOT NULL,
    Description     NVARCHAR(MAX),
    Severity        NVARCHAR(20)    NOT NULL,
    CVSS_Score      DECIMAL(3,1)    CHECK (CVSS_Score BETWEEN 0.0 AND 10.0),
    Status          NVARCHAR(30)    NOT NULL DEFAULT 'Open',
    DiscoveredAt    DATETIME        NOT NULL DEFAULT GETDATE(),
    PatchedAt       DATETIME,
    RemediationNotes NVARCHAR(MAX),
    AssignedTo      INT             FOREIGN KEY REFERENCES Users(UserID)
);
GO

INSERT INTO Users (Username, FullName, Email, Department, Role, AccessLevel, AccountStatus, LastLogin) VALUES
    ('arsh.m',   'Arsh Makkar',   'arsh@omnitech.io',     'Security',   'Analyst',  'High',     'Active',    '2026-05-22 08:30:00'),
    ('j.carter', 'James Carter',  'j.carter@omnitech.io', 'IT',         'Admin',    'Critical', 'Active',    '2026-05-23 09:00:00'),
    ('s.patel',  'Simran Patel',  's.patel@omnitech.io',  'Security',   'Engineer', 'High',     'Active',    '2026-05-21 14:00:00'),
    ('t.nguyen', 'Tommy Nguyen',  't.nguyen@omnitech.io', 'HR',         'User',     'Low',      'Active',    '2026-05-20 11:00:00'),
    ('r.jones',  'Rachel Jones',  'r.jones@omnitech.io',  'Finance',    'User',     'Medium',   'Active',    '2026-05-19 10:00:00'),
    ('d.kim',    'Daniel Kim',    'd.kim@omnitech.io',    'IT',         'Engineer', 'High',     'Suspended', '2026-05-10 16:00:00'),
    ('l.torres', 'Luis Torres',   'l.torres@omnitech.io', 'Operations', 'Manager',  'Medium',   'Active',    '2026-05-22 07:45:00'),
    ('a.white',  'Amy White',     'a.white@omnitech.io',  'Security',   'Analyst',  'High',     'Active',    '2026-05-23 08:00:00');
GO

INSERT INTO Assets (AssetName, AssetType, IPAddress, OperatingSystem, Department, Criticality, Status, Owner, LastScanned) VALUES
    ('OMNI-DC-01',    'Server',         '10.0.0.1',   'Windows Server 2022', 'IT',       'Critical', 'Active',      'James Carter', '2026-05-22 02:00:00'),
    ('OMNI-WEB-01',   'Server',         '10.0.0.2',   'Ubuntu 22.04',        'IT',       'High',     'Active',      'James Carter', '2026-05-22 02:30:00'),
    ('OMNI-FW-01',    'Network Device', '10.0.0.254', 'Cisco IOS',           'IT',       'Critical', 'Active',      'James Carter', '2026-05-21 03:00:00'),
    ('ARSH-WS-01',    'Workstation',    '10.0.1.10',  'Windows 11',          'Security', 'Medium',   'Active',      'Arsh Makkar',  '2026-05-23 01:00:00'),
    ('FINANCE-WS-01', 'Workstation',    '10.0.1.20',  'Windows 11',          'Finance',  'High',     'Active',      'Rachel Jones', '2026-05-22 01:00:00'),
    ('OMNI-CLOUD-S3', 'Cloud',          NULL,         'AWS S3',              'IT',       'Critical', 'Active',      'James Carter', '2026-05-23 00:00:00'),
    ('HR-WS-01',      'Workstation',    '10.0.1.30',  'Windows 10',          'HR',       'Low',      'Active',      'Tommy Nguyen', '2026-05-20 01:00:00'),
    ('OMNI-VPN-01',   'Network Device', '10.0.0.100', 'OpenVPN',             'IT',       'High',     'Quarantined', 'James Carter', '2026-05-18 02:00:00');
GO

INSERT INTO Incidents (Title, Category, Severity, Status, AssignedTo, AffectedAssetID, DetectedAt, ResolvedAt, MTTD_Minutes, MTTR_Minutes, RootCause, RemediationNotes) VALUES
    ('Phishing Email Campaign Detected',        'Phishing',            'High',     'Resolved',    1, 4, '2026-05-10 09:00:00', '2026-05-10 13:30:00', 15,  270, 'Spoofed HR domain targeting Finance team',   'Blocked sender domain, user awareness training issued'),
    ('Malware Detected on Finance Workstation', 'Malware',             'Critical', 'Contained',   3, 5, '2026-05-15 11:00:00', NULL,                   8,   NULL,'Trojan dropped via malicious PDF attachment', 'Endpoint isolated, forensic image taken'),
    ('Unauthorized VPN Access Attempt',         'Unauthorized Access', 'High',     'Resolved',    1, 8, '2026-05-18 03:00:00', '2026-05-18 05:00:00', 5,   120, 'Brute-force against VPN from external IP',   'IP blocked at firewall, MFA enforced'),
    ('Suspicious Admin Privilege Escalation',   'Insider Threat',      'Critical', 'In Progress', 8, 1, '2026-05-20 14:00:00', NULL,                   20,  NULL,'Suspended user account accessed DC remotely','Account fully disabled, audit trail preserved'),
    ('DDoS Attack on Web Server',               'DDoS',                'Medium',   'Closed',      3, 2, '2026-05-12 16:00:00', '2026-05-12 18:00:00', 10,  120, 'UDP flood from botnet',                      'Rate limiting applied, upstream filtering enabled'),
    ('Failed Login Spike on Domain Controller', 'Unauthorized Access', 'Medium',   'Resolved',    1, 1, '2026-05-22 07:00:00', '2026-05-22 08:00:00', 3,   60,  'Password spray attack against AD accounts',  'Lockout policy tightened, alerts configured'),
    ('Cloud S3 Bucket Misconfiguration',        'Unauthorized Access', 'Critical', 'Resolved',    3, 6, '2026-05-05 10:00:00', '2026-05-05 11:30:00', 60,  90,  'Bucket set to public by misconfigured script','Bucket policy corrected, IAM audit completed'),
    ('Ransomware Indicator on HR Workstation',  'Malware',             'High',     'Open',        8, 7, '2026-05-23 06:00:00', NULL,                   5,   NULL,'Suspicious file encryption activity detected','Endpoint isolated pending analysis');
GO

INSERT INTO AccessLogs (UserID, AssetID, EventType, EventStatus, IPAddress, Location, EventTimestamp, RiskScore, FlaggedAsSuspicious, Notes) VALUES
    (1, 4, 'Login',               'Success', '10.0.1.10',     'Exton, PA',      '2026-05-23 08:30:00', 5,  0, NULL),
    (2, 1, 'Login',               'Success', '10.0.0.1',      'Exton, PA',      '2026-05-23 09:00:00', 10, 0, NULL),
    (6, 1, 'Login',               'Failed',  '185.220.101.5', 'Moscow, Russia', '2026-05-20 14:15:00', 95, 1, 'Suspended user login attempt from foreign IP'),
    (6, 1, 'Privilege Escalation','Blocked', '185.220.101.5', 'Moscow, Russia', '2026-05-20 14:17:00', 98, 1, 'Escalation blocked after failed login'),
    (4, 7, 'Login',               'Success', '10.0.1.30',     'Exton, PA',      '2026-05-23 08:45:00', 5,  0, NULL),
    (5, 5, 'File Access',         'Success', '10.0.1.20',     'Exton, PA',      '2026-05-15 10:55:00', 30, 0, 'Accessed payroll folder before malware detection'),
    (3, 6, 'Login',               'Success', '10.0.0.50',     'Exton, PA',      '2026-05-05 09:50:00', 15, 0, 'Pre-misconfiguration fix access'),
    (1, 8, 'Login',               'Failed',  '45.33.32.156',  'Unknown',        '2026-05-18 03:00:00', 88, 1, 'External brute-force on VPN'),
    (2, 1, 'Login',               'Failed',  '10.0.0.1',      'Exton, PA',      '2026-05-22 07:05:00', 40, 0, 'Password spray attempt'),
    (7, 4, 'Login',               'Success', '10.0.1.50',     'Exton, PA',      '2026-05-23 07:45:00', 5,  0, NULL);
GO

INSERT INTO Vulnerabilities (AssetID, CVE_ID, Title, Severity, CVSS_Score, Status, DiscoveredAt, PatchedAt, RemediationNotes, AssignedTo) VALUES
    (1, 'CVE-2024-21351', 'Windows SmartScreen Bypass',           'High',     7.6,  'Patched',        '2026-04-10', '2026-04-15', 'KB5034441 applied',                     2),
    (2, 'CVE-2024-3094',  'XZ Utils Supply Chain Backdoor',       'Critical', 10.0, 'Patched',        '2026-04-01', '2026-04-03', 'Downgraded to XZ 5.4.6, SSH audited',   3),
    (5, 'CVE-2024-26234', 'Microsoft Proxy Driver Spoofing',      'Medium',   6.7,  'In Remediation', '2026-05-15', NULL,         'Patch scheduled for next maintenance',   1),
    (6, NULL,             'S3 Public Access Misconfiguration',    'Critical', 9.8,  'Patched',        '2026-05-05', '2026-05-05', 'Bucket policy corrected, logging on',    3),
    (8, 'CVE-2023-46805', 'Ivanti VPN Authentication Bypass',     'Critical', 8.2,  'Open',           '2026-05-18', NULL,         'Asset quarantined pending patch',         2),
    (4, 'CVE-2024-30078', 'Windows WiFi Driver RCE',              'High',     8.8,  'Patched',        '2026-05-01', '2026-05-05', 'Windows Update KB5039213 applied',       1),
    (7, NULL,             'Endpoint Protection Outdated Signatures','Medium',  5.5,  'In Remediation', '2026-05-23', NULL,         'Forced update pushed via GPO',            8),
    (3, 'CVE-2024-20353', 'Cisco ASA Firewall DoS Vulnerability', 'High',     8.6,  'Open',           '2026-05-20', NULL,         'Vendor patch pending, monitoring active', 2);
GO
