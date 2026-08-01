import random
import uuid
from datetime import datetime, timedelta
import pandas as pd
import numpy as np

def generate_ott_dataset(num_users=1000, num_titles=150, num_events=5000):
    print("Generating synthetic OTT enterprise dataset...")
    random.seed(42)
    np.random.seed(42)

    # 1. Users
    countries = ['US', 'IN', 'GB', 'CA', 'AU', 'DE', 'BR', 'JP']
    age_groups = ['18-24', '25-34', '35-44', '45-54', '55+']
    genders = ['Male', 'Female', 'Non-Binary']
    languages = ['English', 'Hindi', 'Spanish', 'Japanese', 'German']
    channels = ['Organic Search', 'Paid Social', 'Referral', 'TV Ad', 'App Store']
    
    users = []
    start_date = datetime(2025, 1, 1)
    for i in range(1, num_users + 1):
        uid = f"USR_{i:06d}"
        reg_date = start_date + timedelta(days=random.randint(0, 500))
        users.append({
            'user_id': uid,
            'registration_date': reg_date.strftime('%Y-%m-%d'),
            'country_code': random.choice(countries),
            'age_group': random.choice(age_groups),
            'gender': random.choice(genders),
            'preferred_language': random.choice(languages),
            'acquisition_channel': random.choice(channels),
            'user_segment': random.choice(['Binge Watcher', 'Casual Viewer', 'Weekend Moviegoer', 'Sports Enthusiast']),
            'is_active': random.choices([True, False], weights=[0.85, 0.15])[0]
        })
    df_users = pd.DataFrame(users)

    # 2. Content
    genres = ['Action', 'Drama', 'Comedy', 'Sci-Fi', 'Thriller', 'Documentary', 'Romance', 'Horror', 'Live Sports']
    types = ['Movie', 'TV Series', 'Documentary', 'Live Sports']
    ratings = ['PG-13', 'TV-MA', 'U/A 16+', 'PG', 'R']

    content = []
    for i in range(1, num_titles + 1):
        cid = f"CNT_{i:05d}"
        ctype = random.choice(types)
        runtime = random.randint(80, 180) if ctype == 'Movie' else random.randint(30, 60)
        licensing = round(random.uniform(50000, 5000000), 2)
        content.append({
            'content_id': cid,
            'title': f"OTT Title {i}: The {random.choice(['Shadow', 'Legend', 'Chronicles', 'Rise', 'Empire', 'Final'])}{i}",
            'content_type': ctype,
            'primary_genre': random.choice(genres),
            'secondary_genre': random.choice(genres),
            'release_year': random.randint(2018, 2026),
            'runtime_minutes': runtime,
            'content_rating': random.choice(ratings),
            'language': random.choice(languages),
            'licensing_cost_usd': licensing,
            'is_original': random.choices([True, False], weights=[0.3, 0.7])[0],
            'imdb_score': round(random.uniform(5.5, 9.4), 1)
        })
    df_content = pd.DataFrame(content)

    # 3. Devices
    devices = []
    dev_types = ['Smart TV', 'Mobile', 'Tablet', 'Desktop', 'Gaming Console']
    os_list = ['Android TV', 'iOS', 'Android', 'macOS', 'Windows 11', 'FireOS', 'RokuOS']
    net_list = ['5G', '4G', 'Wi-Fi', 'Broadband Fiber']
    for i in range(1, 50):
        did = f"DEV_{i:03d}"
        devices.append({
            'device_id': did,
            'device_category': random.choice(dev_types),
            'operating_system': random.choice(os_list),
            'app_version': f"v{random.randint(1, 5)}.{random.randint(0, 9)}",
            'screen_resolution': random.choice(['4K UHD', '1080p Full HD', '720p HD']),
            'default_network_type': random.choice(net_list)
        })
    df_devices = pd.DataFrame(devices)

    # 4. Geography
    geos = []
    for i, c in enumerate(countries, 1):
        geos.append({
            'geo_id': f"GEO_{i:03d}",
            'country': c,
            'region': f"Region_{c}",
            'city': f"Metro_{c}_1",
            'timezone': 'UTC+0',
            'tier_category': random.choice(['Tier 1 Metro', 'Tier 2 City', 'Tier 3 / Rural'])
        })
    df_geos = pd.DataFrame(geos)

    # 5. Marketing Campaigns
    campaigns = []
    camp_channels = ['Social', 'Search', 'TV Ad', 'Influencer', 'Referral']
    for i in range(1, 15):
        campaigns.append({
            'campaign_id': f"CMP_{i:03d}",
            'campaign_name': f"Campaign {i} - {random.choice(['Summer Promo', 'New Release', 'Holiday Special', 'Black Friday'])}",
            'channel': random.choice(camp_channels),
            'target_demographic': random.choice(age_groups),
            'budget_usd': round(random.uniform(20000, 500000), 2),
            'start_date': '2025-01-01',
            'end_date': '2026-06-30'
        })
    df_campaigns = pd.DataFrame(campaigns)

    # 6. Payment Methods
    payments = []
    pm_types = ['Credit Card', 'UPI', 'PayPal', 'Direct Debit', 'Carrier Billing']
    for i in range(1, 10):
        payments.append({
            'payment_method_id': f"PAY_{i:03d}",
            'payment_type': random.choice(pm_types),
            'auto_renew_enabled': True,
            'billing_currency': 'USD'
        })
    df_payments = pd.DataFrame(payments)

    # 7. Dates Dimension
    date_records = []
    curr_date = datetime(2025, 1, 1)
    end_calendar = datetime(2026, 6, 30)
    while curr_date <= end_calendar:
        date_records.append({
            'date_id': int(curr_date.strftime('%Y%m%d')),
            'full_date': curr_date.strftime('%Y-%m-%d'),
            'year': curr_date.year,
            'quarter': (curr_date.month - 1) // 3 + 1,
            'month': curr_date.month,
            'month_name': curr_date.strftime('%B'),
            'day_of_month': curr_date.day,
            'day_of_week': curr_date.isoweekday(),
            'day_name': curr_date.strftime('%A'),
            'is_weekend': curr_date.isoweekday() in [6, 7],
            'is_holiday': False
        })
        curr_date += timedelta(days=1)
    df_dates = pd.DataFrame(date_records)

    # 8. Fact Viewing Events
    viewing_events = []
    user_ids = df_users['user_id'].tolist()
    content_ids = df_content['content_id'].tolist()
    device_ids = df_devices['device_id'].tolist()
    geo_ids = df_geos['geo_id'].tolist()
    
    for i in range(1, num_events + 1):
        event_dt = datetime(2025, 1, 1) + timedelta(days=random.randint(0, 500), minutes=random.randint(0, 1400))
        date_id = int(event_dt.strftime('%Y%m%d'))
        cid = random.choice(content_ids)
        runtime = df_content.loc[df_content['content_id'] == cid, 'runtime_minutes'].values[0]
        
        # watch duration logic
        watch_ratio = random.choices([random.uniform(0.05, 0.3), random.uniform(0.7, 1.0)], weights=[0.25, 0.75])[0]
        watch_duration = round(runtime * watch_ratio, 2)
        completion_rate = round((watch_duration / runtime) * 100, 2)
        is_completed = completion_rate >= 90.0
        
        buff_cnt = random.choices([0, 1, 2, 3, 5, 8], weights=[0.70, 0.15, 0.08, 0.04, 0.02, 0.01])[0]
        
        viewing_events.append({
            'event_id': f"EVT_{i:08d}",
            'user_id': random.choice(user_ids),
            'content_id': cid,
            'device_id': random.choice(device_ids),
            'geo_id': random.choice(geo_ids),
            'date_id': date_id,
            'event_timestamp': event_dt.strftime('%Y-%m-%d %H:%M:%S'),
            'watch_duration_minutes': watch_duration,
            'completion_rate_pct': completion_rate,
            'is_completed': is_completed,
            'buffer_count': buff_cnt,
            'total_buffer_duration_sec': buff_cnt * random.randint(3, 12),
            'bitrate_kbps': random.choice([1500, 3500, 6000, 15000]),
            'video_quality': random.choice(['4K', '1080p', '720p']),
            'user_rating': round(random.uniform(1.0, 5.0), 1) if random.random() < 0.3 else None
        })
    df_events = pd.DataFrame(viewing_events)

    # 9. Fact Subscriptions
    plans = [
        ('Mobile', 4.99),
        ('Basic', 8.99),
        ('Standard HD', 13.99),
        ('Premium 4K', 19.99),
        ('Ad-Supported', 6.99)
    ]
    statuses = ['Active', 'Cancelled', 'Expired', 'Paused', 'Payment Failed']
    churn_reasons = ['Price Too High', 'Lack of Content', 'Technical Issues', 'Switched to Competitor', 'Finished Target Series']

    subs = []
    for i, uid in enumerate(user_ids, 1):
        plan_name, price = random.choice(plans)
        s_date = datetime(2025, 1, 1) + timedelta(days=random.randint(0, 300))
        status = random.choices(statuses, weights=[0.65, 0.20, 0.08, 0.04, 0.03])[0]
        e_date = s_date + timedelta(days=random.randint(30, 365)) if status in ['Cancelled', 'Expired'] else None
        
        subs.append({
            'subscription_id': f"SUB_{i:06d}",
            'user_id': uid,
            'plan_tier': plan_name,
            'billing_cycle': random.choice(['Monthly', 'Quarterly', 'Annual']),
            'start_date': s_date.strftime('%Y-%m-%d'),
            'end_date': e_date.strftime('%Y-%m-%d') if e_date else None,
            'subscription_status': status,
            'monthly_price_usd': price,
            'discount_applied_usd': 0.00,
            'net_revenue_usd': price,
            'campaign_id': random.choice(df_campaigns['campaign_id'].tolist()),
            'payment_method_id': random.choice(df_payments['payment_method_id'].tolist()),
            'auto_renew': status == 'Active',
            'churn_reason': random.choice(churn_reasons) if status == 'Cancelled' else None
        })
    df_subs = pd.DataFrame(subs)

    # 10. Fact Ad Impressions
    ad_formats = ['Pre-Roll', 'Mid-Roll', 'Post-Roll', 'Banner Display']
    advertisers = ['Nike', 'Coca-Cola', 'Samsung', 'Apple', 'Amazon', 'Toyota', 'Pepsi', 'Netflix Games']
    ad_impressions = []
    for i in range(1, int(num_events * 0.4)):
        evt = df_events.iloc[random.randint(0, len(df_events)-1)]
        ad_impressions.append({
            'impression_id': f"IMP_{i:08d}",
            'user_id': evt['user_id'],
            'content_id': evt['content_id'],
            'device_id': evt['device_id'],
            'date_id': evt['date_id'],
            'ad_id': f"AD_{random.randint(100, 999)}",
            'ad_advertiser': random.choice(advertisers),
            'ad_format': random.choice(ad_formats),
            'ad_duration_sec': random.choice([15, 30]),
            'was_completed': random.choices([True, False], weights=[0.85, 0.15])[0],
            'was_clicked': random.choices([True, False], weights=[0.12, 0.88])[0],
            'ad_revenue_usd': round(random.uniform(0.015, 0.085), 4)
        })
    df_ads = pd.DataFrame(ad_impressions)

    # 11. Fact User Sessions
    sessions = []
    for i in range(1, int(num_events * 0.6)):
        s_start = datetime(2025, 1, 1) + timedelta(days=random.randint(0, 500), minutes=random.randint(0, 1400))
        s_dur = random.randint(10, 240)
        s_end = s_start + timedelta(minutes=s_dur)
        sessions.append({
            'session_id': f"SES_{i:08d}",
            'user_id': random.choice(user_ids),
            'device_id': random.choice(device_ids),
            'geo_id': random.choice(geo_ids),
            'session_start': s_start.strftime('%Y-%m-%d %H:%M:%S'),
            'session_end': s_end.strftime('%Y-%m-%d %H:%M:%S'),
            'session_duration_minutes': s_dur,
            'titles_viewed_count': random.randint(1, 5),
            'searches_performed_count': random.randint(0, 4),
            'had_playback_error': random.choices([True, False], weights=[0.05, 0.95])[0]
        })
    df_sessions = pd.DataFrame(sessions)

    return {
        'dim_users': df_users,
        'dim_content': df_content,
        'dim_device': df_devices,
        'dim_geography': df_geos,
        'dim_marketing_campaign': df_campaigns,
        'dim_payment': df_payments,
        'dim_date': df_dates,
        'fact_viewing_events': df_events,
        'fact_subscriptions': df_subs,
        'fact_ad_impressions': df_ads,
        'fact_user_sessions': df_sessions
    }

if __name__ == "__main__":
    datasets = generate_ott_dataset(num_users=500, num_titles=100, num_events=2000)
    for name, df in datasets.items():
        print(f"Table {name}: {len(df)} rows")
