from airflow import DAG
from airflow.operators.bash import BashOperator
from datetime import datetime
from airflow.utils.dates import days_ago
default_args = {
    'owner': 'abhishek',
    'start_date': days_ago(1),
}

with DAG(
    dag_id='static_example',
    default_args=default_args,
    schedule_interval=None,
    tags=["environment"],
    catchup=False,
) as dag:
    task_1 = BashOperator(
        task_id='process_item1',
        bash_command='echo "Processing item1"',
    )

    task_2 = BashOperator(
        task_id='process_item2',
        bash_command='echo "Processing item2"',
    )

    task_3 = BashOperator(
        task_id='process_item3',
        bash_command='echo "Processing item3"',
    )

    # Define task dependencies (optional, but good practice)
    task_1 >> task_2 >> task_3
