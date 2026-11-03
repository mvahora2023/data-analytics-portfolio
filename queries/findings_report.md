# Corporate Operations Demo: Reproducible Findings (November 2026 revision)

**Analyst:** Mahmadarsh Vahora  
**Nature:** Self-directed SQL/data-analysis portfolio using **fictional** company, people, clients, transactions and results  
**Evidence:** [eight-table T-SQL schema and seed data](../schema/enterprise_operations_db.sql), [analysis query library](analyst_queries.sql), [case study queries](case_study_analysis.sql)

> These results were recomputed arithmetically from the checked-in SQL `INSERT` rows. They are **not** results of an actual deployed SQL Server instance, audited financial records or current business operations. Any live SQL execution and Power BI visualization must be verified separately.

## Verified dataset scope

| Measure | In the checked-in sample |
| --- | ---: |
| Relational tables | 8 |
| Departments | 5 |
| Employees | 10 |
| Clients | 8 |
| Products | 8 |
| Projects | 7 |
| Orders | 9 |
| Order line items | 31 |
| Support tickets | 8 |
| Order dates | January–May 2026 |
| Delivered / Processing / Pending orders | 5 / 2 / 2 |

The schema now refuses to destroy an existing database and includes a final update that reconciles order header totals with the sum of item rows. Four original sample order headers differ from their item totals before reconciliation. Values below use **line items** as the source of truth.

## Finding 1: Order values by product category

The numbers below are synthetic order-line amounts, **not audited or recognized revenue**. The 'Delivered' column covers only orders marked `Delivered` in the seed data.

| Category | All order line amounts | Delivered order amounts |
| --- | ---: | ---: |
| Software | $35,990.00 | $22,994.00 |
| Service | $24,900.00 | $20,600.00 |
| Add-on | $6,788.00 | $3,993.00 |
| **Total** | **$67,678.00** | **$47,587.00** |

**Supported observation:** Software is the largest category in both groupings. We cannot conclude it has the highest margin because the schema contains no cost-of-goods measurements.

## Finding 2: Client tiers and order activity

The nine example orders are associated with client tiers as follows:

| Tier | Order count |
| --- | ---: |
| Enterprise | 3 |
| Gold | 3 |
| Silver | 2 |
| Bronze | 1 |

This **does not prove** that changing a client to a higher tier causes additional purchases. The demonstration has too few clients and orders for that conclusion. A proper study would compare order frequency per client over comparable observation periods.

## Finding 3: Monthly order sample is not sufficient for seasonality

| Month in 2026 | Order count |
| --- | ---: |
| January | 2 |
| February | 2 |
| March | 2 |
| April | 2 |
| May | 1 |

There are **no Q4 records**. Therefore, the previous report's claim of a consistent October–December peak was unsupported and has been withdrawn. Seasonal effects require several years of comparable data and an explicit method for incomplete observation periods.

## Finding 4: Project delivery metrics

Two projects are labeled `Completed`; both now include an actual `CompletedDate` distinct from the planned `EndDate`:

- **Nordic API Integration:** January 28, 2026 actual vs. January 31 planned, on time.
- **Brightpath Onboarding:** March 5, 2026 actual vs. February 28 planned, late.

Only **one of the two** completed projects is on time in this sample. A two-project denominator is not sufficient to rank teams or generalize business performance.

## Practical analysis recommendations

1. Execute the T-SQL schema in a **fresh, disposable SQL Server database** and verify the statements, constraints, row counts and analytical queries before treating SQL runtime validation as complete.
2. Add durable test fixtures that reconcile order headers to details and reject inconsistent input data earlier in the ingestion process.
3. Introduce cost, discount, refund and tax columns before using words such as *revenue*, *profit*, or *margin* in external reporting.
4. Add more months and years of representative example transactions before conducting trend or seasonality analyses.
5. Add clearly documented report exports or Power BI files if claiming a finished, interactive Power BI dashboard.

## Historical report correction

The prior version of this document described **seven tables**, a Q4 demand spike, category margins and department performance differences that could not be reproduced from the committed seed data. This revision replaces those claims with limited, checkable observations. The Git history retains the original for review.
