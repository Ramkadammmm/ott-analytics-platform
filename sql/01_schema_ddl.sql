-- ============================================================================
-- OTT CONTENT INTELLIGENCE & VIEWER ANALYTICS PLATFORM
-- Data Warehouse DDL - Star Schema Architecture (PostgreSQL / SQLite Compatible)
-- Author: Principal Data Analytics Architect
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. DIMENSION TABLES
-- ----------------------------------------------------------------------------

-- Dimension: Users
CREATE TABLE IF NOT EXISTS dim_users (
    user_id VARCHAR(50) PRIMARY KEY,
    registration_date DATE NOT NULL,
    country_code VARCHAR(10) NOT NULL,
    age_group VARCHAR(20) CHECK (age_group IN ('18-24', '25-34', '35-44', '45-54', '55+')),
    gender VARCHAR(10),
    preferred_language VARCHAR(30),
    acquisition_channel VARCHAR(50),
    user_segment VARCHAR(30) DEFAULT 'Standard',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Dimension: Content Metadata
CREATE TABLE IF NOT EXISTS dim_content (
    content_id VARCHAR(50) PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    content_type VARCHAR(20) CHECK (content_type IN ('Movie', 'TV Series', 'Documentary', 'Live Sports', 'Short Film')),
    primary_genre VARCHAR(50) NOT NULL,
    secondary_genre VARCHAR(50),
    release_year INT,
    runtime_minutes INT NOT NULL,
    content_rating VARCHAR(15), -- PG-13, TV-MA, U/A 16+, etc.
    language VARCHAR(30),
    licensing_cost_usd DECIMAL(12, 2),
    is_original BOOLEAN DEFAULT FALSE,
    imdb_score DECIMAL(3, 1),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Dimension: Device & Network
CREATE TABLE IF NOT EXISTS dim_device (
    device_id VARCHAR(50) PRIMARY KEY,
    device_category VARCHAR(30) CHECK (device_category IN ('Smart TV', 'Mobile', 'Tablet', 'Desktop', 'Gaming Console', 'Streaming Stick')),
    operating_system VARCHAR(50),
    app_version VARCHAR(20),
    screen_resolution VARCHAR(20),
    default_network_type VARCHAR(20) CHECK (default_network_type IN ('5G', '4G', 'Wi-Fi', 'Broadband Fiber'))
);

-- Dimension: Geography
CREATE TABLE IF NOT EXISTS dim_geography (
    geo_id VARCHAR(50) PRIMARY KEY,
    country VARCHAR(50) NOT NULL,
    region VARCHAR(50) NOT NULL,
    city VARCHAR(50),
    timezone VARCHAR(50),
    tier_category VARCHAR(20) CHECK (tier_category IN ('Tier 1 Metro', 'Tier 2 City', 'Tier 3 / Rural'))
);

-- Dimension: Marketing Campaigns
CREATE TABLE IF NOT EXISTS dim_marketing_campaign (
    campaign_id VARCHAR(50) PRIMARY KEY,
    campaign_name VARCHAR(150) NOT NULL,
    channel VARCHAR(50), -- Social, Search, TV Ad, Influencer, Referral
    target_demographic VARCHAR(50),
    budget_usd DECIMAL(12, 2),
    start_date DATE,
    end_date DATE
);

-- Dimension: Payment Details
CREATE TABLE IF NOT EXISTS dim_payment (
    payment_method_id VARCHAR(50) PRIMARY KEY,
    payment_type VARCHAR(30) CHECK (payment_type IN ('Credit Card', 'UPI', 'PayPal', 'Direct Debit', 'Carrier Billing', 'Gift Card')),
    auto_renew_enabled BOOLEAN DEFAULT TRUE,
    billing_currency VARCHAR(10) DEFAULT 'USD'
);

-- Dimension: Date (Calendar Dimension)
CREATE TABLE IF NOT EXISTS dim_date (
    date_id INT PRIMARY KEY, -- Format YYYYMMDD
    full_date DATE NOT NULL,
    year INT NOT NULL,
    quarter INT NOT NULL,
    month INT NOT NULL,
    month_name VARCHAR(20) NOT NULL,
    day_of_month INT NOT NULL,
    day_of_week INT NOT NULL,
    day_name VARCHAR(20) NOT NULL,
    is_weekend BOOLEAN NOT NULL,
    is_holiday BOOLEAN DEFAULT FALSE
);

-- ----------------------------------------------------------------------------
-- 2. FACT TABLES
-- ----------------------------------------------------------------------------

-- Fact Table 1: Viewing Events (Granularity: Individual Playback Session Event)
CREATE TABLE IF NOT EXISTS fact_viewing_events (
    event_id VARCHAR(60) PRIMARY KEY,
    user_id VARCHAR(50) NOT NULL,
    content_id VARCHAR(50) NOT NULL,
    device_id VARCHAR(50) NOT NULL,
    geo_id VARCHAR(50) NOT NULL,
    date_id INT NOT NULL,
    event_timestamp TIMESTAMP NOT NULL,
    watch_duration_minutes DECIMAL(8, 2) NOT NULL,
    completion_rate_pct DECIMAL(5, 2) NOT NULL, -- (watch_duration / runtime) * 100
    is_completed BOOLEAN DEFAULT FALSE,
    buffer_count INT DEFAULT 0,
    total_buffer_duration_sec INT DEFAULT 0,
    bitrate_kbps INT,
    video_quality VARCHAR(10), -- 4K, 1080p, 720p, 480p
    user_rating DECIMAL(2, 1),
    FOREIGN KEY (user_id) REFERENCES dim_users(user_id),
    FOREIGN KEY (content_id) REFERENCES dim_content(content_id),
    FOREIGN KEY (device_id) REFERENCES dim_device(device_id),
    FOREIGN KEY (geo_id) REFERENCES dim_geography(geo_id),
    FOREIGN KEY (date_id) REFERENCES dim_date(date_id)
);

-- Fact Table 2: Subscriptions (Granularity: Subscription Transactions & Statuses)
CREATE TABLE IF NOT EXISTS fact_subscriptions (
    subscription_id VARCHAR(60) PRIMARY KEY,
    user_id VARCHAR(50) NOT NULL,
    plan_tier VARCHAR(30) CHECK (plan_tier IN ('Mobile', 'Basic', 'Standard HD', 'Premium 4K', 'Ad-Supported')),
    billing_cycle VARCHAR(20) CHECK (billing_cycle IN ('Monthly', 'Quarterly', 'Annual')),
    start_date DATE NOT NULL,
    end_date DATE,
    subscription_status VARCHAR(20) CHECK (subscription_status IN ('Active', 'Cancelled', 'Expired', 'Paused', 'Payment Failed')),
    monthly_price_usd DECIMAL(8, 2) NOT NULL,
    discount_applied_usd DECIMAL(8, 2) DEFAULT 0.00,
    net_revenue_usd DECIMAL(8, 2) NOT NULL,
    campaign_id VARCHAR(50),
    payment_method_id VARCHAR(50),
    auto_renew BOOLEAN DEFAULT TRUE,
    churn_reason VARCHAR(100),
    FOREIGN KEY (user_id) REFERENCES dim_users(user_id),
    FOREIGN KEY (campaign_id) REFERENCES dim_marketing_campaign(campaign_id),
    FOREIGN KEY (payment_method_id) REFERENCES dim_payment(payment_method_id)
);

-- Fact Table 3: Ad Impressions (Granularity: Single Ad Playback)
CREATE TABLE IF NOT EXISTS fact_ad_impressions (
    impression_id VARCHAR(60) PRIMARY KEY,
    user_id VARCHAR(50) NOT NULL,
    content_id VARCHAR(50) NOT NULL,
    device_id VARCHAR(50) NOT NULL,
    date_id INT NOT NULL,
    ad_id VARCHAR(50) NOT NULL,
    ad_advertiser VARCHAR(100),
    ad_format VARCHAR(30) CHECK (ad_format IN ('Pre-Roll', 'Mid-Roll', 'Post-Roll', 'Banner Display')),
    ad_duration_sec INT NOT NULL,
    was_completed BOOLEAN DEFAULT TRUE,
    was_clicked BOOLEAN DEFAULT FALSE,
    ad_revenue_usd DECIMAL(6, 4) NOT NULL, -- eCPM attribution
    FOREIGN KEY (user_id) REFERENCES dim_users(user_id),
    FOREIGN KEY (content_id) REFERENCES dim_content(content_id),
    FOREIGN KEY (device_id) REFERENCES dim_device(device_id),
    FOREIGN KEY (date_id) REFERENCES dim_date(date_id)
);

-- Fact Table 4: User Sessions (Granularity: User Login App Session)
CREATE TABLE IF NOT EXISTS fact_user_sessions (
    session_id VARCHAR(60) PRIMARY KEY,
    user_id VARCHAR(50) NOT NULL,
    device_id VARCHAR(50) NOT NULL,
    geo_id VARCHAR(50) NOT NULL,
    session_start TIMESTAMP NOT NULL,
    session_end TIMESTAMP NOT NULL,
    session_duration_minutes DECIMAL(8, 2) NOT NULL,
    titles_viewed_count INT DEFAULT 0,
    searches_performed_count INT DEFAULT 0,
    had_playback_error BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (user_id) REFERENCES dim_users(user_id),
    FOREIGN KEY (device_id) REFERENCES dim_device(device_id),
    FOREIGN KEY (geo_id) REFERENCES dim_geography(geo_id)
);

-- ----------------------------------------------------------------------------
-- 3. INDEXES FOR QUERY OPTIMIZATION
-- ----------------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_fve_user_date ON fact_viewing_events(user_id, date_id);
CREATE INDEX IF NOT EXISTS idx_fve_content ON fact_viewing_events(content_id);
CREATE INDEX IF NOT EXISTS idx_fve_timestamp ON fact_viewing_events(event_timestamp);

CREATE INDEX IF NOT EXISTS idx_sub_user_status ON fact_subscriptions(user_id, subscription_status);
CREATE INDEX IF NOT EXISTS idx_sub_start_end ON fact_subscriptions(start_date, end_date);

CREATE INDEX IF NOT EXISTS idx_ad_user_content ON fact_ad_impressions(user_id, content_id);
CREATE INDEX IF NOT EXISTS idx_session_user_start ON fact_user_sessions(user_id, session_start);
