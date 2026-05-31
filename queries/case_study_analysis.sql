-- ============================================================
-- CorpDB Analytics Case Study
-- Author: Mahmadarsh Vahora
-- Purpose: Answer 4 business questions for annual planning
-- Date: 2026-05-30
--
-- Business Questions:
--   Q1. Which product category drives the most revenue?
--   Q2. Which client tier has the best order frequency?
--   Q3. What is the seasonal order pattern across the year?
--   Q4. Which department has the highest project delivery rate?
-- ============================================================


-- ============================================================
-- Q1: Which Product Category Drives the Most Revenue?
--
-- Hypothesis: Categories are not equal contributors — one or
-- two likely drive the majority of revenue (Pareto principle).
-- We calculate revenue, units sold, and average unit price
-- per category to understand both volume and value drivers.
-- ============================================================
WITH CategoryMetrics AS (
    SELECT
        p.Category,
        COUNT(DISTINCT o.OrderID)                                   AS OrderCount,
        SUM(oi.Qty)                                                 AS UnitsSold,
        SUM(oi.Qty * oi.UnitPrice)                                  AS TotalRevenue,
        AVG(oi.UnitPrice)                                           AS AvgUnitPrice
    FROM Products    p
    JOIN OrderItems  oi ON oi.ProductID = p.ProductID
    JOIN Orders      o  ON o.OrderID    = oi.OrderID
    WHERE o.Status NOT IN ('Cancelled')
    GROUP BY p.Category
)
SELECT
    Category,
    OrderCount,
    UnitsSold,
    CAST(TotalRevenue  AS DECIMAL(12,2))                            AS TotalRevenue,
    CAST(AvgUnitPrice  AS DECIMAL(10,2))                            AS AvgUnitPrice,
    -- Revenue share shows concentration
    CAST(
        100.0 * TotalRevenue / SUM(TotalRevenue) OVER ()
    AS DECIMAL(5,2))                                                AS RevenuePct,
    RANK() OVER (ORDER BY TotalRevenue DESC)                        AS RevenueRank
FROM CategoryMetrics
ORDER BY TotalRevenue DESC;


-- ============================================================
-- Q2: Which Client Tier Has the Best Order Frequency?
--
-- Order frequency = average orders per client within a tier.
-- This reveals whether premium tiers (Gold, Enterprise) are
-- actually purchasing more often, which would validate the
-- tier strategy. A high-revenue tier with low frequency
-- suggests large but infrequent deals — different risk profile.
-- ============================================================
WITH TierOrderStats AS (
    SELECT
        c.Tier,
        c.ClientID,
        COUNT(o.OrderID)                                            AS OrdersPerClient
    FROM Clients c
    LEFT JOIN Orders o ON o.ClientID = c.ClientID
                      AND o.Status NOT IN ('Cancelled')
    GROUP BY c.Tier, c.ClientID
)
SELECT
    Tier,
    COUNT(ClientID)                                                 AS ClientCount,
    SUM(OrdersPerClient)                                            AS TotalOrders,
    CAST(AVG(CAST(OrdersPerClient AS FLOAT)) AS DECIMAL(5,2))      AS AvgOrdersPerClient,
    MAX(OrdersPerClient)                                            AS MaxOrdersPerClient,
    MIN(OrdersPerClient)                                            AS MinOrdersPerClient,
    -- Frequency index: normalized to the highest-performing tier
    CAST(
        100.0 * AVG(CAST(OrdersPerClient AS FLOAT))
        / NULLIF(MAX(AVG(CAST(OrdersPerClient AS FLOAT))) OVER (), 0)
    AS DECIMAL(5,2))                                                AS FrequencyIndexPct
FROM TierOrderStats
GROUP BY Tier
ORDER BY AvgOrdersPerClient DESC;


-- ============================================================
-- Q3: What Is the Seasonal Order Pattern Across the Year?
--
-- We look at order count and revenue by month to identify
-- seasonal spikes or lulls. A consistent pattern allows the
-- business to align staffing, inventory, and marketing spend
-- with actual demand cycles rather than assumptions.
-- ============================================================
WITH MonthlyOrders AS (
    SELECT
        YEAR(o.OrderDate)                                           AS OrderYear,
        MONTH(o.OrderDate)                                          AS OrderMonth,
        DATENAME(MONTH, o.OrderDate)                                AS MonthName,
        COUNT(DISTINCT o.OrderID)                                   AS OrderCount,
        SUM(oi.Qty * oi.UnitPrice)                                  AS MonthRevenue
    FROM Orders     o
    JOIN OrderItems oi ON oi.OrderID = o.OrderID
    WHERE o.Status NOT IN ('Cancelled')
    GROUP BY
        YEAR(o.OrderDate),
        MONTH(o.OrderDate),
        DATENAME(MONTH, o.OrderDate)
),
MonthlyWithAvg AS (
    SELECT
        OrderYear,
        OrderMonth,
        MonthName,
        OrderCount,
        CAST(MonthRevenue AS DECIMAL(12,2))                         AS MonthRevenue,
        -- Annual average for comparison
        AVG(OrderCount) OVER (PARTITION BY OrderYear)               AS AvgMonthlyOrders,
        AVG(MonthRevenue) OVER (PARTITION BY OrderYear)             AS AvgMonthlyRevenue
    FROM MonthlyOrders
)
SELECT
    OrderYear,
    OrderMonth,
    MonthName,
    OrderCount,
    MonthRevenue,
    -- Index above/below average: 100 = exactly average, >100 = peak month
    CAST(
        100.0 * OrderCount / NULLIF(AvgMonthlyOrders, 0)
    AS DECIMAL(5,1))                                                AS SeasonalityIndex,
    LAG(OrderCount) OVER (
        PARTITION BY OrderYear ORDER BY OrderMonth
    )                                                               AS PrevMonthOrders
FROM MonthlyWithAvg
ORDER BY OrderYear, OrderMonth;


-- ============================================================
-- Q4: Which Department Has the Highest Project Delivery Rate?
--
-- Delivery rate = completed projects / all closed projects
-- (Completed + Cancelled). "Cancelled" projects failed to
-- deliver. We also calculate average project duration for
-- completed projects to understand delivery speed.
-- ============================================================
WITH DeptProjectStats AS (
    SELECT
        d.DeptID,
        d.DeptName,
        COUNT(proj.ProjID)                                          AS TotalProjects,
        SUM(CASE WHEN proj.Status = 'Completed'  THEN 1 ELSE 0 END) AS Completed,
        SUM(CASE WHEN proj.Status = 'Active'     THEN 1 ELSE 0 END) AS Active,
        SUM(CASE WHEN proj.Status = 'On Hold'    THEN 1 ELSE 0 END) AS OnHold,
        SUM(CASE WHEN proj.Status = 'Cancelled'  THEN 1 ELSE 0 END) AS Cancelled,
        -- Average duration for completed projects only
        AVG(
            CASE
                WHEN proj.Status = 'Completed'
                THEN DATEDIFF(DAY, proj.StartDate, proj.EndDate)
            END
        )                                                           AS AvgCompletedDays
    FROM Departments d
    JOIN Employees   e    ON e.DeptID   = d.DeptID
    JOIN Projects    proj ON proj.EmpID = e.EmpID
    GROUP BY d.DeptID, d.DeptName
)
SELECT
    DeptName,
    TotalProjects,
    Completed,
    Active,
    OnHold,
    Cancelled,
    AvgCompletedDays,
    -- Delivery rate: completed vs. all closed (completed + cancelled)
    CAST(
        100.0 * Completed / NULLIF(Completed + Cancelled, 0)
    AS DECIMAL(5,2))                                                AS DeliveryRatePct,
    -- Overall completion rate vs all projects
    CAST(
        100.0 * Completed / NULLIF(TotalProjects, 0)
    AS DECIMAL(5,2))                                                AS CompletionRatePct
FROM DeptProjectStats
WHERE TotalProjects > 0
ORDER BY DeliveryRatePct DESC;

