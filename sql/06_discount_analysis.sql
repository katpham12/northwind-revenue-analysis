-- ============================================================
-- NORTHWIND TRADERS: SECTION 6 - DISCOUNT ANALYSIS
-- ============================================================

-- Discount tier vs avg quantity (proves diminishing returns above 15%)
SELECT
  CASE
    WHEN discount = 0 THEN '0% - no discount'
    WHEN discount <= 0.05 THEN '1-5%'
    WHEN discount <= 0.10 THEN '6-10%'
    WHEN discount <= 0.15 THEN '11-15%'
    ELSE '16-25%'
  END AS discount_tier,
  COUNT(*) AS line_item_count,
  ROUND(AVG(quantity), 1) AS avg_quantity,
  ROUND(AVG(unit_price * quantity * (1 - discount)), 2) AS avg_line_revenue
FROM order_details
GROUP BY
  CASE
    WHEN discount = 0 THEN '0% - no discount'
    WHEN discount <= 0.05 THEN '1-5%'
    WHEN discount <= 0.10 THEN '6-10%'
    WHEN discount <= 0.15 THEN '11-15%'
    ELSE '16-25%'
  END
ORDER BY avg_quantity DESC;

-- End-of-quarter pressure selling pattern
-- Proves discount spike in final 2 weeks of each quarter
WITH order_quarter_position AS (
  SELECT
    o.order_id,
    o.order_date,
    (DATE_PART('doy', o.order_date) - DATE_PART('doy', DATE_TRUNC('quarter', o.order_date))) / 91.0 AS pct_through_quarter,
    CASE WHEN AVG(od.discount) > 0 THEN 1 ELSE 0 END AS has_discount
  FROM orders o
  JOIN order_details od ON o.order_id = od.order_id
  GROUP BY o.order_id, o.order_date
)
SELECT
  ROUND(pct_through_quarter * 10) / 10 AS quarter_position_bucket,
  COUNT(*) AS order_count,
  ROUND(AVG(has_discount) * 100, 1) AS pct_orders_with_discount
FROM order_quarter_position
GROUP BY ROUND(pct_through_quarter * 10) / 10
ORDER BY quarter_position_bucket;

-- Discount by category (which categories absorb the most margin hit)
SELECT
  c.category_name,
  ROUND(
    SUM(CASE WHEN od.discount > 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1
  ) AS pct_orders_discounted,
  ROUND(
    AVG(CASE WHEN od.discount > 0 THEN od.discount END) * 100, 1
  ) AS avg_discount_when_applied,
  ROUND(
    SUM(od.unit_price * od.quantity * od.discount), 2
  ) AS total_revenue_sacrificed
FROM order_details od
JOIN products p ON od.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id
GROUP BY c.category_name
ORDER BY total_revenue_sacrificed DESC;
