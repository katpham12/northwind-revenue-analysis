-- ============================================================
-- NORTHWIND TRADERS: SECTION 4 - CUSTOMER CONCENTRATION
-- ============================================================

-- Customer revenue ranking with cumulative share
-- Use for the bar chart with 52% reference line
WITH customer_revenue AS (
  SELECT
    o.customer_id,
    c.company_name,
    c.country,
    ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount)), 2) AS total_revenue,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(AVG(od.discount) * 100, 1) AS avg_discount_pct
  FROM orders o
  JOIN order_details od ON o.order_id = od.order_id
  JOIN customers c ON o.customer_id = c.customer_id
  GROUP BY o.customer_id, c.company_name, c.country
),
ranked AS (
  SELECT *,
    ROW_NUMBER() OVER (ORDER BY total_revenue DESC) AS revenue_rank,
    ROUND(
      SUM(total_revenue) OVER (
        ORDER BY total_revenue DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
      ) / SUM(total_revenue) OVER () * 100, 1
    ) AS cumulative_revenue_pct
  FROM customer_revenue
)
SELECT
  revenue_rank,
  customer_id,
  company_name,
  country,
  total_revenue,
  total_orders,
  avg_discount_pct,
  cumulative_revenue_pct,
  CASE
    WHEN revenue_rank <= 10 THEN 'Top 10 - concentration risk'
    ELSE 'Other'
  END AS segment_flag
FROM ranked
ORDER BY revenue_rank;

-- Repeat purchase frequency by customer cohort year
-- Proves the -31% Year 2 drop
WITH customer_year_orders AS (
  SELECT
    o.customer_id,
    DATE_PART('year', o.order_date) AS order_year,
    COUNT(DISTINCT o.order_id) AS orders_that_year
  FROM orders o
  GROUP BY o.customer_id, DATE_PART('year', o.order_date)
),
customer_first_year AS (
  SELECT customer_id, MIN(order_year) AS first_year
  FROM customer_year_orders
  GROUP BY customer_id
)
SELECT
  cyo.order_year - cfy.first_year AS customer_year_cohort,
  ROUND(AVG(cyo.orders_that_year), 2) AS avg_orders_per_customer,
  COUNT(DISTINCT cyo.customer_id) AS customers_in_cohort
FROM customer_year_orders cyo
JOIN customer_first_year cfy ON cyo.customer_id = cfy.customer_id
GROUP BY cyo.order_year - cfy.first_year
ORDER BY customer_year_cohort;

-- Geographic revenue concentration
SELECT
  c.country,
  ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount)), 2) AS total_revenue,
  COUNT(DISTINCT o.customer_id) AS customers,
  ROUND(
    SUM(od.unit_price * od.quantity * (1 - od.discount)) /
    SUM(SUM(od.unit_price * od.quantity * (1 - od.discount))) OVER () * 100, 1
  ) AS pct_of_total_revenue
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.country
ORDER BY total_revenue DESC;
