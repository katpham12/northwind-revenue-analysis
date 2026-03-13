-- ============================================================
-- NORTHWIND TRADERS: SECTION 2 - REVENUE TRENDS
-- ============================================================

-- Monthly revenue trend (use for trend line chart)
SELECT
  DATE_TRUNC('month', o.order_date) AS order_month,
  TO_CHAR(o.order_date, 'Mon YYYY') AS month_label,
  ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount)), 2) AS monthly_revenue,
  COUNT(DISTINCT o.order_id) AS order_count,
  DATE_PART('quarter', o.order_date) AS fiscal_quarter
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
GROUP BY
  DATE_TRUNC('month', o.order_date),
  TO_CHAR(o.order_date, 'Mon YYYY'),
  DATE_PART('quarter', o.order_date)
ORDER BY order_month;

-- Quarterly revenue with % vs annual avg (proves Q4 surge)
SELECT
  DATE_PART('year', o.order_date) AS order_year,
  DATE_PART('quarter', o.order_date) AS fiscal_quarter,
  CONCAT('Q', DATE_PART('quarter', o.order_date), ' ', DATE_PART('year', o.order_date)) AS quarter_label,
  ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount)), 2) AS quarterly_revenue,
  ROUND(
    SUM(od.unit_price * od.quantity * (1 - od.discount)) /
    AVG(SUM(od.unit_price * od.quantity * (1 - od.discount)))
      OVER (PARTITION BY DATE_PART('year', o.order_date)) * 100 - 100, 1
  ) AS pct_above_annual_quarterly_avg
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
GROUP BY
  DATE_PART('year', o.order_date),
  DATE_PART('quarter', o.order_date)
ORDER BY order_year, fiscal_quarter;
