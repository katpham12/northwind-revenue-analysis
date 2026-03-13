-- ============================================================
-- NORTHWIND TRADERS: SECTION 0 - DATA QUALITY CHECKS
-- Run these first before any analysis queries
-- ============================================================

-- Row counts across all tables
SELECT 'orders' AS table_name, COUNT(*) AS row_count FROM orders
UNION ALL SELECT 'order_details', COUNT(*) FROM order_details
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'customers', COUNT(*) FROM customers
UNION ALL SELECT 'employees', COUNT(*) FROM employees;

-- Date range and months covered
SELECT
  MIN(order_date) AS earliest_order,
  MAX(order_date) AS latest_order,
  COUNT(DISTINCT DATE_TRUNC('month', order_date)) AS months_covered
FROM orders;

-- Outlier discounts (above 0.25 = likely data error)
SELECT order_id, product_id, discount, unit_price, quantity
FROM order_details
WHERE discount > 0.25
ORDER BY discount DESC;

-- Discontinued products still appearing in orders
SELECT
  p.product_id,
  p.product_name,
  p.discontinued,
  COUNT(od.order_id) AS order_appearances
FROM products p
JOIN order_details od ON p.product_id = od.product_id
WHERE p.discontinued = 1
GROUP BY p.product_id, p.product_name, p.discontinued
ORDER BY order_appearances DESC;

-- Orders with no matching employee (orphaned records)
SELECT COUNT(*) AS orders_without_employee
FROM orders
WHERE employee_id IS NULL;

-- Orders with no line items (empty orders)
SELECT COUNT(*) AS orders_without_line_items
FROM orders o
LEFT JOIN order_details od ON o.order_id = od.order_id
WHERE od.order_id IS NULL;
