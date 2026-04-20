-- ============================================================
-- 05_optimized_queries.sql
-- SOLUTION: Optimized Queries That Save Credits
-- Author: Ramkumar G
-- Project: Snowflake Cost Optimization
-- ============================================================
-- ✅ Run these AFTER 03_inefficient_queries.sql
-- ✅ Compare execution time + bytes scanned
-- ============================================================

USE DATABASE COST_OPT_DB;
USE SCHEMA PUBLIC;
USE WAREHOUSE DEMO_WH;

-- ============================================================
-- FIX 1: Select only needed columns (not SELECT *)
-- ✅ Columnar storage — only required columns read
-- ✅ Massive I/O reduction
-- ============================================================

-- ❌ BEFORE:
-- SELECT * FROM sales_data;

-- ✅ AFTER:
SELECT id, product, amount, status, created_at
FROM sales_data
LIMIT 100;

-- ============================================================
-- FIX 2: Add WHERE filter — enables partition pruning
-- ✅ Only recent data scanned
-- ✅ Old partitions skipped automatically
-- ============================================================

-- ❌ BEFORE:
-- SELECT product, SUM(amount) FROM sales_data GROUP BY product;

-- ✅ AFTER: Filter last 30 days only
SELECT
    product,
    SUM(amount)     AS total_revenue,
    COUNT(*)        AS order_count,
    AVG(amount)     AS avg_order_value
FROM sales_data
WHERE created_at >= DATEADD(DAY, -30, CURRENT_TIMESTAMP())
  AND status = 'completed'
GROUP BY product
ORDER BY total_revenue DESC;

-- ============================================================
-- FIX 3: Use CONTAINS or = instead of leading wildcard LIKE
-- ✅ Better performance than LIKE '%Laptop%'
-- ============================================================

-- ❌ BEFORE:
-- SELECT * FROM sales_data WHERE product LIKE '%Laptop%';

-- ✅ AFTER:
SELECT id, product, amount, created_at
FROM sales_data
WHERE product = 'Laptop Pro 15'
  AND created_at >= DATEADD(DAY, -90, CURRENT_TIMESTAMP());

-- ============================================================
-- FIX 4: Use LIMIT for exploratory queries
-- ✅ Never scan full table just to preview data
-- ============================================================

-- ❌ BEFORE:
-- SELECT * FROM sales_data;

-- ✅ AFTER:
SELECT * FROM sales_data LIMIT 10;

-- ============================================================
-- FIX 5: Add Clustering Key — better pruning for large tables
-- ✅ Data with same created_at grouped in same micro-partitions
-- ✅ Time-based queries become much faster
-- ============================================================

-- Add clustering key
ALTER TABLE sales_data CLUSTER BY (DATE(created_at), category);

-- Check clustering info
SELECT SYSTEM$CLUSTERING_INFORMATION('COST_OPT_DB.PUBLIC.SALES_DATA');

-- ============================================================
-- FIX 6: Use result cache — run same query multiple times FREE
-- ✅ Same query within 24 hours = zero credits
-- ============================================================
SELECT COUNT(*), SUM(amount)
FROM sales_data
WHERE status = 'completed';

-- Run same query again → Uses result cache → 0 credits!
SELECT COUNT(*), SUM(amount)
FROM sales_data
WHERE status = 'completed';

-- ============================================================
-- FIX 7: Use CTEs for readable + optimized queries
-- ✅ Better than subqueries in many cases
-- ============================================================
WITH recent_sales AS (
    SELECT product, category, amount, region
    FROM sales_data
    WHERE created_at >= DATEADD(DAY, -30, CURRENT_TIMESTAMP())
      AND status = 'completed'
),
product_revenue AS (
    SELECT
        product,
        category,
        SUM(amount)  AS revenue,
        COUNT(*)     AS orders
    FROM recent_sales
    GROUP BY product, category
)
SELECT *
FROM product_revenue
WHERE revenue > 10000
ORDER BY revenue DESC;

-- ============================================================
-- COMPARISON TABLE:
-- Run each optimized query and note improvement
-- ============================================================
-- | Query          | Before (seconds) | After (seconds) | Savings |
-- |----------------|-----------------|-----------------|---------|
-- | SELECT *       | ~8s             | ~0.1s           | 98%     |
-- | No filter      | ~5s             | ~0.5s           | 90%     |
-- | LIKE '%..%'    | ~6s             | ~0.3s           | 95%     |
-- | No LIMIT       | ~8s             | ~0.05s          | 99%     |
-- ============================================================

