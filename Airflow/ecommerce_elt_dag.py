
from datetime import timedelta

import pendulum

from airflow.providers.airbyte.operators.airbyte import AirbyteTriggerSyncOperator
from airflow.providers.standard.operators.bash import BashOperator
from airflow.sdk import DAG

# --- Shell snippets: expanded by bash on the Airflow worker at run time -------------
PROJECT = '"${ECOM_PROJECT_ROOT:-/usr/local/airflow/project}"'
DBT_DIR = f"{PROJECT}/ecomerce_dbt"      # folder name as it is in your repo
PIPELINE_DIR = f"{PROJECT}/Pipeline"
DBT = '"${DBT_BIN:-dbt}"'

# Move into the dbt project and point dbt at profiles.yml (defaults to the project folder).
DBT_PREFIX = f'cd {DBT_DIR} && export DBT_PROFILES_DIR="${{DBT_PROFILES_DIR:-$PWD}}" && '

# Python ingestion script in /Pipeline (Postgres -> Snowflake RAW tables).
# Fails with a clear message if POSTGRES_INGEST_SCRIPT is not set.
INGEST_POSTGRES_CMD = (
    f"cd {PIPELINE_DIR} && "
    '"${PIPELINE_PYTHON:-python}" "${POSTGRES_INGEST_SCRIPT:?Set POSTGRES_INGEST_SCRIPT in .env}"'
)

default_args = {
    "owner": "data-engineering",
    "retries": 2,                          # network / API hiccups in ingestion
    "retry_delay": timedelta(minutes=5),
}

with DAG(
    dag_id="ecommerce_elt_pipeline",
    description="Postgres + MongoDB -> Snowflake (Bronze) -> dbt (Silver, Gold) with tests",
    doc_md=__doc__,
    default_args=default_args,
    start_date=pendulum.datetime(2026, 1, 1, tz="Asia/Kolkata"),
    schedule="0 2 * * *",                  # every day at 02:00 IST
    catchup=False,
    max_active_runs=1,
    tags=["ecommerce", "snowflake", "dbt", "medallion"],
) as dag:

    # ---------------- Ingestion (runs in parallel) ----------------
    ingest_postgres = BashOperator(
        task_id="ingest_postgres_to_snowflake",
        bash_command=INGEST_POSTGRES_CMD,
    )

    sync_mongodb_sessions = AirbyteTriggerSyncOperator(
        task_id="airbyte_sync_mongodb_sessions",
        airbyte_conn_id="airbyte_default",
        # Airflow Variable, resolved at run time (Admin -> Variables).
        connection_id="{{ var.value.get('airbyte_mongo_connection_id', 'REPLACE_WITH_AIRBYTE_CONNECTION_UUID') }}",
        asynchronous=False,
        timeout=3600,
        wait_seconds=10,
    )

    # ---------------- Transformation (dbt) ----------------
    dbt_deps = BashOperator(
        task_id="dbt_deps",                # installs dbt_utils
        bash_command=DBT_PREFIX + f"{DBT} deps",
        retries=1,
    )

    dbt_source_freshness = BashOperator(
        task_id="dbt_source_freshness",    # alert only: runs next to the build, does not gate it
        bash_command=DBT_PREFIX + f"{DBT} source freshness",
        retries=0,
    )

    dbt_build = BashOperator(
        task_id="dbt_build",               # seeds + snapshots + models + tests, in dependency order
        bash_command=DBT_PREFIX + f"{DBT} build",
        retries=0,                         # a failed data test fails again on retry, so do not retry
        execution_timeout=timedelta(hours=1),
    )

    dbt_docs_generate = BashOperator(
        task_id="dbt_docs_generate",       # refreshes lineage graph and docs
        bash_command=DBT_PREFIX + f"{DBT} docs generate",
        retries=0,
    )

    # ---------------- Dependencies ----------------
    [ingest_postgres, sync_mongodb_sessions] >> dbt_deps
    dbt_deps >> [dbt_source_freshness, dbt_build]
    dbt_build >> dbt_docs_generate
