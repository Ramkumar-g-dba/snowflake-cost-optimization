-- ============================================================
-- 03_inefficient_queries.sql
-- PROBLEM: Inefficient Queries That Waste Credits
-- Author: Ramkumar G
-- Project: Snowflake Cost Optimization
-- ============================================================
-- ⚠️  RUN THESE QUERIES AND NOTE EXECUTION TIME + BYTES SCANNED
-- ⚠️  These are INTENTIONALLY BAD — for comparison purpose
-- ============================================================

USE DATABASE COST_OPT_DB;
USE SCHEMA PUBLIC;
USE WAREHOUSE DEMO_WH;

-- ============================================================
-- PROBLEM 1: SELECT * — Full Table Scan
-- ❌ Fetches ALL columns even if not needed
-- ❌ In columnar storage, this is very wasteful
-- ============================================================
SELECT * FROM sales_data;
-- 👉 Note: Execution time + Bytes scanned

-- ============================================================
-- PROBLEM 2: No WHERE filter — Scans entire table
-- ❌ No partition pruning possible
-- ❌ All 10,000 rows scanned
-- ============================================================
SELECT product, SUM(amount) AS revenue
FROM sales_data
GROUP BY product
ORDER BY revenue DESC;

-- ============================================================
-- PROBLEM 3: LIKE with leading wildcard — No pruning
-- ❌ Cannot use metadata for pruning
-- ❌ Full scan every time
-- ============================================================
SELECT * FROM sales_data
WHERE product LIKE '%Laptop%';

-- ============================================================
-- PROBLEM 4: Repeated same query — Not using result cache
-- ❌ If you run the same query multiple times in different sessions
--    result cache won't help → credits wasted
-- ============================================================
SELECT COUNT(*), SUM(amount) FROM sales_data WHERE status = 'completed';
SELECT COUNT(*), SUM(amount) FROM sales_data WHERE status = 'completed';
SELECT COUNT(*), SUM(amount) FROM sales_data WHERE status = 'completed';

-- ============================================================
-- PROBLEM 5: No LIMIT on exploratory queries
-- ❌ Full scan just to see sample data
-- ============================================================
SELECT * FROM sales_data; -- should use LIMIT 10

-- ============================================================
-- PROBLEM 6: Unnecessary columns in GROUP BY
-- ❌ Forces more data processing
-- ============================================================
SELECT id, product, category, region, amount, quantity, status, created_at,
       SUM(amount) OVER (PARTITION BY category) AS category_total
FROM sales_data;

-- ============================================================
-- AFTER RUNNING ABOVE QUERIES:
-- Go to Snowsight → Activity → Query History
-- Note for each query:
--   → Execution Time
--   → Bytes Scanned
--   → Partitions Scanned vs Total
-- ============================================================

