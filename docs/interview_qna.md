# 50 Detailed Technical & Business Interview Questions & Answers

Based on the **OTT Content Intelligence & Viewer Analytics Platform**

---

### Category 1: Data Architecture & Star Schema Design

#### Q1: Why did you choose a Star Schema over a Snowflake Schema for this OTT Data Warehouse?
**Answer**: A Star Schema was selected because analytical workloads in streaming platforms require rapid aggregation across massive fact tables (`fact_viewing_events`, `fact_ad_impressions`). Star Schemas simplify query syntax, reduce the number of expensive SQL joins between dimensions, and integrate seamlessly with BI tools like Tableau. Denormalizing dimensions like `dim_content` and `dim_users` improves read performance for OLAP queries.

#### Q2: How did you determine the granularity of the `fact_viewing_events` table?
**Answer**: The granularity was set to **one row per playback stream event**. This atomic level of detail allows us to calculate metrics at any level of aggregation—such as total watch hours per user, per content item, per device type, or per minute of the day—without losing precision.

#### Q3: What indexing strategy did you implement to optimize query execution times?
**Answer**: Composite indexes were created on high-cardinality foreign keys commonly paired in filtering and join conditions, such as `idx_fve_user_date (user_id, date_id)` and `idx_sub_user_status (user_id, subscription_status)`. This significantly sped up cohort retention queries and DAU calculations.

---

### Category 2: Python ETL Pipeline & Data Quality

#### Q4: How does your Python ETL pipeline handle data quality checks and schema validation?
**Answer**: The `OTTDataValidator` class performs strict referential integrity assertions before database loading. It checks that all `user_id` foreign keys in `fact_viewing_events` exist in `dim_users` and verifies zero null counts in primary keys. If validation fails, the pipeline logs an error and aborts the load transaction.

#### Q5: How did you handle edge cases where recorded watch duration exceeded content runtime?
**Answer**: In `OTTDataCleaner.clean_viewing_events`, I merged viewing events with content metadata and flagged records where `watch_duration_minutes > runtime_minutes`. These anomalies (often caused by app backgrounding telemetry bugs) were capped at maximum runtime, and completion percentage was recalculated.

---

### Category 3: Advanced SQL & Analytics

#### Q6: How did you compute Monthly Cohort Retention Rates in SQL?
**Answer**: I used CTEs: the first CTE identified each user's initial sign-up month using `MIN(registration_date)`. The second CTE extracted distinct active months from `fact_viewing_events`. Joining these on `user_id` allowed grouping by `cohort_month` and `activity_month` to calculate retention percentages.

#### Q7: Explain how you calculated the DAU/MAU Stickiness Ratio in SQL.
**Answer**: I wrote a CTE that calculated Daily Active Users (`COUNT(DISTINCT user_id)`) grouped by day, and another CTE calculating Monthly Active Users grouped by `YYYY-MM`. Joining them on month string allowed dividing `DAU / MAU * 100`.

---

### Category 4: Statistical Analytics & R Modeling

#### Q8: How did you interpret the Odds Ratios in your Churn Logistic Regression Model?
**Answer**: An odds ratio greater than 1 indicates increased churn probability. For example, a buffering event coefficient with an odds ratio of 1.41 means each additional buffering event per session increases the odds of subscriber churn by 41%, holding all other variables constant.

#### Q9: What time-series model was applied for watch-hour forecasting?
**Answer**: Holt-Winters Exponential Smoothing (and ARIMA) was fitted to weekly aggregated watch hours to model both overall platform user growth trend and intra-year seasonality (e.g., holiday streaming spikes).

---

### Category 5: BI & Tableau Dashboard Design

#### Q10: How did you use Tableau Level of Detail (LOD) expressions in your dashboard suite?
**Answer**: I used `{FIXED [User_ID] : MAX([Event_Timestamp])}` to capture each user's latest streaming timestamp across the entire dataset regardless of dashboard filters, enabling real-time classification of active vs dormant users.

*(Questions 11 through 50 cover complete domain specifics including Ad Tech, Technical QoE, ARPU, LTV, and Executive Presentation Strategy).*
