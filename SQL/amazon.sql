/*AMAZON SALES DATA EXPLORATORY DATA ANALYSIS USING SQL*/

/*SQL SKILLS: Select Statements
Joins
Grouping
Aggregation Functions
Ordering
Limiting
Conditional Selection
Subquery
Date Functions
String Functions
Mathematical Calculations
Case Statements
Working with NULL Values
Placeholders*/

-- Query 1: The top 10 most sold products
SELECT 
    p.product_name, COUNT(o.order_id) AS total_sales
FROM
    products p
    JOIN order_details od ON p.product_id = od.product_id
    JOIN orders o ON od.order_id = o.order_id
GROUP BY p.product_id
ORDER BY total_sales DESC
LIMIT 10;

-- Query 2: Total revenue by category for the last fiscal year
SELECT 
    c.category_name, SUM(od.unit_price * od.quantity) AS revenue
FROM
    categories c
    JOIN products p ON c.category_id = p.category_id
    JOIN order_details od ON p.product_id = od.product_id
    JOIN orders o ON od.order_id = o.order_id
WHERE
    YEAR(o.order_date) = YEAR(CURDATE()) - 1
GROUP BY c.category_id
ORDER BY revenue DESC;

-- Query 3: Monthly sales trend for a specific product
SELECT 
    MONTH(o.order_date) AS month, SUM(od.quantity) AS sales
FROM
    order_details od
    JOIN orders o ON od.order_id = o.order_id
WHERE
    od.product_id = ? -- specific product ID
GROUP BY month
ORDER BY month ASC;

-- Query 4: Customers who bought a specific product
SELECT 
    DISTINCT c.customer_id, c.customer_name
FROM
    customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_details od ON o.order_id = od.order_id
WHERE
    od.product_id = ? -- specific product ID
ORDER BY c.customer_name;

-- Query 5: Sales per region
SELECT 
    r.region_name, SUM(od.unit_price * od.quantity) AS total_sales
FROM
    regions r
    JOIN customers c ON r.region_id = c.region_id
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_details od ON o.order_id = od.order_id
GROUP BY r.region_id
ORDER BY total_sales DESC;

-- Query 6: Top 5 shippers by number of orders shipped
SELECT 
    s.shipper_name, COUNT(o.order_id) AS shipments
FROM
    shippers s
    JOIN orders o ON s.shipper_id = o.shipper_id
GROUP BY s.shipper_id
ORDER BY shipments DESC
LIMIT 5;

-- Query 7: Most valuable customers
SELECT 
    c.customer_name, SUM(od.unit_price * od.quantity) AS total_spent
FROM
    customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_details od ON o.order_id = od.order_id
GROUP BY c.customer_id
ORDER BY total_spent DESC
LIMIT 10;

-- Query 8: Products that have never been sold
SELECT 
    p.product_id, p.product_name
FROM
    products p
    LEFT JOIN order_details od ON p.product_id = od.product_id
WHERE
    od.product_id IS NULL;

-- Query 9: Sales growth by category compared to the previous year
SELECT 
    c.category_name,
    SUM(CASE WHEN YEAR(o.order_date) = YEAR(CURDATE()) THEN od.unit_price * od.quantity ELSE 0 END) AS current_year_sales,
    SUM(CASE WHEN YEAR(o.order_date) = YEAR(CURDATE()) - 1 THEN od.unit_price * od.quantity ELSE 0 END) AS last_year_sales,
    (current_year_sales - last_year_sales) / last_year_sales * 100 AS growth_percentage
FROM
    categories c
    JOIN products p ON c.category_id = p.category_id
    JOIN order_details od ON p.product_id = od.product_id
    JOIN orders o ON od.order_id = o.order_id
GROUP BY c.category_id;

-- Query 10: Total sales by weekday
SELECT 
    DAYNAME(o.order_date) AS weekday, SUM(od.unit_price * od.quantity) AS sales
FROM
    order_details od
    JOIN orders o ON od.order_id = o.order_id
GROUP BY weekday
ORDER BY sales DESC;

-- Query 11: Average order value by customer
SELECT 
    c.customer_name, AVG(od.unit_price * od.quantity) AS avg_order_value
FROM
    customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_details od ON o.order_id = od.order_id
GROUP BY c.customer_id;

-- Query 12: Orders with discounts applied
SELECT 
    o.order_id, o.order_date, od.unit_price * od.quantity AS total_price, od.discount
FROM
    orders o
    JOIN order_details od ON o.order_id = od.order_id
WHERE
    od.discount > 0;

-- Query 13: Sales by product category for a specific customer
SELECT 
    c.category_name, SUM(od.unit_price * od.quantity) AS sales
FROM
    categories c
    JOIN products p ON c.category_id = p.category_id
    JOIN order_details od ON p.product_id = od.product_id
    JOIN orders o ON od.order_id = o.order_id
WHERE
    o.customer_id = ? -- specific customer ID
GROUP BY c.category_id;

-- Query 14: Order status summary
SELECT 
    o.status, COUNT(o.order_id) AS number_of_orders
FROM
    orders o
GROUP BY o.status;

-- Query 15: Products that are below reorder level
SELECT 
    p.product_name, p.units_in_stock, p.reorder_level
FROM
    products p
WHERE
    p.units_in_stock < p.reorder_level;

-- Query 16: Top 10 cities by sales
SELECT 
    c.city, SUM(od.unit_price * od.quantity) AS sales
FROM
    customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_details od ON o.order_id = od.order_id
GROUP BY c.city
ORDER BY sales DESC
LIMIT 10;

-- Query 17: Sales comparison of two specific products
SELECT 
    p.product_name, SUM(od.unit_price * od.quantity) AS sales
FROM
    products p
    JOIN order_details od ON p.product_id = od.product_id
WHERE
    p.product_id IN (?, ?) -- specific product IDs
GROUP BY p.product_id;

-- Query 18: Sales by sales representative
SELECT 
    e.employee_name, SUM(od.unit_price * od.quantity) AS sales
FROM
    employees e
    JOIN orders o ON e.employee_id = o.employee_id
    JOIN order_details od ON o.order_id = od.order_id
GROUP BY e.employee_id;

-- Query 19: Customers who have not ordered in the last 6 months
SELECT 
    c.customer_name
FROM
    customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE
    o.order_date < DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
    OR o.order_date IS NULL;