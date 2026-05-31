# Data Analytics Portfolio

SQL schema design, T-SQL query library, DAX measures, and business intelligence case studies built on Microsoft SQL Server and Power BI.

## Projects

### OmniTech Business Operations Database
A 9-table normalized SQL Server schema modeling a fictional enterprise: Departments, Employees, Clients (with tier classification), Products, Projects, Orders, and Order Items. Designed with `CHECK` constraints, `IDENTITY` primary keys, explicit `FOREIGN KEY` references, and `DECIMAL(10,2)` for all monetary values.

### SafeOps Security Operations Database
A SQL schema purpose-built for security operations data: service management events, audit log entries, and operational metrics. Demonstrates applying relational database design principles to security tooling.

## Contents

```
schema/
  omni_tech_db.sql          — Full OmniTech DDL (9 tables, constraints, relationships)
  safeops_toolkit_db.sql    — SafeOps security operations schema
  SafeOps_Toolkit.sql       — SafeOps alternate schema variant

queries/
  analyst_queries.sql       — 8 T-SQL analyst queries (window functions, aggregations)
  case_study_analysis.sql   — Business case study: 4 queries answering real business questions
  schema_design_decisions.md — 5 documented schema design decisions with rationale
  findings_report.md        — Structured analysis findings and business recommendations

dashboards/
  dax_measures_library.md   — 8 DAX measures with code: Revenue YTD, On-Time Delivery %, AOV, etc.
```

## Key Skills Demonstrated

- T-SQL DDL: `CREATE TABLE`, `CHECK`, `IDENTITY`, `REFERENCES`, `DECIMAL` precision
- SQL analysis: window functions (`RANK()`, `ROW_NUMBER()`), CTEs, aggregations
- Data governance: domain separation, constraint-enforced data quality, reproducible schemas
- Power BI: DAX measures, dashboard design for executive and operational audiences

## Certifications

Google Data Analytics Certificate — validates the analytical methodology applied throughout this work.

---

*Technologies: Microsoft SQL Server, T-SQL, Power BI Desktop, DAX*
