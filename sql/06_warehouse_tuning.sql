-- ============================================================
-- 06_warehouse_tuning.sql
-- Warehouse Optimization — Right-sizing + Auto-suspend
-- Author: Ramkumar G
-- Project: Snowflake Cost Optimization
-- ============================================================

USE DATABASE COST_OPT_DB;
USE SCHEMA PUBLIC;

-- ============================================================
-- STEP 1: Check current warehouse config
-- ============================================================
SHOW WAREHOUSES LIKE 'DEMO_WH';

-- ============================================================
-- STEP 2: Reduce warehouse size (SMALL → X-SMALL)
-- ✅ X-SMALL = 1 credit/hour vs SMALL = 2 credits/hour
-- ✅ 50% cost reduction for same queries!
-- ✅ For small datasets (< 1GB), X-SMALL is sufficient
-- ============================================================
ALTER WAREHOUSE DEMO_WH
  SET WAREHOUSE_SIZE = 'X-SMALL';

-- ============================================================
-- STEP 3: Reduce auto-suspend (5 min → 60 seconds)
-- ✅ Warehouse was idle for 5 minutes before = wasted credits
-- ✅ Now suspends after 60 seconds = much less idle cost
-- ============================================================
ALTER WAREHOUSE DEMO_WH
  SET AUTO_SUSPEND = 60;

-- ============================================================
-- STEP 4: Enable auto-resume (should already be TRUE)
-- ✅ Warehouse auto-starts when query arrives
-- ✅ No manual start needed
-- ============================================================
ALTER WAREHOUSE DEMO_WH
  SET AUTO_RESUME = TRUE;

-- ============================================================
-- STEP 5: Add query tag for tracking
-- ✅ Identify which project is using credits
-- ============================================================
ALTER SESSION SET QUERY_TAG = 'cost_optimization_project';

-- ============================================================
-- STEP 6: Verify changes
-- ============================================================
SHOW WAREHOUSES LIKE 'DEMO_WH';

-- ============================================================
-- WAREHOUSE SIZING GUIDE:
-- ============================================================
-- X-Small (1 credit/hr)  → Dev, Testing, Small queries
-- Small   (2 credits/hr) → Light analytics, Small team
-- Medium  (4 credits/hr) → Regular analytics, Medium data
-- Large   (8 credits/hr) → Heavy queries, Large joins
-- X-Large (16 credits/hr)→ Complex analytics, Very large data
-- ============================================================

-- ============================================================
-- STEP 7: Create separate warehouses for different workloads
-- ✅ Different teams / purposes → separate warehouses
-- ✅ Better cost tracking + isolation
-- ============================================================

-- ETL warehouse (can be larger but runs less often)
CREATE WAREHOUSE IF NOT EXISTS ETL_WH
  WAREHOUSE_SIZE = 'SMALL'
  AUTO_SUSPEND   = 60
  AUTO_RESUME    = TRUE
  COMMENT        = 'Warehouse for ETL/ELT jobs';

-- Analytics warehouse (small, always available)
CREATE WAREHOUSE IF NOT EXISTS ANALYTICS_WH
  WAREHOUSE_SIZE = 'X-SMALL'
  AUTO_SUSPEND   = 60
  AUTO_RESUME    = TRUE
  COMMENT        = 'Warehouse for analyst queries';

SHOW WAREHOUSES;

