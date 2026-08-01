import logging
import sqlite3
from pathlib import Path
import pandas as pd
import numpy as np

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

class OTTDataCleaner:
    @staticmethod
    def clean_viewing_events(df_events, df_content):
        logging.info("Cleaning viewing events data...")
        df = df_events.copy()
        
        # Deduplicate
        initial_len = len(df)
        df = df.drop_duplicates(subset=['event_id'])
        logging.info(f"Removed {initial_len - len(df)} duplicate viewing events.")
        
        # Check invalid durations
        merged = df.merge(df_content[['content_id', 'runtime_minutes']], on='content_id', how='left')
        invalid_mask = merged['watch_duration_minutes'] > merged['runtime_minutes']
        if invalid_mask.any():
            logging.warning(f"Found {invalid_mask.sum()} events with watch duration > runtime. Capping values.")
            merged.loc[invalid_mask, 'watch_duration_minutes'] = merged.loc[invalid_mask, 'runtime_minutes']
            merged['completion_rate_pct'] = (merged['watch_duration_minutes'] / merged['runtime_minutes']) * 100
        
        merged['is_completed'] = merged['completion_rate_pct'] >= 90.0
        return merged.drop(columns=['runtime_minutes'])

    @staticmethod
    def clean_users(df_users):
        logging.info("Cleaning users dimension...")
        df = df_users.copy()
        df['country_code'] = df['country_code'].str.upper().str.strip()
        df['user_segment'] = df['user_segment'].fillna('Standard')
        return df

class OTTDataValidator:
    @staticmethod
    def validate_integrity(datasets):
        logging.info("Running Data Quality Checks...")
        # Referential integrity check
        users = set(datasets['dim_users']['user_id'])
        events_users = set(datasets['fact_viewing_events']['user_id'])
        missing_users = events_users - users
        assert len(missing_users) == 0, f"Referential integrity failure: {len(missing_users)} users missing in dim_users!"
        
        # Null value checks
        assert datasets['dim_users']['user_id'].isnull().sum() == 0, "Null user_ids found!"
        assert datasets['dim_content']['content_id'].isnull().sum() == 0, "Null content_ids found!"
        logging.info("All Data Quality & Integrity Checks PASSED successfully!")
        return True

def run_etl():
    from src.generator.data_generator import generate_ott_dataset
    
    db_path = Path("ott_analytics_dw.db")
    logging.info(f"Initializing Data Warehouse ETL pipeline at {db_path.absolute()}")
    
    # 1. Extract (Generate Synthetic Data)
    datasets = generate_ott_dataset(num_users=1000, num_titles=200, num_events=10000)
    
    # 2. Transform & Clean
    datasets['fact_viewing_events'] = OTTDataCleaner.clean_viewing_events(
        datasets['fact_viewing_events'], datasets['dim_content']
    )
    datasets['dim_users'] = OTTDataCleaner.clean_users(datasets['dim_users'])
    
    # 3. Validate Quality
    OTTDataValidator.validate_integrity(datasets)
    
    # 4. Load into Database
    conn = sqlite3.connect(db_path)
    
    # Execute Schema DDL first
    ddl_path = Path("sql/01_schema_ddl.sql")
    if ddl_path.exists():
        logging.info("Applying Star Schema DDL...")
        with open(ddl_path, 'r') as f:
            conn.executescript(f.read())
    
    for table_name, df in datasets.items():
        logging.info(f"Loading table {table_name} ({len(df)} rows) into Data Warehouse...")
        df.to_sql(table_name, conn, if_exists='replace', index=False)
        
    # Execute Views DDL
    views_path = Path("sql/02_views_and_aggregates.sql")
    if views_path.exists():
        logging.info("Creating Analytical Views & Summary Tables...")
        with open(views_path, 'r') as f:
            conn.executescript(f.read())
            
    conn.close()
    logging.info("ETL Pipeline completed successfully! Enterprise Data Warehouse is ready.")

if __name__ == "__main__":
    run_etl()
