-- ============================================================
-- NORTHWIND TRADERS: SECTION 1 - KPI CARDS
-- ============================================================

-- All 5 core KPIs in one query
SELECT
  ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount)), 2) AS total_revenue,
  COUNT(DISTINCT o.order_id) AS total_orders,
  ROUND(
    SUM(od.unit_price * od.quantity * (1 - od.discount)) / COUNT(DISTINCT o.order_id), 2
  ) AS avg_order_value,
  COUNT(DISTINCT o.customer_id) AS total_customers,
  ROUND(AVG(od.discount) * 100, 1) AS avg_discount_pct
FROM orders o
JOIN order_details od ON o.order_id = od.order_id;

-- Top 10 customer revenue share
WITH customer_revenue AS (
  SELECT
    o.customer_id,
    SUM(od.unit_price * od.quantity * (1 - od.discount)) AS customer_revenue
  FROM orders o
  JOIN order_details od ON o.order_id = od.order_id
  GROUP BY o.customer_id
),
totals AS (
  SELECT SUM(customer_revenue) AS total_rev FROM customer_revenue
)
SELECT
  ROUND(
    SUM(CASE WHEN rn <= 10 THEN cr.customer_revenue ELSE 0 END) / t.total_rev * 100, 1
  ) AS top_10_pct_of_revenue
FROM (
  SELECT
    customer_id,
    customer_revenue,
    ROW_NUMBER() OVER (ORDER BY customer_revenue DESC) AS rn
  FROM customer_revenue
) cr
CROSS JOIN totals t;
