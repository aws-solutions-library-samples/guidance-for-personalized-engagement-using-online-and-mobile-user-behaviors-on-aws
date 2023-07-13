from datetime import datetime, timedelta

from airflow import DAG
from airflow_dbt.operators.dbt_operator import DbtRunOperator
import pendulum

from common import *

conn_id_name = 'redshift_default'

# Default settings applied to all tasks
default_args = {
    'owner': 'airflow',
    'start_date': datetime(2023, 6, 1, tzinfo=pendulum.timezone("Asia/Shanghai")),
    'retries': 0,
    'retry_delay': timedelta(minutes=5)
}

dag = DAG(
    dag_id='rudder_incr_refresh_dag',
    schedule_interval=INCR_SCHEDULE,
    dagrun_timeout=timedelta(minutes=120),
    default_args=default_args,
    max_active_runs=1,
    catchup=False
)

# This runs the transformation steps in the dbt pipeline
dbt_run = DbtRunOperator(
    task_id='dbt_run',
    dir=DBT_PROJECT_DIR,
    profiles_dir=TRANSFORM_DIR,
    target=DBT_TARGET,
    dag=dag,
    vars={}
)

dbt_run
