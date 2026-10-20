from datetime import datetime

from airflow.providers.standard.operators.bash import BashOperator
from airflow.sdk import DAG


DBT_DIR = "/usr/local/airflow/ecomerce_dbt"   # where your dbt project is mounted
DBT_CMD = f"cd {DBT_DIR} && dbt"              # dbt Core, installed with pip

with DAG(
    dag_id="ecommerce_dbt_pipeline",
    start_date=datetime(2026, 1, 1),
    schedule="@daily",
    catchup=False,
) as dag:

    dbt_deps = BashOperator(task_id="dbt_deps", bash_command=f"{DBT_CMD} deps")

    dbt_seed = BashOperator(task_id="dbt_seed", bash_command=f"{DBT_CMD} seed")

    dbt_run_staging = BashOperator(
        task_id="dbt_run_staging",
        bash_command=f"{DBT_CMD} run --select 'STG_*'",
    )

    dbt_snapshot = BashOperator(task_id="dbt_snapshot", bash_command=f"{DBT_CMD} snapshot")

    dbt_run_rest = BashOperator(
        task_id="dbt_run_intermediate_and_gold",
        bash_command=f"{DBT_CMD} run --exclude 'STG_*'",
    )

    dbt_test = BashOperator(task_id="dbt_test", bash_command=f"{DBT_CMD} test --store-failures")

    dbt_deps >> dbt_seed >> dbt_run_staging >> dbt_snapshot >> dbt_run_rest >> dbt_test