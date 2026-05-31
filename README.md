# data-analytics-portfolio

![License](https://img.shields.io/github/license/mvahora2023/data-analytics-portfolio)
![Last Commit](https://img.shields.io/github/last-commit/mvahora2023/data-analytics-portfolio)
![SQL Server](https://img.shields.io/badge/SQL%20Server-T--SQL-CC2927?logo=microsoftsqlserver&logoColor=white)
![Power BI](https://img.shields.io/badge/Power%20BI-DAX-F2C811?logo=powerbi&logoColor=black)
![Google Data Analytics](https://img.shields.io/badge/Google-Data%20Analytics%20Cert-4285F4?logo=google&logoColor=white)

SQL schema design, T-SQL query library, Power BI DAX measures, and business intelligence case studies built on Microsoft SQL Server. Demonstrates end-to-end analytics capability: from schema design through dashboard delivery.

---

## Projects

### Corporate Operations Database
A 9-table normalized SQL Server schema modeling a fictional enterprise: Departments, Employees, Clients (tier-classified), Products, Projects, Orders, and Order Items. Designed with `CHECK` constraints for data quality enforcement, `IDENTITY` primary keys, explicit `FOREIGN KEY` references, and `DECIMAL(10,2)` for all monetary values.

### SafeOps Security Operations Database
A SQL schema for security operations data: service management events, audit log entries, and operational metrics. Demonstrates applying relational database design to security tooling — transforming flat log output into a queryable, reportable dataset.

---

## Repository Structure

```
data-analytics-portfolio/
├── schema/
│   ├── enterprise_operations_db.sql  — Full 9-table DDL with constraints and relationships
│   ├── safeops_toolkit_db.sql        — Security operations schema
│   └── SafeOps_Toolkit.sql           — SafeOps schema variant
├── queries/
│   ├── analyst_queries.sql           — 8 T-SQL analyst queries with window functions
│   ├── case_study_analysis.sql       — Business case study: 4 queries answering real questions
│   ├── schema_design_decisions.md    — 5 documented design decisions with rationale
│   └── findings_report.md            — Structured analysis findings and recommendations
└── dashboards/
    └── dax_measures_library.md       — 8 DAX measures with code and descriptions
```

---

## Schema Design Highlights

| Decision | Implementation | Why |
|---|---|---|
| Status validation | `CHECK` constraints on all status columns | Rejects invalid data at the database layer — not in application code |
| Monetary precision | `DECIMAL(10,2)` on all price/salary columns | Eliminates floating-point errors in financial calculations |
| Primary keys | `IDENTITY` on all tables | No natural key assumptions that break under real data |
| Referential integrity | Explicit `REFERENCES` on all foreign keys | Enforced consistency, not assumed |
| Domain separation | Separate databases for operations vs. security | Mirrors enterprise data classification and access control principles |

---

## Query Library

`analyst_queries.sql` includes:
- Revenue by product category with running total (`OVER (ORDER BY ...)`)
- Client tier distribution with percentage (`COUNT` + window)
- Project on-time delivery rate by department
- Top 5 products by revenue using `RANK()`
- Order fulfillment rate by status
- Employee salary distribution (`AVG` / `MIN` / `MAX` by department)
- Monthly order volume trend
- Client lifetime value (total order aggregation)

---

## DAX Measures

`dashboards/dax_measures_library.md` includes 8 complete measures:
`Revenue YTD` · `Revenue Growth % MoM` · `On-Time Delivery %` · `Average Order Value` · `Client Churn Rate` · `Product Margin %` · `Employee Headcount by Department` · `Order Fulfillment Rate`

---

## Certifications

This work applies methodology from the **Google Data Analytics Certificate** — specifically the six-phase analysis framework (Ask / Prepare / Process / Analyze / Share / Act) mapped to real schema design decisions and dashboard outputs.

---

## License

[MIT](LICENSE) — see the LICENSE file for details.
