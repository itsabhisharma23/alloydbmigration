from dags import dynamic_dag_generator  # Import the DAG generator
# Purpose: Pytest test for Data Lake and Redshift
#          Airflow Demonstration project DAGs
# Author: Gary A. Stafford
# Modified: 2021-12-10

import os
import sys

import pytest
from airflow.models import DagBag

sys.path.append(os.path.join(os.path.dirname(__file__), "../dags"))
sys.path.append(os.path.join(os.path.dirname(__file__), "../dags/utilities"))

# Airflow variables called from DAGs under test are stubbed out
os.environ["AIRFLOW_VAR_DATA_LAKE_BUCKET"] = "test_bucket"
os.environ["AIRFLOW_VAR_ATHENA_QUERY_RESULTS"] = "SELECT 1;"
os.environ["AIRFLOW_VAR_SNS_TOPIC"] = "test_topic"
os.environ["AIRFLOW_VAR_REDSHIFT_UNLOAD_IAM_ROLE"] = "test_role_1"
os.environ["AIRFLOW_VAR_GLUE_CRAWLER_IAM_ROLE"] = "test_role_2"


@pytest.fixture(params=["../dags/"])
def dag_bag(request):
    dynamic_dag_generator.generate_dags()
    return DagBag(dag_folder=request.param, include_examples=False)

def test_dagbag_not_empty(dagbag):
    for dag in dagbag.dags.values():
        print(dag.dag_id)
    assert dagbag.size() > 0, "Dagbag should not be empty."
    
def test_dagbag_no_import_errors(dagbag):
    assert dagbag.import_errors == {}, "No import errors should be found."

    




