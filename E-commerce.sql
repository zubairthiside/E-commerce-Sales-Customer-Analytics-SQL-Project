USE ecommerce;
DROP TABLE IF EXISTS Order_Items;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Products;
DROP TABLE IF EXISTS Customers;

CREATE TABLE Customers (
  customer_id INT PRIMARY KEY,
  first_name VARCHAR(50),
  last_name VARCHAR(50),
  email VARCHAR(100),
  signup_date DATE
);

CREATE TABLE Products(
  product_id INT PRIMARY KEY,
  product_name VARCHAR(100),
  category VARCHAR(50),
  price DECIMAL(10, 2)
);

CREATE TABLE Orders(
  order_id INT PRIMARY KEY,
  customer_id INT,
  order_date DATE,
  total_amount DECIMAL(10, 2),
  FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

CREATE TABLE Order_Items(
  order_item_id INT PRIMARY KEY,
  order_id INT,
  product_id INT,
  quantity INT,
  FOREIGN KEY (order_id) REFERENCES Orders(order_id),
  FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

INSERT INTO Customers (customer_id, first_name, last_name, email, signup_date) VALUES
(1, 'Alice', 'Smith', 'alice.smith@email.com', '2023-01-15'),
(2, 'Bob', 'Johnson', 'bob.johnson@email.com', '2023-02-20'),
(3, 'Charlie', 'Brown', 'charlie.brown@email.com', '2023-03-05'),
(4, 'David', 'Lee', 'david.lee@email.com', '2023-04-10'),
(5, 'Emily', 'Davis', 'emily.davis@email.com', '2023-05-22');

INSERT INTO Products (product_id, product_name, category, price) VALUES
(101, 'Laptop', 'Electronics', 1200.00),
(102, 'Smartphone', 'Electronics', 800.00),
(103, 'Coffee Maker', 'Appliances', 150.00),
(104, 'Headphones', 'Electronics', 250.00),
(105, 'Desk Chair', 'Furniture', 180.00);

INSERT INTO Orders (order_id, customer_id, order_date, total_amount) VALUES
(1001, 1, '2023-06-01', 1200.00), 
(1002, 2, '2023-06-05', 1050.00), 
(1003, 1, '2023-06-10', 300.00), 
(1004, 3, '2023-06-12', 180.00), 
(1005, 4, '2023-06-15', 800.00), 
(1006, 2, '2023-07-01', 250.00), 
(1007, 5, '2023-07-05', 1380.00); 

INSERT INTO Order_Items (order_item_id, order_id, product_id, quantity) VALUES
(2001, 1001, 101, 1); -- 1 * 1200.00 = 1200.00

-- Order 1002 (Bob)
INSERT INTO Order_Items (order_item_id, order_id, product_id, quantity) VALUES
(2002, 1002, 102, 1), -- 1 * 800.00
(2003, 1002, 104, 1); -- 1 * 250.00 = 1050.00

INSERT INTO Order_Items (order_item_id, order_id, product_id, quantity) VALUES
(2004, 1003, 103, 2); -- 2 * 150.00 = 300.00

INSERT INTO Order_Items (order_item_id, order_id, product_id, quantity) VALUES
(2005, 1004, 105, 1); -- 1 * 180.00 = 180.00

INSERT INTO Order_Items (order_item_id, order_id, product_id, quantity) VALUES
(2006, 1005, 102, 1); -- 1 * 800.00 = 800.00

INSERT INTO Order_Items (order_item_id, order_id, product_id, quantity) VALUES
(2007, 1006, 104, 1); -- 1 * 250.00 = 250.00

INSERT INTO Order_Items (order_item_id, order_id, product_id, quantity) VALUES
(2008, 1007, 101, 1), -- 1 * 1200.00
(2009, 1007, 105, 1); -- 1 * 180.00 = 1380.00

SELECT 
	SUM(total_amount) AS total_revenue_june_2023
FROM Orders
WHERE order_date BETWEEN '2023-06-01' AND '2023-06-30';

SELECT
	p.category,
    SUM(oi.quantity) AS total_units_sold,
    SUM(oi.quantity * p.price) AS category_revenue
FROM Products p
JOIN Order_Items oi ON p.product_id = oi.product_id
GROUP BY p.category
ORDER BY category_revenue DESC;

SELECT
	c.customer_id,
    c.first_name,
    c.email,
    SUM(o.total_amount) AS total_spent
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.email
ORDER BY total_spent DESC
LIMIT 10;

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

SELECT 
	c.first_name,
    c.email,
    CustomerOrders.order_count
FROM Customers c
JOIN(
SELECT
	customer_id,
    COUNT(order_id) AS order_count
FROM Orders
GROUP BY customer_id
HAVING COUNT(order_id) > 1
) AS CustomerOrders ON c.customer_id = CustomerOrders.customer_id;

WITH DailyRevenue AS (
    SELECT
        order_date,
        SUM(total_amount) AS daily_revenue
    FROM Orders
    GROUP BY order_date
)
SELECT
    order_date,
    daily_revenue,
    SUM(daily_revenue) OVER (
        ORDER BY order_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_revenue
FROM DailyRevenue
ORDER BY order_date;

WITH RFM_Base AS (
    SELECT
        c.customer_id,
        c.first_name,
        c.email,
        DATEDIFF('2023-08-01', MAX(o.order_date)) AS recency,
        COUNT(DISTINCT o.order_id) AS frequency,
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
    NTILE(4) OVER (ORDER BY recency ASC) AS R_Score,
    NTILE(4) OVER (ORDER BY frequency DESC) AS F_Score,
    NTILE(4) OVER (ORDER BY monetary_value DESC) AS M_Score
FROM RFM_Base
ORDER BY M_Score DESC, F_Score DESC;