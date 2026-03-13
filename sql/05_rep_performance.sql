-- ============================================================
-- NORTHWIND TRADERS: SECTION 5 - SALES REP PERFORMANCE
-- ============================================================

-- Full rep summary with new customer origination
SELECT
  e.employee_id,
  CONCAT(e.first_name, ' ', e.last_name) AS rep_name,
  e.title,
  ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount)), 2) AS total_revenue,
  COUNT(DISTINCT o.order_id) AS total_orders,
  COUNT(DISTINCT o.customer_id) AS customers_served,
  ROUND(
    SUM(od.unit_price * od.quantity * (1 - od.discount)) / COUNT(DISTINCT o.order_id), 2
  ) AS avg_order_value,
  ROUND(AVG(od.discount) * 100, 1) AS avg_discount_pct,
  COUNT(DISTINCT CASE
    WHEN o.order_date = first_orders.first_order THEN o.customer_id
  END) AS new_customers_originated
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
JOIN employees e ON o.employee_id = e.employee_id
LEFT JOIN (
  SELECT customer_id, MIN(order_date) AS first_order
  FROM orders
  GROUP BY customer_id
) first_orders ON o.customer_id = first_orders.customer_id
GROUP BY e.employee_id, e.first_name, e.last_name, e.title
ORDER BY total_revenue DESC;

-- Rep performance quartiles for scatter plot color coding
-- Bubble size = discount rate; x = avg order value; y = total revenue
WITH rep_summary AS (
  SELECT
    e.employee_id,
    CONCAT(e.first_name, ' ', e.last_name) AS rep_name,
    ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount)), 2) AS total_revenue,
    ROUND(
      SUM(od.unit_price * od.quantity * (1 - od.discount)) / COUNT(DISTINCT o.order_id), 2
    ) AS avg_order_value,
    ROUND(AVG(od.discount) * 100, 1) AS avg_discount_pct
  FROM orders o
  JOIN order_details od ON o.order_id = od.order_id
  JOIN employees e ON o.employee_id = e.employee_id
  GROUP BY e.employee_id, e.first_name, e.last_name
)
SELECT *,
  NTILE(4) OVER (ORDER BY total_revenue ASC) AS revenue_quartile,
  CASE
    WHEN NTILE(4) OVER (ORDER BY total_revenue ASC) = 4 THEN 'Top quartile'
    WHEN NTILE(4) OVER (ORDER BY total_revenue ASC) = 1 THEN 'Bottom quartile'
    ELSE 'Mid tier'
  END AS performance_tier
FROM rep_summary
ORDER BY total_revenue DESC;
