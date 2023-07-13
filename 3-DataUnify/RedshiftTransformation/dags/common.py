import os

# These could be set with environment variables if you want to run the DAG outside the Astro container
PROJECT_HOME = '/opt/airflow'
TRANSFORM_DIR = os.path.join(PROJECT_HOME, 'transform')
DBT_PROJECT_DIR = os.path.join(TRANSFORM_DIR, 'rudder-ecommerce')
DBT_TARGET = 'prod'
DBT_TARGET_DIR = os.path.join(DBT_PROJECT_DIR, 'target')
DBT_DOCS_DIR = os.path.join(PROJECT_HOME, 'include', 'dbt_docs')

INCR_SCHEDULE = '10 10-22/4 * * *'
FULL_SCHEDULE = '15 3 * * *'

TASK_RETRIES = 1

TARGET_SCHEMA = 'dbt_etl'