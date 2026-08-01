# Data Dictionary - OTT Content Intelligence & Viewer Analytics Platform

## Star Schema Overview

The Data Warehouse consists of 7 Dimension Tables and 4 Fact Tables designed for high-performance streaming telemetry analysis.

---

### 1. `dim_users` (User Dimension)
| Column Name | Data Type | Nullable | Primary Key | Description |
| :--- | :--- | :--- | :--- | :--- |
| `user_id` | VARCHAR(50) | No | Yes | Unique identifier for subscriber |
| `registration_date` | DATE | No | No | Account sign-up date |
| `country_code` | VARCHAR(10) | No | No | ISO country code (e.g., US, IN, GB) |
| `age_group` | VARCHAR(20) | No | No | Age tier (18-24, 25-34, 35-44, 45-54, 55+) |
| `gender` | VARCHAR(10) | Yes | No | Gender identity |
| `preferred_language` | VARCHAR(30) | Yes | No | Primary UI language preference |
| `acquisition_channel` | VARCHAR(50) | Yes | No | Marketing channel (Organic, Paid Social, Referral) |
| `user_segment` | VARCHAR(30) | No | No | Behavioral segment (Binge Watcher, Casual, Sports) |
| `is_active` | BOOLEAN | No | No | Account activity status flag |

---

### 2. `dim_content` (Content Metadata Dimension)
| Column Name | Data Type | Nullable | Primary Key | Description |
| :--- | :--- | :--- | :--- | :--- |
| `content_id` | VARCHAR(50) | No | Yes | Unique content asset identifier |
| `title` | VARCHAR(255) | No | No | Title name of movie, series episode, or show |
| `content_type` | VARCHAR(20) | No | No | Asset category (Movie, TV Series, Documentary, Live Sports) |
| `primary_genre` | VARCHAR(50) | No | No | Main genre classification |
| `secondary_genre` | VARCHAR(50) | Yes | No | Secondary genre classification |
| `release_year` | INT | Yes | No | Year of original release |
| `runtime_minutes` | INT | No | No | Total content runtime in minutes |
| `content_rating` | VARCHAR(15) | Yes | No | Maturity rating (PG-13, TV-MA, U/A 16+) |
| `licensing_cost_usd` | DECIMAL(12,2) | Yes | No | Amortized content acquisition or production cost |
| `is_original` | BOOLEAN | No | No | Flag indicating platform original content |
| `imdb_score` | DECIMAL(3,1) | Yes | No | Rating score on IMDB scale (1.0 - 10.0) |

---

### 3. `fact_viewing_events` (Viewing Playback Telemetry Fact)
| Column Name | Data Type | Nullable | Foreign Key | Description |
| :--- | :--- | :--- | :--- | :--- |
| `event_id` | VARCHAR(60) | No | PK | Unique playback session event ID |
| `user_id` | VARCHAR(50) | No | `dim_users` | Subscriber ID |
| `content_id` | VARCHAR(50) | No | `dim_content` | Content asset ID |
| `device_id` | VARCHAR(50) | No | `dim_device` | Streaming device ID |
| `geo_id` | VARCHAR(50) | No | `dim_geography` | Geographic region ID |
| `date_id` | INT | No | `dim_date` | Calendar date key (YYYYMMDD) |
| `event_timestamp` | TIMESTAMP | No | No | Exact start timestamp of playback event |
| `watch_duration_minutes` | DECIMAL(8,2) | No | No | Total active watch duration in minutes |
| `completion_rate_pct` | DECIMAL(5,2) | No | No | Watch duration divided by total runtime |
| `is_completed` | BOOLEAN | No | No | True if completion rate >= 90% |
| `buffer_count` | INT | No | No | Number of buffering events during playback |
| `total_buffer_duration_sec` | INT | No | No | Cumulative buffering delay in seconds |
| `bitrate_kbps` | INT | Yes | No | Average streaming bitrate |
| `video_quality` | VARCHAR(10) | Yes | No | Resolution tier (4K, 1080p, 720p) |
