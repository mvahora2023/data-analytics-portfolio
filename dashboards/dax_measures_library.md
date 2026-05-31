# DAX Measures Library — OmniTech Power BI Dashboard

All measures are defined in the `_Measures` table and prefixed by domain for easy navigation in the Fields pane.

---

## 1. Revenue YTD

```dax
Revenue YTD =
CALCULATE(
    SUMX(
        OrderItems,
        OrderItems[Qty] * OrderItems[UnitPrice]
    ),
    DATESYTD( Orders[OrderDate] ),
    Orders[Status] <> "Cancelled"
)
```

**Description:** Calculates cumulative revenue from January 1 of the current year through the date in the current filter context. Uses `SUMX` as an iterator to multiply Qty × UnitPrice row by row (avoids pre-aggregation errors). Cancelled orders are excluded via an explicit filter argument to `CALCULATE`. Responds dynamically to date slicers — selecting March shows Jan–Mar YTD.

---

## 2. Revenue Growth % MoM

```dax
Revenue Growth % MoM =
VAR CurrentMonthRevenue =
    CALCULATE(
        SUMX( OrderItems, OrderItems[Qty] * OrderItems[UnitPrice] ),
        Orders[Status] <> "Cancelled"
    )
VAR PriorMonthRevenue =
    CALCULATE(
        SUMX( OrderItems, OrderItems[Qty] * OrderItems[UnitPrice] ),
        DATEADD( Orders[OrderDate], -1, MONTH ),
        Orders[Status] <> "Cancelled"
    )
RETURN
    DIVIDE(
        CurrentMonthRevenue - PriorMonthRevenue,
        PriorMonthRevenue,
        BLANK()
    )
```

**Description:** Computes month-over-month revenue growth as a percentage. Uses two VAR blocks for readability. `DATEADD(..., -1, MONTH)` shifts the filter context back exactly one month. `DIVIDE` is used instead of the `/` operator to return BLANK (not an error) when prior month revenue is zero — prevents divide-by-zero on the first data month. Format as percentage in the visual.

---

## 3. On-Time Delivery %

```dax
On-Time Delivery % =
DIVIDE(
    CALCULATE(
        COUNTROWS( Projects ),
        Projects[Status] = "Completed",
        Projects[EndDate] <= TODAY()
    ),
    CALCULATE(
        COUNTROWS( Projects ),
        Projects[Status] = "Completed"
    ),
    BLANK()
)
```

**Description:** Measures the percentage of completed projects that were delivered on or before their planned end date. The numerator counts completed projects where `EndDate` has already passed (i.e., delivered on schedule or early). The denominator counts all completed projects. Filter context from slicers (department, date range) flows through both CALCULATE calls, making this measure work correctly in a department matrix. Format as percentage.

---

## 4. Average Order Value

```dax
Average Order Value =
DIVIDE(
    SUMX(
        OrderItems,
        OrderItems[Qty] * OrderItems[UnitPrice]
    ),
    DISTINCTCOUNT( Orders[OrderID] ),
    BLANK()
)
```

**Description:** Calculates the mean revenue per order. Revenue is computed via SUMX at the line-item level; the denominator uses `DISTINCTCOUNT` on `OrderID` rather than `COUNTROWS(Orders)` to handle the one-to-many relationship correctly — counting from the OrderItems table would overcount orders with multiple products. DIVIDE returns BLANK when there are no orders in the filter context rather than an error.

---

## 5. Client Churn Rate

```dax
Client Churn Rate =
VAR ActiveClients =
    CALCULATE(
        DISTINCTCOUNT( Orders[ClientID] ),
        Orders[OrderDate] >= DATEADD( TODAY(), -12, MONTH )
    )
VAR TotalClients = DISTINCTCOUNT( Clients[ClientID] )
RETURN
    DIVIDE(
        TotalClients - ActiveClients,
        TotalClients,
        BLANK()
    )
```

**Description:** Approximates churn as the proportion of clients who have not placed an order in the past 12 months. Active clients are those with at least one order in the trailing 12-month window. This is a behavioral definition of churn (no recent purchase), not a contractual one. The measure is an approximation suitable for trend monitoring; a precise churn model would require explicit churn event data. Useful as a KPI card on the Client Analysis page.

---

## 6. Product Margin %

```dax
Product Margin % =
VAR Revenue =
    SUMX( OrderItems, OrderItems[Qty] * OrderItems[UnitPrice] )
VAR Cost =
    SUMX(
        OrderItems,
        OrderItems[Qty] * RELATED( Products[Price] )
    )
RETURN
    DIVIDE( Revenue - Cost, Revenue, BLANK() )
```

**Description:** Calculates gross margin percentage as `(Revenue - Cost) / Revenue`. Uses the catalog `Products[Price]` as a proxy for cost basis when actual cost data is not available — in this schema, `Products[Price]` represents the list price used in cost calculations. `RELATED` navigates the relationship from OrderItems to Products to fetch the product's base price. In a production environment, a separate cost column would replace `Products[Price]`. Format as percentage.

---

## 7. Employee Headcount by Dept

```dax
Employee Headcount =
CALCULATE(
    COUNTROWS( Employees ),
    ALL( Employees[Title] )
)
```

**Description:** Counts the number of employees in the current filter context (typically a department slicer or matrix row). `ALL( Employees[Title] )` removes any Title filter that might be applied via a slicer, ensuring the headcount reflects the full department population regardless of title filters active in the report. Used in the HR Snapshot page as both a standalone card and as a matrix column alongside average salary. Returns the correct total when used in a bar chart sliced by department.

---

## 8. Order Fulfillment Rate

```dax
Order Fulfillment Rate =
DIVIDE(
    CALCULATE(
        COUNTROWS( Orders ),
        Orders[Status] = "Delivered"
    ),
    CALCULATE(
        COUNTROWS( Orders ),
        Orders[Status] <> "Cancelled"
    ),
    BLANK()
)
```

**Description:** Measures the proportion of non-cancelled orders that have reached "Delivered" status. The denominator explicitly excludes cancelled orders because a cancelled order was never intended for fulfillment — including it would deflate the rate in a misleading way. Responds to date range slicers to show fulfillment rate over time periods. Target threshold for the gauge visual is set to 0.85 (85%), representing the operational SLA. Format as percentage.
