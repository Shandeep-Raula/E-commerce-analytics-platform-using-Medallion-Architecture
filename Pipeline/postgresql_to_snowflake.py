"""
PostgreSQL → Snowflake ETL Pipeline
Orchestrated with Prefect — single file
"""

import os
import psycopg2
import pandas as pd
import snowflake.connector
from snowflake.connector.pandas_tools import write_pandas
from datetime import datetime, timezone
from dotenv import load_dotenv
from prefect import flow, task, get_run_logger

load_dotenv()

# ─────────────────────────────────────────────
# CONFIG
# ─────────────────────────────────────────────

# Map: PostgreSQL source table → Snowflake target table name
TABLE_MAP: dict[str, str] = {
    "raw_customers":        "RAW_CUSTOMERS",
    "raw_delivery_persons": "RAW_DELIVERY_PERSONS",
    "raw_products":         "RAW_PRODUCTS",
    "raw_sellers":          "RAW_SELLERS",
}

# Tables to skip during auto-discovery
EXCLUDE_TABLES: set[str] = {"schema_migrations", "spatial_ref_sys"}

# PostgreSQL schema to read from
PG_SCHEMA = os.getenv("PG_SCHEMA", "public")

# Load mode: "truncate_insert" (full refresh) or "append"
DEFAULT_LOAD_MODE = "truncate_insert"

POSTGRES_CONFIG = {
    "host":     os.getenv("PG_HOST"),
    "port":     int(os.getenv("PG_PORT", 5432)),
    "dbname":   os.getenv("PG_DB"),
    "user":     os.getenv("PG_USER"),
    "password": os.getenv("PG_PASSWORD"),
}

SNOWFLAKE_CONFIG = {
    "account":   os.getenv("SNOWFLAKE_ACCOUNT"),
    "user":      os.getenv("SNOWFLAKE_USER"),
    "password":  os.getenv("SNOWFLAKE_PASSWORD"),
    "warehouse": os.getenv("SNOWFLAKE_WAREHOUSE"),
    "database":  os.getenv("SNOWFLAKE_DATABASE"),
    "schema":    os.getenv("SNOWFLAKE_SCHEMA", "RAW"),
    "role":      os.getenv("SNOWFLAKE_ROLE"),
}

# ─────────────────────────────────────────────
# HELPERS
# ─────────────────────────────────────────────

def _pg_conn():
    return psycopg2.connect(**POSTGRES_CONFIG)

def _snowflake_conn():
    return snowflake.connector.connect(**SNOWFLAKE_CONFIG)

# ─────────────────────────────────────────────
# TASKS
# ─────────────────────────────────────────────

@task(name="discover-tables", retries=2, retry_delay_seconds=10)
def discover_tables() -> list[str]:
    """Auto-discover all user tables from PostgreSQL schema."""
    logger = get_run_logger()
    conn = _pg_conn()
    try:
        query = f"""
            SELECT table_name
            FROM information_schema.tables
            WHERE table_schema = '{PG_SCHEMA}'
              AND table_type = 'BASE TABLE'
            ORDER BY table_name;
        """
        df = pd.read_sql(query, conn)
        tables = [t for t in df["table_name"].tolist() if t not in EXCLUDE_TABLES]
        logger.info(f"Discovered {len(tables)} tables: {tables}")
        return tables
    finally:
        conn.close()


@task(name="extract-table", retries=3, retry_delay_seconds=30)
def extract_table(table_name: str) -> pd.DataFrame:
    """Extract all rows from a PostgreSQL table."""
    logger = get_run_logger()
    conn = _pg_conn()
    try:
        df = pd.read_sql(f'SELECT * FROM {PG_SCHEMA}."{table_name}"', conn)
        logger.info(f"[{table_name}] Extracted {len(df)} rows, {len(df.columns)} columns")
        return df
    finally:
        conn.close()


@task(name="ensure-snowflake-table")
def ensure_table_exists(target_table: str, df: pd.DataFrame):
    """Create the Snowflake target table if it doesn't already exist."""
    logger = get_run_logger()

    DTYPE_MAP = {
        "int64":               "NUMBER",
        "float64":             "FLOAT",
        "bool":                "BOOLEAN",
        "datetime64[ns]":      "TIMESTAMP_NTZ",
        "datetime64[ns, UTC]": "TIMESTAMP_TZ",
        "datetime64[us, UTC]": "TIMESTAMP_TZ",
        "object":              "VARCHAR",
    }

    col_defs = ", ".join(
        f'"{col}" {DTYPE_MAP.get(str(dtype), "VARCHAR")}'
        for col, dtype in df.dtypes.items()
    )

    ddl = f"""
        CREATE TABLE IF NOT EXISTS
        {SNOWFLAKE_CONFIG['database']}.{SNOWFLAKE_CONFIG['schema']}.{target_table}
        ({col_defs});
    """
    conn = _snowflake_conn()
    try:
        conn.cursor().execute(ddl)
        logger.info(f"[{target_table}] Table is ready in Snowflake")
    finally:
        conn.close()


@task(name="load-to-snowflake", retries=2, retry_delay_seconds=20)
def load_to_snowflake(df: pd.DataFrame, target_table: str, mode: str = "truncate_insert") -> int:
    """
    Load DataFrame into a Snowflake table.

    mode options:
      - "truncate_insert" : wipe the table, then reload (full refresh)
      - "append"          : insert rows without deleting existing data
    """
    logger = get_run_logger()
    conn = _snowflake_conn()
    database = SNOWFLAKE_CONFIG["database"]
    schema   = SNOWFLAKE_CONFIG["schema"]

    # Add pipeline metadata column
    df["_loaded_at"] = datetime.now(timezone.utc)

    try:
        if mode == "truncate_insert":
            conn.cursor().execute(
                f"TRUNCATE TABLE IF EXISTS {database}.{schema}.{target_table}"
            )
            logger.info(f"[{target_table}] Truncated for full refresh")

        success, nchunks, nrows, _ = write_pandas(
            conn=conn,
            df=df,
            table_name=target_table,
            schema=schema,
            database=database,
            auto_create_table=False,
            overwrite=False,
            quote_identifiers=True,
        )

        if not success:
            raise RuntimeError(f"write_pandas reported failure for {target_table}")

        logger.info(f"[{target_table}] Loaded {nrows} rows in {nchunks} chunks")
        return nrows

    finally:
        conn.close()

# ─────────────────────────────────────────────
# FLOW
# ─────────────────────────────────────────────

@flow(
    name="postgres-to-snowflake",
    description="Full ETL pipeline: PostgreSQL → Snowflake, orchestrated by Prefect",
    log_prints=True,
)
def etl_pipeline(
    tables: list[str] | None = None,
    load_mode: str = DEFAULT_LOAD_MODE,
):
    """
    Main Prefect flow.

    Args:
        tables:    Explicit list of PostgreSQL tables to sync.
                   Pass None to use TABLE_MAP, or leave TABLE_MAP empty to auto-discover all.
        load_mode: "truncate_insert" (default) or "append"
    """
    logger = get_run_logger()

    # Resolve which tables to sync
    if tables:
        source_tables = tables
    elif TABLE_MAP:
        source_tables = list(TABLE_MAP.keys())
    else:
        source_tables = discover_tables()

    logger.info(f"Starting ETL for {len(source_tables)} tables | mode={load_mode}")

    summary: dict[str, int] = {}

    for source_table in source_tables:
        target_table = TABLE_MAP.get(source_table, f"RAW_{source_table.upper()}")

        # Extract
        df = extract_table(source_table)

        # Ensure target table exists in Snowflake
        ensure_table_exists(target_table, df)

        # Load
        row_count = load_to_snowflake(df, target_table, mode=load_mode)

        summary[target_table] = row_count

    logger.info(f"Pipeline complete. Summary: {summary}")
    return summary


# ─────────────────────────────────────────────
# ENTRY POINT
# ─────────────────────────────────────────────

if __name__ == "__main__":
    # Run locally:
    #   python postgres_to_snowflake_pipeline.py
    #
    # Deploy with a daily schedule:
    #   prefect deploy postgres_to_snowflake_pipeline.py:etl_pipeline \
    #     --name "daily-sync" --cron "0 2 * * *"
    #
    # Run specific tables only:
    #   etl_pipeline(tables=["raw_customers", "raw_orders"])
    #
    # Append mode (no truncate):
    #   etl_pipeline(load_mode="append")

    etl_pipeline()