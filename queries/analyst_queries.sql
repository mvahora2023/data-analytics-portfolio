-- ============================================================
-- OmniTech Analyst Query Library
-- Author: Mahmadarsh Vahora
-- Schema: OmniTech (9-table relational model)
-- Purpose: Business intelligence queries for operational reporting
-- ============================================================


-- ============================================================
-- Query 1: Revenue by Product Category with Running Total
-- Business Question: What is each product category's revenue
--   contribution, and what is the cumulative revenue across
--   categories ordered from highest to lowest?
-- ============================================================
WITH CategoryRevenue AS (
    SELECT
        p.Category,
        SUM(oi.Qty * oi.UnitPrice)          AS CategoryRevenue
    FROM OrderItems   oi
    JOIN Products     p  ON oi.ProductID = p.ProductID
    JOIN Orders       o  ON oi.OrderID   = o.OrderID
    WHERE o.Status NOT IN ('Cancelled')
    GROUP BY p.Category
)
SELECT
    Category,
    CAST(CategoryRevenue AS DECIMAL(12,2))                          AS CategoryRevenue,
    CAST(
        SUM(CategoryRevenue) OVER (
            ORDER BY CategoryRevenue DESC
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        )
    AS DECIMAL(12,2))                                               AS RunningTotal,
    CAST(
        100.0 * CategoryRevenue / SUM(CategoryRevenue) OVER ()
    AS DECIMAL(5,2))                                                AS PctOfTotal
FROM CategoryRevenue
ORDER BY CategoryRevenue DESC;


-- ============================================================
-- Query 2: Client Tier Distribution — Count and Percentage
-- Business Question: How are our clients distributed across
--   tier levels, and what percentage does each tier represent?
-- ============================================================
SELECT
    Tier,
    COUNT(*)                                                        AS ClientCount,
    CAST(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER ()
    AS DECIMAL(5,2))                                                AS PctOfClients
FROM Clients
GROUP BY Tier
ORDER BY
    CASE Tier
        WHEN 'Enterprise' THEN 1
        WHEN 'Gold'       THEN 2
        WHEN 'Silver'     THEN 3
        WHEN 'Bronze'     THEN 4
    END;


-- ============================================================
-- Query 3: Project On-Time Delivery Rate by Department
-- Business Question: Which departments consistently deliver
--   projects on or before the planned end date?
-- ============================================================
SELECT
    d.DeptName,
    COUNT(proj.ProjID)                                              AS TotalCompleted,
    SUM(
        CASE
            WHEN proj.EndDate >= proj.StartDate
             AND proj.Status = 'Completed'
             AND proj.EndDate <= GETDATE()
            THEN 1 ELSE 0
        END
    )                                                               AS OnTimeDeliveries,
    CAST(
        100.0 * SUM(
            CASE
                WHEN proj.Status = 'Completed'
                 AND proj.EndDate <= GETDATE()
                THEN 1 ELSE 0
            END
        ) / NULLIF(COUNT(proj.ProjID), 0)
    AS DECIMAL(5,2))                                                AS CompletionRatePct,
    CAST(
        100.0 * SUM(
            CASE
                WHEN proj.Status = 'Completed'
                 AND proj.EndDate <= GETDATE()   -- delivered on or before planned end
                THEN 1 ELSE 0
            END
        ) / NULLIF(
            SUM(CASE WHEN proj.Status = 'Completed' THEN 1 ELSE 0 END),
        0)
    AS DECIMAL(5,2))                                                AS OnTimeRatePct
FROM Departments d
JOIN Employees   e    ON e.DeptID  = d.DeptID
JOIN Projects    proj ON proj.EmpID = e.EmpID
GROUP BY d.DeptID, d.DeptName
HAVING COUNT(proj.ProjID) > 0
ORDER BY OnTimeRatePct DESC;


-- ============================================================
-- Query 4: Top 5 Products by Revenue Using RANK()
-- Business Question: Which individual products generate the
--   most revenue, and how do they rank relative to each other?
-- ============================================================
WITH ProductRevenue AS (
    SELECT
        p.ProductID,
        p.Name                                                      AS ProductName,
        p.Category,
        SUM(oi.Qty * oi.UnitPrice)                                  AS TotalRevenue,
        SUM(oi.Qty)                                                 AS UnitsSold,
        RANK() OVER (ORDER BY SUM(oi.Qty * oi.UnitPrice) DESC)      AS RevenueRank
    FROM Products    p
    JOIN OrderItems  oi ON oi.ProductID = p.ProductID
    JOIN Orders      o  ON o.OrderID    = oi.OrderID
    WHERE o.Status NOT IN ('Cancelled')
    GROUP BY p.ProductID, p.Name, p.Category
)
SELECT
    RevenueRank,
    ProductName,
    Category,
    CAST(TotalRevenue AS DECIMAL(12,2))                             AS TotalRevenue,
    UnitsSold
FROM ProductRevenue
WHERE RevenueRank <= 5
ORDER BY RevenueRank;


-- ============================================================
-- Query 5: Order Fulfillment Rate by Status
-- Business Question: What is the current distribution of
--   order statuses, and what percentage have been fulfilled?
-- ============================================================
SELECT
    Status,
    COUNT(*)                                                        AS OrderCount,
    CAST(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER ()
    AS DECIMAL(5,2))                                                AS PctOfAllOrders,
    SUM(COUNT(*)) OVER (
        ORDER BY
            CASE Status
                WHEN 'Pending'    THEN 1
                WHEN 'Processing' THEN 2
                WHEN 'Shipped'    THEN 3
                WHEN 'Delivered'  THEN 4
                WHEN 'Cancelled'  THEN 5
            END
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    )                                                               AS CumulativeOrders
FROM Orders
GROUP BY Status
ORDER BY
    CASE Status
        WHEN 'Delivered'  THEN 1
        WHEN 'Shipped'    THEN 2
        WHEN 'Processing' THEN 3
        WHEN 'Pending'    THEN 4
        WHEN 'Cancelled'  THEN 5
    END;


-- ============================================================
-- Query 6: Employee Salary Distribution by Department
-- Business Question: What are the salary statistics per
--   department — how wide is the spread and where does the
--   average sit?
-- ============================================================
SELECT
    d.DeptName,
    COUNT(e.EmpID)                                                  AS HeadCount,
    CAST(AVG(e.Salary) AS DECIMAL(10,2))                            AS AvgSalary,
    CAST(MIN(e.Salary) AS DECIMAL(10,2))                            AS MinSalary,
    CAST(MAX(e.Salary) AS DECIMAL(10,2))                            AS MaxSalary,
    CAST(MAX(e.Salary) - MIN(e.Salary) AS DECIMAL(10,2))            AS SalaryRange,
    CAST(STDEV(e.Salary) AS DECIMAL(10,2))                          AS SalaryStdDev,
    CAST(d.Budget AS DECIMAL(12,2))                                 AS DeptBudget,
    CAST(
        100.0 * SUM(e.Salary) / NULLIF(d.Budget, 0)
    AS DECIMAL(5,2))                                                AS SalaryBudgetPct
FROM Departments d
JOIN Employees   e ON e.DeptID = d.DeptID
GROUP BY d.DeptID, d.DeptName, d.Budget
ORDER BY AvgSalary DESC;


-- ============================================================
-- Query 7: Monthly Order Volume Trend
-- Business Question: How has order volume changed month over
--   month, and is there a seasonal pattern?
-- ============================================================
WITH MonthlyVolume AS (
    SELECT
        YEAR(OrderDate)                                             AS OrderYear,
        MONTH(OrderDate)                                            AS OrderMonth,
        DATENAME(MONTH, OrderDate)                                  AS MonthName,
        COUNT(*)                                                    AS OrderCount,
        CAST(SUM(oi.Qty * oi.UnitPrice) AS DECIMAL(12,2))          AS MonthRevenue
    FROM Orders     o
    JOIN OrderItems oi ON oi.OrderID = o.OrderID
    WHERE o.Status NOT IN ('Cancelled')
    GROUP BY
        YEAR(OrderDate),
        MONTH(OrderDate),
        DATENAME(MONTH, OrderDate)
)
SELECT
    OrderYear,
    OrderMonth,
    MonthName,
    OrderCount,
    MonthRevenue,
    LAG(OrderCount) OVER (ORDER BY OrderYear, OrderMonth)           AS PrevMonthOrders,
    CAST(
        100.0 * (OrderCount - LAG(OrderCount) OVER (ORDER BY OrderYear, OrderMonth))
        / NULLIF(LAG(OrderCount) OVER (ORDER BY OrderYear, OrderMonth), 0)
    AS DECIMAL(5,2))                                                AS MoMGrowthPct
FROM MonthlyVolume
ORDER BY OrderYear, OrderMonth;


-- ============================================================
-- Query 8: Client Lifetime Value — Total Order Spend
-- Business Question: What is each client's total historical
--   spend, and how does it correlate with their tier?
-- ============================================================
WITH ClientSpend AS (
    SELECT
        c.ClientID,
        c.Name                                                      AS ClientName,
        c.Tier,
        COUNT(DISTINCT o.OrderID)                                   AS TotalOrders,
        CAST(SUM(oi.Qty * oi.UnitPrice) AS DECIMAL(12,2))          AS LifetimeValue,
        MIN(o.OrderDate)                                            AS FirstOrderDate,
        MAX(o.OrderDate)                                            AS LastOrderDate,
        DATEDIFF(DAY, MIN(o.OrderDate), MAX(o.OrderDate))          AS CustomerAgeDays
    FROM Clients    c
    JOIN Orders     o  ON o.ClientID   = c.ClientID
    JOIN OrderItems oi ON oi.OrderID   = o.OrderID
    WHERE o.Status NOT IN ('Cancelled')
    GROUP BY c.ClientID, c.Name, c.Tier
)
SELECT
    ClientName,
    Tier,
    TotalOrders,
    LifetimeValue,
    CAST(
        LifetimeValue / NULLIF(TotalOrders, 0)
    AS DECIMAL(10,2))                                               AS AvgOrderValue,
    FirstOrderDate,
    LastOrderDate,
    CustomerAgeDays,
    RANK() OVER (ORDER BY LifetimeValue DESC)                       AS LTVRank
FROM ClientSpend
ORDER BY LifetimeValue DESC;
