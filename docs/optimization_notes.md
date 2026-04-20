# Snowflake Cost Optimization — Key Learnings

## Project: Snowflake Cost Optimization
**Author:** Ramkumar G

---

## Problems Identified

### 1. SELECT * Queries
- **Problem:** Fetches all columns unnecessarily
- **Impact:** High I/O, more bytes scanned
- **Fix:** Select only required columns

### 2. No WHERE Filters
- **Problem:** Full table scan — no partition pruning
- **Impact:** All micro-partitions scanned = max credits
- **Fix:** Add date/status filters to enable pruning

### 3. Leading Wildcard LIKE
- **Problem:** `LIKE '%keyword%'` prevents index-like optimization
- **Impact:** Full scan required
- **Fix:** Use `=` or `CONTAINS()` where possible

### 4. Oversized Warehouse
- **Problem:** SMALL warehouse for small queries
- **Impact:** 2x credits vs X-SMALL for same work
- **Fix:** X-SMALL sufficient for datasets < 1GB

### 5. High Auto-Suspend Time
- **Problem:** 5 minute idle = 5 minutes of wasted credits
- **Impact:** Significant idle cost over time
- **Fix:** 60 seconds auto-suspend

### 6. No Resource Monitor
- **Problem:** No hard limit on credit usage
- **Impact:** Unexpected large bills
- **Fix:** Resource monitor with alerts + hard limit

---

## Optimizations Applied

| Optimization | Before | After | Savings |
|-------------|--------|-------|---------|
| Column selection | SELECT * | Specific columns | ~80% I/O reduction |
| Date filter | No filter | Last 30 days | ~70% scan reduction |
| Warehouse size | SMALL | X-SMALL | 50% credit reduction |
| Auto-suspend | 300 seconds | 60 seconds | ~80% idle cost reduction |
| Clustering key | None | DATE(created_at) | Better pruning |
| Resource monitor | None | 50 credit limit | Cost control |

---

## Results

- **Query execution time:** Reduced by ~90%
- **Data scanned:** Reduced from 100% → ~15% of table
- **Credit usage:** Estimated ~30% overall reduction
- **Idle cost:** Reduced by ~80% (auto-suspend fix)

---

## Key Commands Reference

```sql
-- Check expensive queries
SELECT QUERY_TEXT, EXECUTION_TIME/1000, BYTES_SCANNED/1048576
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
ORDER BY BYTES_SCANNED DESC LIMIT 10;

-- Right-size warehouse
ALTER WAREHOUSE demo_wh SET WAREHOUSE_SIZE = 'X-SMALL';

-- Reduce auto-suspend
ALTER WAREHOUSE demo_wh SET AUTO_SUSPEND = 60;

-- Add clustering key
ALTER TABLE sales_data CLUSTER BY (DATE(created_at));

-- Create resource monitor
CREATE RESOURCE MONITOR my_monitor
  CREDIT_QUOTA = 50
  TRIGGERS ON 100 PERCENT DO SUSPEND;
```

---

## Lessons Learned

1. **Always filter data** — WHERE clause is the most powerful optimization
2. **Right-size warehouses** — Bigger is not always better
3. **Monitor constantly** — ACCOUNT_USAGE views are your best friend
4. **Set resource monitors** — Prevent surprise bills
5. **Use result cache** — Identical queries = zero cost
6. **Clustering helps** — Especially for time-series data
7. **Auto-suspend aggressively** — 60 seconds is usually fine
