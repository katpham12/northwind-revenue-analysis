-- ============================================================
-- NORTHWIND TRADERS: SECTION 3 - REVENUE BY CATEGORY
-- ============================================================

-- Category revenue with % of total and avg order value
SELECT
  c.category_name,
  ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount)), 2) AS total_revenue,
  COUNT(DISTINCT o.order_id) AS order_count,
  ROUND(
    SUM(od.unit_price * od.quantity * (1 - od.discount)) / COUNT(DISTINCT o.order_id), 2
  ) AS avg_order_value,
  ROUND(
    SUM(od.unit_price * od.quantity * (1 - od.discount)) /
    SUM(SUM(od.unit_price * od.quantity * (1 - od.discount))) OVER () * 100, 1
  ) AS pct_of_total_revenue
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
JOIN products p ON od.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id
GROUP BY c.category_name
ORDER BY total_revenue DESC;

-- Category YoY with growing vs declining flag
-- Use this to color-code the category bar chart
SELECT
  c.category_name,
  DATE_PART('year', o.order_date) AS order_year,
  ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount)), 2) AS annual_revenue,
  ROUND(
    SUM(od.unit_price * od.quantity * (1 - od.discount)) -
    LAG(SUM(od.unit_price * od.quantity * (1 - od.discount)))
      OVER (PARTITION BY c.category_name ORDER BY DATE_PART('year', o.order_date))
  , 2) AS yoy_revenue_change
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
JOIN products p ON od.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id
GROUP BY c.category_name, DATE_PART('year', o.order_date)
ORDER BY c.category_name, order_year;
