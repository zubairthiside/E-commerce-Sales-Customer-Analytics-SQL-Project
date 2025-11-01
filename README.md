E-commerce Sales & Customer Analytics SQL Project

1. Project Objective

This project constitutes a simulation of a real-world analytics task pertinent to an e-commerce enterprise. The primary objective is to conduct a thorough analysis of a relational database, which contains data pertaining to customers, products, and sales, in order to elucidate critical business interrogations and identify significant market trends. The analysis progresses from foundational sales reporting to advanced customer segmentation.

This undertaking serves to demonstrate the capacity for composing clean, efficient, and complex SQL queries designed to extract actionable intelligence from a structured relational database architecture.

2. Database Schema

The database is comprised of four interconnected tables, the structures of which are delineated below:

Customers: This table stores information relevant to registered customers (e.g., identifying credentials, electronic mail addresses, and dates of registration).

Products: This table stores comprehensive details for all products offered within the catalog (e.g., product nomenclature, categorization, and unit price).

Orders: This table stores high-level transactional information for each discrete order (e.g., associated customer, date of transaction, and total monetary value).

Order_Items: This entity serves as a junction table, storing the specific items and corresponding quantities for each order, thereby facilitating the many-to-many relationship between the Orders and Products tables.

3. SQL Queries & Analysis

Herein are the key business interrogations addressed in this analysis, accompanied by the specific SQL queries employed for their resolution.

Query 1: Total Revenue (Basic)

Interrogation: What was the aggregate sales revenue for the period of June 2023?

Rationale: To conduct a high-level assessment of business performance for a specified temporal period.

SELECT
    SUM(total_amount) AS total_revenue_june_2023
FROM Orders
WHERE order_date BETWEEN '2023-06-01' AND '2023-06-30';


Query 2: Sales by Category (Basic)

Interrogation: What are the preeminent product categories, delineated by total units sold and aggregate revenue?

Rationale: To ascertain which product categories exhibit the highest popularity and which are the primary drivers of revenue.

SELECT
    p.category,
    SUM(oi.quantity) AS total_units_sold,
    SUM(oi.quantity * p.price) AS category_revenue
FROM Products p
JOIN Order_Items oi ON p.product_id = oi.product_id
GROUP BY p.category
ORDER BY category_revenue DESC;


Query 3: Top 5 Spending Customers (Intermediate)

Interrogation: Who are the Top 5 customers ranked by total monetary expenditure?

Rationale: To identify high-value customers who may be considered candidates for loyalty programs or similar retention strategies.

SELECT
    c.customer_id,
    c.first_name,
    c.email,
    SUM(o.total_amount) AS total_spent
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.email
ORDER BY total_spent DESC
LIMIT 5;


Query 4: Top 5 Best-Selling Products (Intermediate)

Interrogation: What are the top 5 best-selling products based on quantity sold?

Rationale: To inform inventory management protocols, stocking decisions, and the strategic planning of sales promotions.

SELECT
    p.product_name,
    SUM(oi.quantity) AS total_quantity_sold
FROM Products p
JOIN Order_Items oi ON p.product_id = oi.product_id
GROUP BY p.product_name
ORDER BY total_quantity_sold DESC
LIMIT 5;


Query 5: Average Order Value (AOV) (Advanced)

Interrogation: What is the mean monetary value expended per order transaction?

Rationale: To compute a key performance indicator (KPI) used to track temporal shifts in customer spending behavior and to evaluate the efficacy of marketing initiatives.

-- Using a Common Table Expression (CTE)
WITH OrderTotals AS (
    SELECT
        o.order_id,
        SUM(oi.quantity * p.price) AS order_total
    FROM Orders o
    JOIN Order_Items oi ON o.order_id = oi.order_id
    JOIN Products p ON oi.product_id = p.product_id
    GROUP BY o.order_id
)
SELECT
    AVG(order_total) AS average_order_value
FROM OrderTotals;


Query 6: Repeat Customers (Advanced)

Interrogation: Which customers have initiated more than one discrete order?

Rationale: To identify the cohort of loyal, repeat customers.

SELECT
    c.first_name,
    c.email,
    CustomerOrders.order_count
FROM Customers c
JOIN (
    -- Subquery to find the count of orders for each customer
    SELECT
        customer_id,
        COUNT(order_id) AS order_count
    FROM Orders
    GROUP BY customer_id
    HAVING COUNT(order_id) > 1 -- We use HAVING to filter after grouping
) AS CustomerOrders ON c.customer_id = CustomerOrders.customer_id;


Query 7: Cumulative Revenue Growth (Expert)

Interrogation: What is the diurnal cumulative growth pattern of total revenue?

Rationale: To visualize the cumulative financial growth of the business and to monitor performance trajectories over time.

WITH DailyRevenue AS (
    -- First, calculate total revenue for each day
    SELECT
        order_date,
        SUM(total_amount) AS daily_revenue
    FROM Orders
    GROUP BY order_date
)
SELECT
    order_date,
    daily_revenue,
    -- This is the window function. It sums all 'daily_revenue'
    -- from the start (UNBOUNDED PRECEDING) up to the current row.
    SUM(daily_revenue) OVER (
        ORDER BY order_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_revenue
FROM DailyRevenue
ORDER BY order_date;


Query 8: RFM Customer Segmentation (Expert)

Interrogation: Is it feasible to segment the customer base predicated on purchasing behaviors?

Rationale: To execute an RFM (Recency, Frequency, Monetary) analysis, which is an advanced marketing technique used to segment customers into distinct cohorts (e.g., "Best Customers," "At-Risk Customers") for the deployment of targeted campaigns.

WITH RFM_Base AS (
    SELECT
        c.customer_id,
        c.first_name,
        c.email,
        -- Recency: Days since last order.
        DATEDIFF('2023-08-01', MAX(o.order_date)) AS recency,
        -- Frequency: Total number of orders.
        COUNT(DISTINCT o.order_id) AS frequency,
        -- Monetary: Total amount spent.
        SUM(o.total_amount) AS monetary_value
    FROM Customers c
    JOIN Orders o ON c.customer_id = o.customer_id
    GROUP BY c.customer_id, c.first_name, c.email
)
SELECT
    customer_id,
    first_name,
    recency,
    frequency,
    monetary_value,
    -- Create 4 buckets (quartiles) for each R, F, M score.
    NTILE(4) OVER (ORDER BY recency ASC) AS R_Score,
    NTILE(4) OVER (ORDER BY frequency DESC) AS F_Score,
    NTILE(4) OVER (ORDER BY monetary_value DESC) AS M_Score
FROM RFM_Base
ORDER BY M_Score DESC, F_Score DESC;


4. Key SQL Concepts Demonstrated

This project showcases proficiency in a comprehensive array of SQL skills, including:

Schema Design: Instantiation of a relational schema utilizing primary and foreign keys.

Data Definition Language (DDL): Utilization of CREATE TABLE and DROP TABLE commands.

Data Manipulation Language (DML): Application of the INSERT INTO command.

Aggregate Functions: Employment of SUM(), AVG(), and COUNT().

Joins: Utilization of JOIN ... ON to amalgamate data from multiple tables.

Filtering: Application of WHERE and HAVING clauses for data filtration.

Grouping: Implementation of GROUP BY for data aggregation.

Sorting & Limiting: Usage of ORDER BY (with ASC/DESC) and LIMIT.

Common Table Expressions (CTEs): Employment of WITH ... AS to construct readable temporary result sets.

Subqueries: Utilization of nested queries within primary queries to filter data.

Window Functions: Application of OVER() to execute complex analyses, such as cumulative totals (SUM() OVER) and segmentation (NTILE() OVER).