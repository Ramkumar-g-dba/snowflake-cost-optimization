-- ============================================================
-- 08_cost_dashboard.sql
-- Cost Monitoring Dashboard Queries
-- Author: Ramkumar G
-- Project: Snowflake Cost Optimization
-- ============================================================

USE DATABASE COST_OPT_DB;
USE SCHEMA PUBLIC;
USE WAREHOUSE DEMO_WH;

-- ============================================================
-- DASHBOARD QUERY 1: Daily Credit Usage (Last 30 Days)
-- ============================================================
SELECT
    DATE(START_TIME)                AS usage_date,
    WAREHOUSE_NAME,
    SUM(CREDITS_USED)               AS credits_used,
    ROUND(SUM(CREDITS_USED) * 3, 2) AS estimated_cost_usd
FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY
WHERE START_TIME >= DATEADD(DAY, -30, CURRENT_TIMESTAMP())
GROUP BY usage_date, WAREHOUSE_NAME
ORDER BY usage_date DESC, credits_used DESC;

-- ============================================================
-- DASHBOARD QUERY 2: Top 10 Most Expensive Queries
-- ============================================================
SELECT
    LEFT(QUERY_TEXT, 100)           AS query_preview,
    USER_NAME,
    WAREHOUSE_NAME,
    EXECUTION_TIME / 1000           AS exec_seconds,
    BYTES_SCANNED / 1048576         AS mb_scanned,
    PARTITIONS_SCANNED,
    PARTITIONS_TOTAL,
    ROUND(PARTITIONS_SCANNED * 100.0 / NULLIF(PARTITIONS_TOTAL, 0), 1)
                                    AS pct_scanned
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE START_TIME >= DATEADD(DAY, -7, CURRENT_TIMESTAMP())
ORDER BY BYTES_SCANNED DESC
LIMIT 10;

-- ============================================================
-- DASHBOARD QUERY 3: Warehouse Idle Time Analysis
-- ============================================================
SELECT
    WAREHOUSE_NAME,
    SUM(CREDITS_USED)               AS total_credits,
    COUNT(*)                        AS total_sessions,
    AVG(CREDITS_USED)               AS avg_credits_per_session
FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY
WHERE START_TIME >= DATEADD(DAY, -7, CURRENT_TIMESTAMP())
GROUP BY WAREHOUSE_NAME
ORDER BY total_credits DESC;

-- ============================================================
-- DASHBOARD QUERY 4: Queries With No Partition Pruning (Wasteful)
-- ============================================================
SELECT
    LEFT(QUERY_TEXT, 150)           AS query_preview,
    PARTITIONS_SCANNED,
    PARTITIONS_TOTAL,
    BYTES_SCANNED / 1048576         AS mb_scanned,
    EXECUTION_TIME / 1000           AS exec_seconds,
    USER_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE START_TIME >= DATEADD(DAY, -7, CURRENT_TIMESTAMP())
  AND PARTITIONS_TOTAL > 5
  AND PARTITIONS_SCANNED = PARTITIONS_TOTAL  -- 100% scan = no pruning
ORDER BY BYTES_SCANNED DESC
LIMIT 20;

-- ============================================================
-- DASHBOARD QUERY 5: Weekly Cost Trend
-- ============================================================
SELECT
    DATE_TRUNC('WEEK', DATE(START_TIME))    AS week_start,
    SUM(CREDITS_USED)                       AS weekly_credits,
    ROUND(SUM(CREDITS_USED) * 3, 2)         AS weekly_cost_usd,
    LAG(SUM(CREDITS_USED)) OVER (ORDER BY DATE_TRUNC('WEEK', DATE(START_TIME)))
                                            AS prev_week_credits,
    ROUND(
        (SUM(CREDITS_USED) - LAG(SUM(CREDITS_USED)) OVER (ORDER BY DATE_TRUNC('WEEK', DATE(START_TIME))))
        * 100.0 / NULLIF(LAG(SUM(CREDITS_USED)) OVER (ORDER BY DATE_TRUNC('WEEK', DATE(START_TIME))), 0),
    2)                                      AS week_over_week_pct_change
FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY
WHERE START_TIME >= DATEADD(DAY, -90, CURRENT_TIMESTAMP())
GROUP BY week_start
ORDER BY week_start DESC;

-- ============================================================
-- DASHBOARD QUERY 6: Storage Cost Analysis
-- ============================================================
SELECT
    TABLE_NAME,
    ROW_COUNT,
    ROUND(BYTES / 1073741824, 4)            AS size_gb,
    ROUND(ACTIVE_BYTES / 1073741824, 4)     AS active_gb,
    ROUND(TIME_TRAVEL_BYTES / 1073741824, 4)AS time_travel_gb,
    ROUND(FAILSAFE_BYTES / 1073741824, 4)   AS failsafe_gb,
    -- Estimated monthly cost ($23 per TB)
    ROUND(BYTES / 1099511627776 * 23, 4)    AS est_monthly_cost_usd
FROM INFORMATION_SCHEMA.TABLE_STORAGE_METRICS
WHERE TABLE_CATALOG = 'COST_OPT_DB'
ORDER BY BYTES DESC;

-- ============================================================
-- DASHBOARD QUERY 7: Before vs After Comparison
-- Compares query performance before and after optimization
-- ============================================================
SELECT
    CASE
        WHEN QUERY_TEXT LIKE '%LIMIT%' OR
             QUERY_TEXT LIKE '%created_at >=%' THEN 'Optimized'
        ELSE 'Not Optimized'
    END                                     AS query_type,
    COUNT(*)                                AS query_count,
    AVG(EXECUTION_TIME / 1000)              AS avg_exec_seconds,
    AVG(BYTES_SCANNED / 1048576)            AS avg_mb_scanned,
    AVG(PARTITIONS_SCANNED * 100.0 / NULLIF(PARTITIONS_TOTAL, 0))
                                            AS avg_pct_scanned
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE START_TIME >= DATEADD(HOUR, -2, CURRENT_TIMESTAMP())
  AND WAREHOUSE_NAME = 'DEMO_WH'
  AND QUERY_TYPE = 'SELECT'
GROUP BY query_type;
