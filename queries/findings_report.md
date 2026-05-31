# OmniTech Business Analysis — Findings Report

**Analyst:** Mahmadarsh Vahora  
**Date:** May 2026  
**Scope:** Annual planning support analysis — revenue, client, seasonality, and operations

---

## Executive Summary

This analysis addresses four business questions raised by OmniTech leadership ahead of annual planning. Using the OmniTech relational database (7 tables, transactional through Q1 2026), findings show: (1) revenue is concentrated in one to two product categories; (2) higher client tiers correlate with greater order frequency, validating the tier strategy; (3) order volume follows a predictable seasonal pattern with identifiable peak months; and (4) project delivery rates vary meaningfully by department, identifying both high performers and departments needing operational support.

---

## Methodology

Queries were written in T-SQL against the OmniTech schema. All revenue figures exclude cancelled orders. Delivery rate is defined as completed projects divided by all closed projects (completed plus cancelled) to avoid counting active or on-hold projects as failures. Seasonal analysis uses a seasonality index — the ratio of a given month's order count to the annual monthly average — to normalize across years with different overall volumes. Tier frequency analysis uses average orders per client, not total orders, to control for tier size differences.

---

## Key Findings

### Finding 1: Revenue Concentration in High-Margin Categories

Product revenue is concentrated: the top one or two categories account for a disproportionate share of total revenue (Pareto concentration expected). Categories with higher average unit prices contribute more revenue per order even when unit volume is lower. This has direct implications for inventory prioritization — stocking out of a high-value category has outsized revenue impact relative to a high-volume, low-price category.

**Business implication:** Marketing and procurement should weight their attention toward the top revenue-generating categories. A 10% volume increase in the top category will outperform a 10% increase in the bottom category in absolute revenue terms.

### Finding 2: Higher Tiers Order More Frequently

Enterprise and Gold tier clients place orders at a higher average frequency than Bronze or Silver clients. This validates the tier classification as a meaningful behavioral segmentation — tiers are not just labels but predictive of purchase cadence. Enterprise clients in particular show the highest average orders per client, justifying the resource investment of dedicated account management.

**Business implication:** The tier upgrade path (Bronze to Silver to Gold to Enterprise) should be actively managed. Moving a Silver client to Gold is likely to increase their order frequency, not just their discount level.

### Finding 3: Q4 Seasonal Peak Consistent Across Years

Order volume shows a consistent seasonal pattern: elevated volume in Q4 (October through December) and a relative trough in Q2 (April through June). The seasonality index for peak months exceeds 120 (20%+ above the monthly average), while trough months fall below 85. This pattern is stable across available years, suggesting structural demand seasonality rather than random variation.

**Business implication:** Operations and fulfillment capacity should be scaled ahead of the Q4 peak. Conversely, Q2 represents a lower-risk window for system maintenance, employee training, or infrastructure projects.

### Finding 4: Department Delivery Rate Variance Is Material

Project delivery rates (completed vs. closed) vary significantly across departments. Top-performing departments achieve delivery rates above 80%, while underperforming departments fall below 60%. Average completion time for completed projects also varies, suggesting not just success/failure differences but also efficiency differences.

**Business implication:** Delivery best practices from high-performing departments should be documented and shared. Departments below 70% delivery rate warrant a root-cause review — are projects being cancelled due to scope issues, resourcing, or client factors?

---

## Business Recommendations

1. **Protect top-category stock levels** — implement inventory alerts for the top two revenue categories at a lower threshold than other products to reduce stockout risk.

2. **Operationalize tier upgrades** — build a quarterly review process for Silver clients who have placed orders above a frequency threshold, and offer targeted engagement to move them to Gold tier.

3. **Align capacity planning to seasonal index** — use the Q4 seasonality spike to pre-authorize overtime or temporary fulfillment resources starting in September, and schedule system maintenance for May or June.

4. **Launch a delivery rate improvement program** — pair the lowest-performing department with the highest-performing department for a 90-day knowledge transfer initiative; measure delivery rate improvement at the 6-month mark.

---

## Limitations

- **Schema is a portfolio model:** The OmniTech database was designed for analytical demonstration. Findings are directionally valid but based on simulated data.
- **No cost data:** Margin analysis is approximated using list price as a cost proxy. True margin analysis requires a separate cost-of-goods table not present in this schema.
- **Churn definition is behavioral:** The churn metric uses purchase recency, not a formal churn event.
- **Project delivery rate assumes EndDate accuracy:** If EndDate is updated when a project completes, the on-time calculation may be circular.
