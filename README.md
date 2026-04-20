# ❄️ Snowflake Cost Optimization Project

> **Goal:** Identify and reduce unnecessary Snowflake credit usage through query optimization, warehouse tuning, and cost monitoring.

![Snowflake](https://img.shields.io/badge/Snowflake-Advanced-29B5E8?style=flat&logo=snowflake)
![SQL](https://img.shields.io/badge/SQL-Advanced-4479A1?style=flat)
![Cost](https://img.shields.io/badge/Cost-Reduced%2030%25-70AD47?style=flat)

---

## 🎯 Project Overview

In real-world Snowflake environments, **inefficient queries and poorly configured warehouses** can lead to massive credit wastage. This project demonstrates:

1. How to **identify** inefficient queries
2. How to **optimize** SQL and warehouse settings
3. How to **monitor** cost using ACCOUNT_USAGE views
4. How to **prevent** future cost overruns using Resource Monitors

---

## 📊 Results Achieved

| Metric | Before Optimization | After Optimization |
|--------|--------------------|--------------------|
| Query Execution Time | ~8 seconds | ~0.8 seconds |
| Data Scanned | 100% (full scan) | ~15% (pruned) |
| Credits Used | High | ~30% Reduced |
| Auto-Suspend | 5 minutes | 60 seconds |
| Warehouse Size | SMALL | X-SMALL |

---

## 🗂️ Project Structure

```
snowflake-cost-optimization/
│
├── README.md
│
├── sql/
│   ├── 01_setup.sql                  ← Database, warehouse setup
│   ├── 02_create_data.sql            ← Create tables + bulk data
│   ├── 03_inefficient_queries.sql    ← Problem queries (before)
│   ├── 04_monitor_usage.sql          ← Query history + usage check
│   ├── 05_optimized_queries.sql      ← Optimized queries (after)
│   ├── 06_warehouse_tuning.sql       ← Warehouse optimization
│   ├── 07_resource_monitor.sql       ← Cost control setup
│   └── 08_cost_dashboard.sql         ← Daily usage monitoring
│
└── docs/
    └── optimization_notes.md         ← Key learnings
```

---

## 🧱 Step-by-Step Guide

### Step 1: Setup Environment
Run `sql/01_setup.sql`

### Step 2: Create Dummy Data
Run `sql/02_create_data.sql` — inserts 10,000+ rows

### Step 3: Run Inefficient Queries (Problem)
Run `sql/03_inefficient_queries.sql` — observe high scan + slow execution

### Step 4: Monitor Usage
Run `sql/04_monitor_usage.sql` — check ACCOUNT_USAGE

### Step 5: Apply Optimizations
Run `sql/05_optimized_queries.sql` — compare execution time + bytes scanned

### Step 6: Tune Warehouse
Run `sql/06_warehouse_tuning.sql` — right-size warehouse + auto-suspend

### Step 7: Setup Resource Monitor
Run `sql/07_resource_monitor.sql` — prevent future cost overruns

### Step 8: Cost Dashboard
Run `sql/08_cost_dashboard.sql` — daily/weekly trend monitoring

---

## 💡 Key Optimizations Applied

1. **Added WHERE filters** → Partition pruning → Less data scanned
2. **Reduced warehouse size** → SMALL → X-SMALL → 50% credit reduction
3. **Auto-suspend reduced** → 5 min → 60 sec → Zero idle cost
4. **Clustering key added** → Better pruning on large table
5. **SELECT * replaced** → Only required columns fetched
6. **Resource Monitor** → Hard limit on credits → No surprises

---

## 👨‍💻 Author

**Ramkumar G**
- LinkedIn: [linkedin.com/in/ramdba](https://linkedin.com/in/ramdba)
- GitHub: [github.com/Ramkumar-g-dba](https://github.com/Ramkumar-g-dba)
- Portfolio: [ramkumar-g-dba.github.io/ramkumar-portfolio](https://ramkumar-g-dba.github.io/ramkumar-portfolio)
