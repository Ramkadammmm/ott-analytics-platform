-- ============================================================================
-- OTT CONTENT INTELLIGENCE & VIEWER ANALYTICS PLATFORM
-- Data Warehouse Views & Summary Aggregate Tables
-- Author: Principal Data Analytics Architect
-- ============================================================================

-- 1. View: Daily Active Users (DAU) & Engagement Summary
CREATE VIEW IF NOT EXISTS vw_daily_user_engagement AS
SELECT 
    d.full_date,
    d.year,
    d.month,
    d.day_name,
    COUNT(DISTINCT fve.user_id) AS active_viewers,
    COUNT(DISTINCT fve.event_id) AS total_stream_events,
    SUM(fve.watch_duration_minutes) / 60.0 AS total_watch_hours,
    AVG(fve.watch_duration_minutes) AS avg_watch_minutes_per_event,
    AVG(fve.completion_rate_pct) AS avg_completion_rate_pct,
    AVG(fve.buffer_count) AS avg_buffer_count
FROM fact_viewing_events fve
JOIN dim_date d ON fve.date_id = d.date_id
GROUP BY d.full_date, d.year, d.month, d.day_name;

-- 2. View: Content Performance Summary
CREATE VIEW IF NOT EXISTS vw_content_performance_summary AS
SELECT 
    c.content_id,
    c.title,
    c.content_type,
    c.primary_genre,
    c.release_year,
    c.is_original,
    c.licensing_cost_usd,
    COUNT(DISTINCT fve.user_id) AS unique_viewers,
    COUNT(fve.event_id) AS total_views,
    SUM(fve.watch_duration_minutes) / 60.0 AS total_watch_hours,
    AVG(fve.completion_rate_pct) AS avg_completion_rate,
    SUM(CASE WHEN fve.is_completed THEN 1 ELSE 0 END) * 100.0 / COUNT(fve.event_id) AS completion_percentage,
    AVG(fve.user_rating) AS avg_user_rating
FROM dim_content c
LEFT JOIN fact_viewing_events fve ON c.content_id = fve.content_id
GROUP BY c.content_id, c.title, c.content_type, c.primary_genre, c.release_year, c.is_original, c.licensing_cost_usd;

-- 3. View: Monthly Recurring Revenue (MRR) & Churn Analysis
CREATE VIEW IF NOT EXISTS vw_monthly_subscription_metrics AS
SELECT 
    STRFTIME('%Y-%m', s.start_date) AS yr_month,
    s.plan_tier,
    COUNT(DISTINCT s.subscription_id) AS total_subscriptions,
    SUM(s.net_revenue_usd) AS gross_revenue_usd,
    COUNT(DISTINCT CASE WHEN s.subscription_status = 'Cancelled' THEN s.subscription_id END) AS churned_subscriptions,
    COUNT(DISTINCT CASE WHEN s.subscription_status = 'Active' THEN s.subscription_id END) AS active_subscriptions
FROM fact_subscriptions s
GROUP BY STRFTIME('%Y-%m', s.start_date), s.plan_tier;

-- 4. Aggregate Table: Daily Content Performance
CREATE TABLE IF NOT EXISTS agg_daily_content_performance (
    summary_date DATE NOT NULL,
    content_id VARCHAR(50) NOT NULL,
    primary_genre VARCHAR(50),
    total_views INT DEFAULT 0,
    unique_viewers INT DEFAULT 0,
    total_watch_minutes DECIMAL(12, 2) DEFAULT 0.0,
    avg_completion_pct DECIMAL(5, 2) DEFAULT 0.0,
    total_buffering_events INT DEFAULT 0,
    PRIMARY KEY (summary_date, content_id)
);

-- 5. Aggregate Table: Monthly User Retention Cohorts
CREATE TABLE IF NOT EXISTS agg_monthly_user_retention (
    cohort_month VARCHAR(7) NOT NULL, -- YYYY-MM
    activity_month VARCHAR(7) NOT NULL, -- YYYY-MM
    period_number INT NOT NULL, -- Month 0, Month 1, Month 2...
    cohort_size INT NOT NULL,
    active_users_retained INT NOT NULL,
    retention_rate_pct DECIMAL(5, 2) NOT NULL,
    PRIMARY KEY (cohort_month, activity_month)
);
