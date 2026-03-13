# Revenue Operations Analysis: Northwind Traders
### Identifying Growth Levers and Margin Risk Across a $1.3M Product Portfolio

---

## Project Overview
Revenue operations analysis for Northwind Traders, a specialty food import and distribution company. Framed as an analyst embedded at the company, presenting findings to the VP of Revenue Operations ahead of the FY1999 planning cycle.

**Stakeholder:** VP of Revenue Operations and Sales Leadership
**Tools:** SQL (PostgreSQL), Excel, Tableau
**Dataset:** 830 orders, 91 customers, 77 products, 9 sales reps (July 1996 - August 1998)
**Data source:** Northwind Traders PostgreSQL sample database

---

## Key Metrics

| Metric | Value |
|---|---|
| Total revenue | $1.27M |
| Total orders | 830 |
| Avg order value | $1,530 |
| Total customers | 91 |
| Avg discount rate | 6.3% |
| Top 10 customer revenue share | 52% |
| Year 2 repeat purchase drop | -31% frequency |
| Sales rep performance spread | 3x (top vs bottom) |
| Bottom-quartile avg discount rate | 9.7% |
| Top-quartile avg discount rate | 4.1% |
| Geographic concentration | 58% (USA + Germany + France) |

---

## Four Core Findings

### 1. Revenue Trends
- Monthly trend with Q4 seasonal surge (22% above quarterly avg)
- Growing vs declining categories identified via YoY analysis
- Beverages lead by volume; Meat/Poultry leads by avg order value but is severely under-penetrated

### 2. Customer Concentration
- Top 10 customers = 52% of total revenue with no retention structure in place
- Year 2 repeat purchase frequency drops 31% from Year 1
- 58% of revenue concentrated in 3 countries (USA, Germany, France)

### 3. Sales Rep Performance
- 3x revenue variance between top and bottom performers
- Bottom-quartile reps discount at 2.4x the rate of top quartile (9.7% vs 4.1%)
- Discount gap is a coaching issue, not a market issue

### 4. Discount Strategy
- Diminishing returns above 15% discount; no incremental volume gained
- End-of-quarter pressure selling pattern confirmed (discount spike in final 2 weeks of each quarter)
- Margin erosion concentrated in specific categories

---

## SQL Query Library

All queries are in the `/sql` folder, organized by section:

| File | Contents |
|---|---|
| `00_data_quality_checks.sql` | Row counts, date ranges, outlier discounts, discontinued products |
| `01_kpi_cards.sql` | All 5 dashboard KPIs + top 10 customer revenue share |
| `02_revenue_trends.sql` | Monthly trend, quarterly comparison, Q4 surge calculation |
| `03_category_analysis.sql` | Revenue by category, YoY growth/decline flags |
| `04_customer_concentration.sql` | Customer revenue ranking, cumulative share, repeat purchase cohort |
| `05_rep_performance.sql` | Full rep summary, performance quartiles, new customer origination |
| `06_discount_analysis.sql` | Discount tier vs volume, end-of-quarter pattern, margin hit by category |

**Run order:** Start with `00_data_quality_checks.sql` to validate the dataset before any analysis.

---

## Data Source Setup

**Option 1 (recommended): PostgreSQL via GitHub**
- Repo: `pthom/northwind_psql`
- Load SQL dump into local Postgres or a free cloud instance (Neon, Supabase)
- Full 5-table schema ready to query

**Option 2: CSV direct to Tableau**
- Search "Northwind CSV GitHub" for pre-exported CSVs
- Connect in Tableau as a multi-table data source with joins

---

## Assumptions
- Revenue uses billed unit price from `order_details` (not list price from `products`)
- Margin analysis uses industry benchmark estimates; no COGS table exists in the dataset
- Observation window is 26 months, which limits YoY comparison to one full fiscal year
- 6 discontinued products retained in analysis for historical completeness

---

## Dashboard (Tableau Public)
*Link to be added after publish*

---

*Created by Kat Schmand | Dataset: Northwind Traders PostgreSQL sample database*
