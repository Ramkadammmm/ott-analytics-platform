# Enterprise Architecture & System Flow Specification

```mermaid
flowchart TB
    subgraph Data Generation & Ingestion
        A1[Client Applications: Mobile, Smart TV, Web] -->|HTTP Telemetry Logs| A2[API Gateway / Kafka Streaming Ingestion]
        A3[Billing & CRM DB] -->|CDC / Batch Export| A2
    end

    subgraph ETL Processing Engine
        A2 --> B1[Python Pipeline / PySpark]
        B1 -->|Quality Validation| B2[Data Cleaning & Deduplication]
        B2 -->|Schema Validation| B3[Data Quality Checks & Null Imputation]
    end

    subgraph Data Warehouse Star Schema
        B3 --> C1[(SQL Data Warehouse: PostgreSQL / Databricks)]
        C1 --- C2[Fact Viewing Events]
        C1 --- C3[Fact Subscriptions]
        C1 --- C4[Fact Ad Impressions]
        C1 --- C5[Dimension Tables: Users, Content, Devices, Geo]
    end

    subgraph Analytics & Modeling Layer
        C1 --> D1[Advanced SQL Query Suite - 50 Queries]
        C1 --> D2[R Statistical Analytics Engine: Churn & Forecasting]
    end

    subgraph Business Intelligence & Consumption
        D1 & D2 --> E1[Tableau Enterprise Dashboards - 8 Views]
        E1 --> E2[C-Suite & Executive Leadership Team]
        E1 --> E3[Content Acquisition & Marketing Managers]
    end
```

## System Components
1. **Data Ingestion**: Multi-tenant event logging streaming playback metrics, ad impressions, and app clickstream events.
2. **ETL Data Cleaning**: Pandas-based cleaning handling watch duration caps, timestamp normalization, and referential integrity validations.
3. **Data Warehouse (Star Schema)**: Optimized with composite indexes on `(user_id, date_id)`, `content_id`, and `subscription_status`.
4. **Statistical Analytics**: Logistic regression for churn probability modeling and Holt-Winters / ARIMA exponential smoothing for watch-hour forecasting.
