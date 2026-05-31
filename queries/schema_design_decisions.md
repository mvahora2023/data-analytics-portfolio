# OmniTech Schema Design Decisions

## Purpose

This document explains five key architectural decisions made in the OmniTech relational database schema. Each decision involves a real trade-off, and the reasoning behind each choice reflects how the schema will be used — primarily for analytical querying, not just transactional CRUD.

---

## Decision 1: IDENTITY Primary Keys Over Natural Keys

**Choice:** Every table uses a surrogate integer primary key with `IDENTITY(1,1)` — `EmpID`, `ClientID`, `ProductID`, etc.

**Alternatives Considered:** Natural keys (employee badge numbers, client email, product SKU).

**Rationale:** Natural keys create fragile join chains. If a client changes their email or a product SKU is reissued, cascading updates across Orders, OrderItems, and Projects would corrupt referential integrity silently. IDENTITY keys are immutable — once a row is assigned `ClientID = 42`, that relationship is stable forever. This is especially important for the analytics use case: historical order data must always resolve correctly even if client contact information changes.

**Trade-off:** Surrogate keys require additional lookups when debugging raw data, but this cost is negligible against the stability benefit.

---

## Decision 2: CHECK Constraints Over Lookup Tables for Status and Tier Columns

**Choice:** Status and Tier columns use `CHECK` constraints directly on the table (e.g., `Tier CHECK('Bronze','Silver','Gold','Enterprise')`, `Status CHECK('Scoping','Active','On Hold','Completed','Cancelled')`).

**Alternatives Considered:** Separate lookup tables (`TierTypes`, `ProjectStatuses`) with foreign keys.

**Rationale:** The valid values for these columns are stable business rules, not user-editable reference data. Using CHECK constraints enforces integrity at the database engine level with zero additional joins in every query. A separate `ProjectStatuses` table would add a join to every project query without providing any analytical value — no analyst cares about the `StatusID` surrogate; they need the label. CHECK constraints also make the schema self-documenting: reading the DDL tells you immediately what values are allowed.

**Trade-off:** Adding a new status value requires a schema migration rather than an INSERT. This is acceptable; status vocabulary changes are infrequent and should be treated as schema events, not data events.

---

## Decision 3: DECIMAL(10,2) for All Monetary Columns

**Choice:** `Price`, `UnitPrice`, and `Budget` all use `DECIMAL(10,2)`.

**Alternatives Considered:** `FLOAT`, `MONEY`, `REAL`.

**Rationale:** `FLOAT` and `REAL` are binary floating-point types — they cannot represent `0.10` exactly, which causes silent rounding errors in financial aggregations. Multiplying thousands of `FLOAT` unit prices and summing them introduces cumulative error that will eventually appear in reports. `MONEY` is SQL Server-specific and rounds to 4 decimal places internally, which is imprecise when intermediate calculations occur. `DECIMAL(10,2)` is exact arithmetic: 10 total digits, always 2 after the decimal, no rounding drift, portable across database platforms.

**Trade-off:** Slightly more storage than FLOAT for large tables, and explicit casting is needed in some division operations to avoid integer truncation.

---

## Decision 4: Separate Orders and OrderItems Tables

**Choice:** Order-level data (who ordered, when, fulfillment status) lives in `Orders`. Line-item data (which product, quantity, price at time of purchase) lives in `OrderItems` with a foreign key back to `Orders`.

**Alternatives Considered:** A single wide `Orders` table with product columns, or storing items as a JSON column.

**Rationale:** One order typically contains multiple products. A flat structure would require one row per product per order, duplicating the order date, client, and status on every line — this violates 2NF and makes order-level aggregations (count of orders, fulfillment rate by status) require DISTINCT or subqueries. The normalized structure allows `Orders` to answer order-level questions directly and `OrderItems` to answer product/revenue questions. The join is straightforward and indexed on `OrderID`. The JSON alternative would make SQL aggregations impossible without JSON parsing functions and is not analytically queryable.

**Trade-off:** Every revenue query requires joining two tables. This is the standard trade-off of normalization and is well understood.

---

## Decision 5: Domain Separation Between OmniTech and SafeOps Databases

**Choice:** OmniTech (business analytics data) and SafeOps (security and operations audit data) are maintained as separate database schemas rather than combined into one.

**Alternatives Considered:** Single database with a `Domain` or `Schema` prefix on table names; cross-schema views.

**Rationale:** OmniTech data is business-operational — it answers revenue, client, and HR questions and is accessed by analysts and BI tools. SafeOps data is security-operational — it answers audit, access control, and incident questions and is accessed by security tooling and compliance processes. Merging them would create access control complexity: a business analyst querying orders should not have read access to security audit logs, and a security tool writing audit events should not have permission to touch salary data. Separate schemas enforce this boundary at the database permission layer. They also allow independent backup schedules, retention policies, and performance tuning.

**Trade-off:** Cross-domain questions (e.g., "which employees accessed the system on days they had no projects") require linked server queries or ETL to a reporting layer. This cost is acceptable given the security and governance benefits.
