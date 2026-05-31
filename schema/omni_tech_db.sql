-- ============================================================
-- OmniTech Database
-- ============================================================
USE master;
GO

IF EXISTS (SELECT name FROM sys.databases WHERE name = 'OmniTech')
    DROP DATABASE OmniTech;
GO

CREATE DATABASE OmniTech;
GO
USE OmniTech;
GO

-- --------------------------------------------------------
-- Tables
-- --------------------------------------------------------

CREATE TABLE Departments (
    DepartmentID   INT PRIMARY KEY IDENTITY,
    Name           NVARCHAR(100) NOT NULL,
    Budget         DECIMAL(12,2)
);

CREATE TABLE Employees (
    EmployeeID     INT PRIMARY KEY IDENTITY,
    FirstName      NVARCHAR(50) NOT NULL,
    LastName       NVARCHAR(50) NOT NULL,
    Email          NVARCHAR(100),
    DepartmentID   INT REFERENCES Departments(DepartmentID),
    Title          NVARCHAR(100),
    Salary         DECIMAL(10,2),
    HireDate       DATE
);

CREATE TABLE Clients (
    ClientID       INT PRIMARY KEY IDENTITY,
    CompanyName    NVARCHAR(150) NOT NULL,
    ContactName    NVARCHAR(100),
    Email          NVARCHAR(100),
    Phone          NVARCHAR(30),
    Country        NVARCHAR(80),
    Tier           NVARCHAR(20) CHECK (Tier IN ('Bronze','Silver','Gold','Enterprise')) DEFAULT 'Bronze'
);

CREATE TABLE Products (
    ProductID      INT PRIMARY KEY IDENTITY,
    Name           NVARCHAR(150) NOT NULL,
    Category       NVARCHAR(80),
    Description    NVARCHAR(MAX),
    UnitPrice      DECIMAL(10,2),
    StockQty       INT DEFAULT 0,
    Active         BIT DEFAULT 1
);

CREATE TABLE Projects (
    ProjectID      INT PRIMARY KEY IDENTITY,
    Name           NVARCHAR(150) NOT NULL,
    ClientID       INT REFERENCES Clients(ClientID),
    OwnerID        INT REFERENCES Employees(EmployeeID),
    Status         NVARCHAR(30) CHECK (Status IN ('Scoping','Active','On Hold','Completed','Cancelled')) DEFAULT 'Scoping',
    StartDate      DATE,
    EndDate        DATE,
    Budget         DECIMAL(12,2),
    ActualCost     DECIMAL(12,2)
);

CREATE TABLE Orders (
    OrderID        INT PRIMARY KEY IDENTITY,
    ClientID       INT REFERENCES Clients(ClientID),
    OrderDate      DATE NOT NULL,
    Status         NVARCHAR(30) CHECK (Status IN ('Pending','Processing','Shipped','Delivered','Cancelled')) DEFAULT 'Pending',
    TotalAmount    DECIMAL(12,2)
);

CREATE TABLE OrderItems (
    ItemID         INT PRIMARY KEY IDENTITY,
    OrderID        INT REFERENCES Orders(OrderID),
    ProductID      INT REFERENCES Products(ProductID),
    Quantity       INT NOT NULL,
    UnitPrice      DECIMAL(10,2) NOT NULL
);

CREATE TABLE SupportTickets (
    TicketID       INT PRIMARY KEY IDENTITY,
    ClientID       INT REFERENCES Clients(ClientID),
    AssignedTo     INT REFERENCES Employees(EmployeeID),
    Subject        NVARCHAR(200),
    Priority       NVARCHAR(20) CHECK (Priority IN ('Low','Medium','High','Urgent')) DEFAULT 'Medium',
    Status         NVARCHAR(30) CHECK (Status IN ('Open','In Progress','Pending Client','Resolved','Closed')) DEFAULT 'Open',
    CreatedDate    DATETIME DEFAULT GETDATE(),
    ResolvedDate   DATETIME
);

-- --------------------------------------------------------
-- Sample Data
-- --------------------------------------------------------

INSERT INTO Departments (Name, Budget) VALUES
('Engineering',         850000.00),
('Sales',               420000.00),
('Product Management',  300000.00),
('Customer Success',    260000.00),
('IT Operations',       380000.00);

INSERT INTO Employees (FirstName, LastName, Email, DepartmentID, Title, Salary, HireDate) VALUES
('Marcus',  'Reid',     'm.reid@omnitech.io',     1, 'VP of Engineering',        145000.00, '2017-05-10'),
('Chloe',   'Evans',    'c.evans@omnitech.io',    2, 'Sales Director',           130000.00, '2018-08-15'),
('Noah',    'Torres',   'n.torres@omnitech.io',   3, 'Product Manager',          115000.00, '2019-03-01'),
('Fatima',  'Ali',      'f.ali@omnitech.io',      4, 'Customer Success Manager', 105000.00, '2020-01-20'),
('Liam',    'Chen',     'l.chen@omnitech.io',     1, 'Senior Engineer',          125000.00, '2019-07-22'),
('Grace',   'Park',     'g.park@omnitech.io',     5, 'IT Ops Lead',              110000.00, '2020-11-03'),
('Oscar',   'Brown',    'o.brown@omnitech.io',    2, 'Account Executive',         90000.00, '2021-06-14'),
('Nia',     'James',    'n.james@omnitech.io',    4, 'Support Specialist',        80000.00, '2022-02-28'),
('Ethan',   'Liu',      'e.liu@omnitech.io',      1, 'Backend Engineer',         118000.00, '2021-09-06'),
('Sofia',   'Martins',  's.martins@omnitech.io',  3, 'UX Designer',               95000.00, '2022-07-11');

INSERT INTO Clients (CompanyName, ContactName, Email, Phone, Country, Tier) VALUES
('Apex Logistics',      'Daniel Fry',       'd.fry@apexlogistics.com',      '+1-555-0101', 'USA',          'Enterprise'),
('Vertix Solutions',    'Hannah Cole',      'h.cole@vertix.io',             '+1-555-0202', 'USA',          'Gold'),
('Nordic Systems',      'Erik Svensson',    'e.svensson@nordicsys.se',      '+46-70-123456','Sweden',      'Silver'),
('Brightpath Inc.',     'Tara Singh',       't.singh@brightpath.ca',        '+1-416-555-9900','Canada',    'Gold'),
('Dune Analytics',      'Carlos Reyes',     'c.reyes@duneanalytics.mx',     '+52-55-5551234','Mexico',     'Bronze'),
('Horizon Retail',      'Jenny Wu',         'j.wu@horizonretail.com',       '+1-555-0303', 'USA',          'Enterprise'),
('Kapstone Media',      'Benji Okafor',     'b.okafor@kapstone.ng',         '+234-801-000111','Nigeria',   'Silver'),
('CloudPeak Tech',      'Iris Yamamoto',    'i.yamamoto@cloudpeak.jp',      '+81-3-5555-0808','Japan',     'Gold');

INSERT INTO Products (Name, Category, Description, UnitPrice, StockQty) VALUES
('OmniCore Platform',       'Software',     'Core enterprise SaaS platform',                4999.00,  999),
('DataSync Pro',            'Software',     'Real-time data integration tool',              1499.00,  999),
('SecureVault Module',      'Add-on',       'Encrypted storage and access control module',   799.00,  999),
('Analytics Dashboard',     'Add-on',       'Interactive BI dashboard add-on',               599.00,  999),
('OmniSupport 24/7',        'Service',      'Round-the-clock premium support plan',         2400.00,  999),
('Implementation Package',  'Service',      'Onboarding and deployment service',            5500.00,  999),
('Training Bundle',         'Service',      '10-session staff training package',            1200.00,  999),
('API Access Tier 2',       'Add-on',       'Extended API rate limits and webhooks',         399.00,  999);

INSERT INTO Projects (Name, ClientID, OwnerID, Status, StartDate, EndDate, Budget, ActualCost) VALUES
('Apex Platform Migration',     1, 1, 'Active',      '2026-01-10', '2026-06-30', 120000.00, 54000.00),
('Vertix Analytics Rollout',    2, 3, 'Active',      '2026-02-01', '2026-05-31',  60000.00, 28000.00),
('Nordic API Integration',      3, 5, 'Completed',   '2025-10-01', '2026-01-31',  45000.00, 43500.00),
('Brightpath Onboarding',       4, 3, 'Completed',   '2025-11-15', '2026-02-28',  30000.00, 29800.00),
('Horizon Retail Full Deploy',  6, 1, 'Active',      '2026-03-01', '2026-09-30', 200000.00, 62000.00),
('Dune Analytics POC',          5, 9, 'On Hold',     '2026-04-01', '2026-07-01',  20000.00,  4500.00),
('CloudPeak SaaS Setup',        8, 5, 'Scoping',     '2026-05-01', '2026-08-31',  75000.00,     0.00);

INSERT INTO Orders (ClientID, OrderDate, Status, TotalAmount) VALUES
(1, '2026-01-05', 'Delivered',   11797.00),
(2, '2026-01-18', 'Delivered',    7197.00),
(3, '2026-02-03', 'Delivered',    6698.00),
(4, '2026-02-20', 'Delivered',    8099.00),
(6, '2026-03-01', 'Delivered',   13898.00),
(1, '2026-03-15', 'Processing',   4999.00),
(5, '2026-04-02', 'Pending',      1499.00),
(8, '2026-04-22', 'Processing',  10498.00),
(7, '2026-05-05', 'Pending',      3198.00);

INSERT INTO OrderItems (OrderID, ProductID, Quantity, UnitPrice) VALUES
(1, 1, 1, 4999.00), (1, 3, 1,  799.00), (1, 5, 1, 2400.00), (1, 6, 1, 3599.00),
(2, 1, 1, 4999.00), (2, 4, 1,  599.00), (2, 7, 1, 1200.00), (2, 8, 1,  399.00),
(3, 2, 1, 1499.00), (3, 3, 1,  799.00), (3, 8, 2,  399.00), (3, 6, 1, 3601.00),
(4, 1, 1, 4999.00), (4, 5, 1, 2400.00), (4, 4, 1,  599.00),
(5, 1, 1, 4999.00), (5, 2, 1, 1499.00), (5, 5, 1, 2400.00), (5, 6, 1, 5000.00),
(6, 1, 1, 4999.00),
(7, 2, 1, 1499.00),
(8, 1, 1, 4999.00), (8, 3, 1,  799.00), (8, 5, 1, 2400.00), (8, 7, 1, 1200.00), (8, 8, 1, 399.00), (8, 4, 1, 599.00),
(9, 2, 1, 1499.00), (9, 4, 1,  599.00), (9, 8, 1,  399.00), (9, 7, 1,  700.00);

INSERT INTO SupportTickets (ClientID, AssignedTo, Subject, Priority, Status, CreatedDate, ResolvedDate) VALUES
(1, 8, 'API timeout on bulk import',            'High',   'Resolved',     '2026-01-20', '2026-01-22'),
(2, 8, 'Dashboard not loading for some users',  'Medium', 'Resolved',     '2026-02-05', '2026-02-07'),
(3, 4, 'SSO configuration assistance needed',   'Medium', 'Closed',       '2026-02-14', '2026-02-16'),
(6, 8, 'Data export feature returning errors',  'High',   'In Progress',  '2026-03-10', NULL),
(4, 4, 'Billing invoice discrepancy',           'Low',    'Resolved',     '2026-03-25', '2026-03-26'),
(1, 8, 'Performance degradation on reports',    'Urgent', 'In Progress',  '2026-04-08', NULL),
(8, 4, 'New user onboarding walkthrough',       'Low',    'Open',         '2026-04-30', NULL),
(5, 8, 'Cannot connect DataSync to source DB',  'High',   'Open',         '2026-05-10', NULL);
GO
