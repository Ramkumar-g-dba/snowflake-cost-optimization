-- ============================================================
-- 02_create_data.sql
-- Create Tables + Insert 10,000+ Rows of Dummy Data
-- Author: Ramkumar G
-- Project: Snowflake Cost Optimization
-- ============================================================

USE DATABASE COST_OPT_DB;
USE SCHEMA PUBLIC;
USE WAREHOUSE DEMO_WH;

-- ============================================================
-- CREATE TABLES
-- ============================================================

-- Main sales table
CREATE OR REPLACE TABLE sales_data (
    id          NUMBER AUTOINCREMENT PRIMARY KEY,
    product     VARCHAR(100),
    category    VARCHAR(50),
    region      VARCHAR(50),
    amount      NUMBER(10,2),
    quantity    NUMBER,
    status      VARCHAR(20),
    created_at  TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- Products reference table
CREATE OR REPLACE TABLE products (
    product_id   NUMBER PRIMARY KEY,
    product_name VARCHAR(100),
    category     VARCHAR(50),
    unit_price   NUMBER(10,2)
);

-- Customers table
CREATE OR REPLACE TABLE customers (
    customer_id  NUMBER PRIMARY KEY,
    name         VARCHAR(100),
    region       VARCHAR(50),
    joined_at    DATE
);

-- ============================================================
-- INSERT BULK DATA (10,000+ rows using GENERATOR)
-- ============================================================

-- Insert 10,000 rows into sales_data
INSERT INTO sales_data (product, category, region, amount, quantity, status, created_at)
SELECT
    CASE MOD(SEQ4(), 10)
        WHEN 0 THEN 'Laptop Pro 15'
        WHEN 1 THEN 'Wireless Mouse'
        WHEN 2 THEN 'Office Chair'
        WHEN 3 THEN 'USB Hub'
        WHEN 4 THEN 'Standing Desk'
        WHEN 5 THEN 'Mechanical Keyboard'
        WHEN 6 THEN 'Monitor 27 inch'
        WHEN 7 THEN 'Webcam HD'
        WHEN 8 THEN 'Desk Lamp'
        ELSE 'Headphones Pro'
    END AS product,

    CASE MOD(SEQ4(), 3)
        WHEN 0 THEN 'Electronics'
        WHEN 1 THEN 'Furniture'
        ELSE 'Accessories'
    END AS category,

    CASE MOD(SEQ4(), 5)
        WHEN 0 THEN 'North'
        WHEN 1 THEN 'South'
        WHEN 2 THEN 'East'
        WHEN 3 THEN 'West'
        ELSE 'Central'
    END AS region,

    ROUND(UNIFORM(500, 50000, RANDOM())::FLOAT, 2)  AS amount,
    UNIFORM(1, 20, RANDOM())                         AS quantity,

    CASE MOD(SEQ4(), 3)
        WHEN 0 THEN 'completed'
        WHEN 1 THEN 'pending'
        ELSE 'cancelled'
    END AS status,

    DATEADD(DAY, -UNIFORM(1, 365, RANDOM()), CURRENT_TIMESTAMP()) AS created_at

FROM TABLE(GENERATOR(ROWCOUNT => 10000));

-- ============================================================
-- VERIFY DATA
-- ============================================================
SELECT COUNT(*) AS total_rows    FROM sales_data;
SELECT COUNT(*) AS total_records FROM sales_data WHERE status = 'completed';

SELECT
    category,
    COUNT(*)            AS orders,
    SUM(amount)         AS total_revenue,
    AVG(amount)         AS avg_order_value
FROM sales_data
GROUP BY category
ORDER BY total_revenue DESC;

