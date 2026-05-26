SELECT * FROM order_items;

ALTER TABLE order_items
ALTER COLUMN list_price TYPE NUMERIC
USING CAST(REPLACE(REPLACE(TRIM(list_price), '₹', ''), ',', '') AS NUMERIC);

-- Store-wise total sales revenue
SELECT s.store_name,
       SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_sales
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN stores s ON o.store_id = s.store_id
GROUP BY s.store_name
ORDER BY total_sales DESC;

-- Region-wise (state) sales revenue
SELECT s.state,
       SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_sales
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN stores s ON o.store_id = s.store_id
GROUP BY s.state
ORDER BY total_sales DESC;

-- Product-wise sales quantity and revenue
SELECT p.product_name,
       SUM(oi.quantity) AS total_units_sold,
       SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_name
ORDER BY revenue DESC;

-- Product inventory vs sales trend
SELECT p.product_name,
       SUM(oi.quantity) AS units_sold,
       SUM(st.quantity) AS current_stock
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN stocks st ON p.product_id = st.product_id
GROUP BY p.product_name
ORDER BY units_sold DESC;

-- Staff-wise sales handled
SELECT st.first_name || ' ' || st.last_name AS staff_name,
       COUNT(DISTINCT o.order_id) AS orders_handled,
       SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_sales
FROM staffs st
JOIN orders o ON st.staff_id = o.staff_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY staff_name
ORDER BY total_sales DESC;

-- Customer order frequency and spending
SELECT c.first_name || ' ' || c.last_name AS customer_name,
       COUNT(DISTINCT o.order_id) AS total_orders,
       SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY customer_name
ORDER BY total_orders DESC;

-- Top repeat customers
SELECT c.first_name || ' ' || c.last_name AS customer_name,
       COUNT(o.order_id) AS order_count
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY customer_name
HAVING COUNT(o.order_id) > 5
ORDER BY order_count DESC;

-- Average order value per customer
SELECT c.first_name || ' ' || c.last_name AS customer_name,
       AVG(oi.quantity * oi.list_price * (1 - oi.discount)) AS avg_order_value
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY customer_name
ORDER BY avg_order_value DESC;

-- Overall revenue and discount impact
SELECT SUM(oi.quantity * oi.list_price) AS gross_revenue,
       SUM(oi.quantity * oi.list_price * oi.discount) AS total_discount,
       SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS net_revenue
FROM order_items oi;

-- Discount effectiveness by product
SELECT p.product_name,
       SUM(oi.quantity * oi.list_price * oi.discount) AS discount_given,
       SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS net_revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_name
ORDER BY discount_given DESC;




