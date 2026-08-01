# Tableau Production Dashboard Specifications & LOD Guide

## Overview of 8 Enterprise Dashboards

### 1. Executive Summary & Subscriber Growth Dashboard
* **KPI Cards**: Total Subscribers, Monthly Recurring Revenue (MRR), DAU/MAU Stickiness %, Overall Churn Rate %.
* **Visuals**:
  * Monthly Subscriber Acquisition vs Churn Trend (Dual-Axis Combo Chart).
  * MRR Breakdown by Subscription Tier (Stacked Bar Chart).
* **LOD Expression**:
  * *User Max Watch Date*: `{FIXED [User_ID] : MAX([Event_Timestamp])}`
  * *Monthly Active User Flag*: `IF DATEDIFF('day', [User Max Watch Date], TODAY()) <= 30 THEN 1 ELSE 0 END`

### 2. Content Intelligence & Binge Analytics Dashboard
* **Visuals**:
  * Content Efficiency Matrix: Licensing Cost vs Total Watch Hours (Scatter Plot).
  * Top 15 Binge-Watched Titles (Horizontal Bar Chart sorted by Binge Index).
  * Episode Completion Drop-off Minutes (Area Chart).
* **LOD Expression**:
  * *Average Content Completion Rate*: `{FIXED [Content_ID] : AVG([Completion_Rate_Pct])}`

### 3. Subscriber Retention & Cohort Matrix Dashboard
* **Visuals**:
  * Month 0 to Month 12 Subscriber Retention Heatmap (Matrix Table).
  * Churn Reason Breakdown (Donut Chart).
* **LOD Expression**:
  * *Cohort Sign-Up Month*: `{FIXED [User_ID] : MIN(DATETRUNC('month', [Registration_Date]))}`

### 4. Ad Tech & Revenue Operations Dashboard
* **Visuals**:
  * Ad Impression Fill Rate & Click-Through Rate (CTR) by Advertiser.
  * Gross Ad Revenue Contribution by Ad Format (Pre-Roll vs Mid-Roll).

### 5. Marketing Campaign Attribution & Acquisition Funnel
* **Visuals**:
  * Acquisition Funnel: Impressions -> App Downloads -> Free Trial -> Paid Subscription.
  * Campaign ROI & LTV Contribution by Channel.

### 6. Technical Quality of Experience (QoE) & Operations Dashboard
* **Visuals**:
  * Buffering Rate (Events per Hour) vs Churn Rate by Device Category.
  * Bitrate Distribution & Playback Error Frequency.

### 7. Geographic & Regional Intelligence Dashboard
* **Visuals**:
  * Regional Subscriber Density & Local Content Consumption Map.
  * ARPU Variance across Country Tiers.

### 8. Predictive Churn Risk Control Center
* **Visuals**:
  * High Churn Risk Subscriber List (Filtered by Churn Probability Score > 0.70).
  * Recommended Retention Campaign Triggers (Personalized Push Notifications / Discounts).
