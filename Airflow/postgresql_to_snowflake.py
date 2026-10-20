"""PostgreSQL -> Snowflake (RAW layer), orchestrated with Prefect."""

import os
from datetime import datetime, timezone

import pandas as pd
import psycopg2
import snowflake.connector
from dotenv import load_dotenv
from prefect import flow, task
from snowflake.connector.pandas_tools import write_pandas

load_dotenv()

# PostgreSQL tables to copy. Each one goes to the same name in UPPER case in Snowflake.
TABLES = ["raw_customers", "raw_delivery_persons", "raw_products", "raw_sellers"]


@task(retries=2, retry_delay_seconds=30)
def load_table(table: str) -> int:
    # 1. Extract from PostgreSQL
    pg = psycopg2.connect(
        host=os.getenv("PG_HOST"),
        port=os.getenv("PG_PORT", "5432"),
        dbname=os.getenv("PG_DB"),
        user=os.getenv("PG_USER"),
        password=os.getenv("PG_PASSWORD"),
    )
    df = pd.read_sql(f"SELECT * FROM {table}", pg)
    pg.close()

    df["_loaded_at"] = datetime.now(timezone.utc)

    # 2. Load into Snowflake (full refresh: empty the table, then insert)
    with snowflake.connector.connect(
        account=os.getenv("SNOWFLAKE_ACCOUNT"),
        user=os.getenv("SNOWFLAKE_USER"),
        password=os.getenv("SNOWFLAKE_PASSWORD"),
        warehouse=os.getenv("SNOWFLAKE_WAREHOUSE"),
        database=os.getenv("SNOWFLAKE_DATABASE"),
        schema=os.getenv("SNOWFLAKE_SCHEMA", "RAW"),
        role=os.getenv("SNOWFLAKE_ROLE"),
    ) as sf:
        target = table.upper()
        sf.cursor().execute(f"TRUNCATE TABLE IF EXISTS {target}")
        write_pandas(sf, df, target, auto_create_table=True)  # creates the table only if missing

    return len(df)


@flow(log_prints=True)
def etl_pipeline():
    for table in TABLES:
        rows = load_table(table)
        print(f"{table}: loaded {rows} rows")


if __name__ == "__main__":
    etl_pipeline()