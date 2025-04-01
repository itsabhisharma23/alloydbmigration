from airflow import DAG
from airflow.operators.bash import BashOperator
from datetime import datetime
from airflow.utils.dates import days_ago


def generate_dags():
    default_args = {
        'owner': 'airflow',
        'start_date': days_ago(1),
    }

    items = ['item1', 'item2', 'item3']

    dag = DAG(
        dag_id='dynamic_example',
        default_args=default_args,
        schedule_interval=None,
        tags=["environment"],
        catchup=False,
    )

    with dag:
        for item in items:
            task = BashOperator(
                task_id=f'process_{item}',
                bash_command=f'echo "Processing {item}"',
            )

    globals()[dag.dag_id] = dag

generate_dags() #important, call the function to generate the dags.
