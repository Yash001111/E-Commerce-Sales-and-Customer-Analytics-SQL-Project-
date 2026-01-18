create database market_point;
use market_point;
CREATE TABLE ecommerce_orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    product_category VARCHAR(20),
    product_price INT,
    quantity INT,
    payment_method VARCHAR(15),
    order_status VARCHAR(15),
    city VARCHAR(20),
    delivery_days INT
);
CREATE TABLE customers (
    customer_id INT PRIMARY KEY
);
INSERT INTO customers (customer_id)
SELECT DISTINCT customer_id
FROM ecommerce_orders;
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    payment_method VARCHAR(15),
    order_status VARCHAR(15),
    city VARCHAR(20),
    delivery_days INT,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
INSERT INTO orders
SELECT order_id, customer_id, order_date,
       payment_method, order_status, city, delivery_days
FROM ecommerce_orders;
CREATE TABLE order_items (
    order_id INT,
    product_category VARCHAR(20),
    product_price INT,
    quantity INT,
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);
INSERT INTO order_items
SELECT order_id, product_category, product_price, quantity
FROM ecommerce_orders;

SELECT SUM(product_price * quantity) AS total_revenue
FROM order_items;

SELECT product_category,
       SUM(product_price * quantity) AS revenue
FROM order_items
GROUP BY product_category
ORDER BY revenue DESC;

SELECT o.city,
       SUM(oi.product_price * oi.quantity) AS revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.city
ORDER BY revenue DESC;

SELECT o.order_id,
       SUM(oi.product_price * oi.quantity) AS order_value
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_id
ORDER BY order_value DESC
LIMIT 5;

SELECT o.customer_id,
       SUM(oi.product_price * oi.quantity) AS total_spent
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.customer_id
ORDER BY total_spent DESC
LIMIT 10;

SELECT AVG(total_spent) AS avg_spend_per_customer
FROM (
    SELECT o.customer_id,
           SUM(oi.product_price * oi.quantity) AS total_spent
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY o.customer_id
) t;

SELECT customer_id,
       COUNT(*) AS total_orders,
       RANK() OVER (ORDER BY COUNT(*) DESC) AS rnk
FROM orders
GROUP BY customer_id;

SELECT customer_id,
       AVG(order_value) AS avg_order_value
FROM (
    SELECT o.customer_id,
           o.order_id,
           SUM(oi.product_price * oi.quantity) AS order_value
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY o.customer_id, o.order_id
) t
GROUP BY customer_id
ORDER BY avg_order_value DESC;

SELECT o.payment_method,
       SUM(oi.product_price * oi.quantity) AS revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.payment_method;

SELECT city, AVG(delivery_days) AS avg_delivery
FROM orders
GROUP BY city
ORDER BY avg_delivery DESC
LIMIT 1;

SELECT SUM(oi.product_price * oi.quantity) AS returned_revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'Returned';

SELECT oi.product_category,
       SUM(oi.product_price * oi.quantity) AS revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status != 'Returned'
GROUP BY oi.product_category
ORDER BY revenue DESC
LIMIT 1;


