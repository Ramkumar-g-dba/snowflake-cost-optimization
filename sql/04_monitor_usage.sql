-- ============================================================
-- 04_monitor_usage.sql
-- Monitor Query History + Credit Usage
-- Author: Ramkumar G
-- Project: Snowflake Cost Optimization
-- ============================================================

USE DATABASE COST_OPT_DB;
USE SCHEMA PUBLIC;
USE WAREHOUSE DEMO_WH;

-- ============================================================
-- 1. CHECK RECENT QUERY HISTORY (Last 1 hour)
-- ============================================================
SELECT
    QUERY_TEXT,
    USER_NAME,
    WAREHOUSE_NAME,
    WAREHOUSE_SIZE,
    EXECUTION_TIME / 1000                   AS execution_seconds,
    BYTES_SCANNED / (1024 * 1024)           AS mb_scanned,
    PARTITIONS_SCANNED,
    PARTITIONS_TOTAL,
    ROUND(PARTITIONS_SCANNED * 100.0 / NULLIF(PARTITIONS_TOTAL, 0), 2)
                                            AS pct_partitions_scanned,
    CREDITS_USED_CLOUD_SERVICES
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE START_TIME >= DATEADD(HOUR, -1, CURRENT_TIMESTAMP())
  AND WAREHOUSE_NAME = 'DEMO_WH'
ORDER BY START_TIME DESC;

-- ============================================================
-- 2. FIND MOST EXPENSIVE QUERIES (By Execution Time)
-- ============================================================
SELECT
    QUERY_TEXT,
    EXECUTION_TIME / 1000   AS execution_seconds,
    BYTES_SCANNED / 1048576 AS mb_scanned,
    PARTITIONS_SCANNED,
    PARTITIONS_TOTAL
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE START_TIME >= DATEADD(DAY, -1, CURRENT_TIMESTAMP())
  AND WAREHOUSE_NAME = 'DEMO_WH'
ORDER BY EXECUTION_TIME DESC
LIMIT 10;

-- ============================================================
-- 3. CHECK WAREHOUSE CREDIT USAGE
-- ============================================================
SELECT
    WAREHOUSE_NAME,
    DATE(START_TIME)        AS usage_date,
    SUM(CREDITS_USED)       AS total_credits,
    SUM(CREDITS_USED) * 3   AS estimated_cost_usd  -- ~$3 per credit
FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY
WHERE START_TIME >= DATEADD(DAY, -7, CURRENT_TIMESTAMP())
GROUP BY WAREHOUSE_NAME, usage_date
ORDER BY usage_date DESC;

-- ============================================================
-- 4. CHECK QUERIES WITH FULL TABLE SCAN (0% pruning)
-- ============================================================
SELECT
    QUERY_TEXT,
    PARTITIONS_SCANNED,
    PARTITIONS_TOTAL,
    BYTES_SCANNED / 1048576 AS mb_scanned,
    EXECUTION_TIME / 1000   AS exec_seconds
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE START_TIME >= DATEADD(HOUR, -1, CURRENT_TIMESTAMP())
  AND PARTITIONS_TOTAL > 0
  AND PARTITIONS_SCANNED = PARTITIONS_TOTAL  -- 100% scan = no pruning!
ORDER BY BYTES_SCANNED DESC;

-- ============================================================
-- 5. STORAGE USAGE
-- ============================================================
SELECT
    TABLE_NAME,
    ROW_COUNT,
    BYTES / (1024 * 1024)       AS size_mb,
    ACTIVE_BYTES / 1048576      AS active_mb,
    TIME_TRAVEL_BYTES / 1048576 AS time_travel_mb,
    FAILSAFE_BYTES / 1048576    AS failsafe_mb
FROM INFORMATION_SCHEMA.TABLE_STORAGE_METRICS
WHERE TABLE_CATALOG = 'COST_OPT_DB'
ORDER BY BYTES DESC;

