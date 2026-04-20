-- ============================================================
-- 07_resource_monitor.sql
-- Resource Monitor — Prevent Cost Overruns
-- Author: Ramkumar G
-- Project: Snowflake Cost Optimization
-- ============================================================

USE ROLE ACCOUNTADMIN;

-- ============================================================
-- STEP 1: Create Resource Monitor
-- ✅ Hard limit on credits per month
-- ✅ Alerts at 50%, 75%, 90%
-- ✅ Auto-suspends warehouse at 100%
-- ============================================================
CREATE OR REPLACE RESOURCE MONITOR cost_opt_monitor
  CREDIT_QUOTA  = 50             -- Max 50 credits per month
  FREQUENCY     = MONTHLY
  START_TIMESTAMP = IMMEDIATELY
  TRIGGERS
    ON 50  PERCENT DO NOTIFY          -- Alert at 50% usage
    ON 75  PERCENT DO NOTIFY          -- Alert at 75% usage
    ON 90  PERCENT DO NOTIFY          -- Alert at 90% usage
    ON 100 PERCENT DO SUSPEND;        -- Stop warehouse at 100%

-- ============================================================
-- STEP 2: Assign to Warehouses
-- ============================================================
ALTER WAREHOUSE DEMO_WH
  SET RESOURCE_MONITOR = cost_opt_monitor;

ALTER WAREHOUSE ETL_WH
  SET RESOURCE_MONITOR = cost_opt_monitor;

ALTER WAREHOUSE ANALYTICS_WH
  SET RESOURCE_MONITOR = cost_opt_monitor;

-- ============================================================
-- STEP 3: Verify Resource Monitor
-- ============================================================
SHOW RESOURCE MONITORS;

-- ============================================================
-- STEP 4: Check current credit usage
-- ============================================================
SELECT
    NAME,
    CREDIT_QUOTA,
    CREDITS_USED,
    CREDITS_REMAINING,
    ROUND(CREDITS_USED * 100.0 / NULLIF(CREDIT_QUOTA, 0), 2) AS pct_used
FROM SNOWFLAKE.ACCOUNT_USAGE.RESOURCE_MONITORS
WHERE NAME = 'COST_OPT_MONITOR';
