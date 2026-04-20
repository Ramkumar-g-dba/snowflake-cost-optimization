-- ============================================================
-- 01_setup.sql
-- Environment Setup — Database, Schema, Warehouse
-- Author: Ramkumar G
-- Project: Snowflake Cost Optimization
-- ============================================================

-- Step 1: Create Database & Schema
CREATE DATABASE IF NOT EXISTS COST_OPT_DB;
USE DATABASE COST_OPT_DB;

CREATE SCHEMA IF NOT EXISTS PUBLIC;
USE SCHEMA PUBLIC;

-- Step 2: Create Warehouse (SMALL — intentionally larger for demo)
CREATE WAREHOUSE IF NOT EXISTS DEMO_WH
  WAREHOUSE_SIZE    = 'SMALL'
  AUTO_SUSPEND      = 300        -- 5 minutes (intentionally high — will optimize later)
  AUTO_RESUME       = TRUE
  COMMENT           = 'Demo warehouse for cost optimization project';

USE WAREHOUSE DEMO_WH;

-- Verify setup
SHOW DATABASES;
SHOW WAREHOUSES;

-- ============================================================
-- NOTE:
-- We start with SMALL warehouse + 300 sec auto-suspend
-- This represents a poorly configured warehouse
-- After optimization we will:
--   → Reduce to X-SMALL
--   → Reduce auto-suspend to 60 seconds
-- ============================================================

