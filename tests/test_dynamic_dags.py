from dags import dynamic_dag_generator  # Import the DAG generator
import sys
from pathlib import Path

import pytest
from airflow.models import DagBag


@pytest.fixture(scope="session")
def dagbag():
    dags_path = str((Path(__file__).parent.parent / "dags").resolve())
    sys.path.insert(0, dags_path)

    # Generate dynamic DAGs before creating the DagBag
    dynamic_dag_generator.generate_dags()

    yield DagBag(dag_folder=dags_path, include_examples=False)

def test_dagbag_not_empty(dagbag):
    print("Testing DAGs: Ensuring dagbag is not empty")
    assert dagbag.size() > 0, "Dagbag should not be empty."

def test_dagbag_no_import_errors(dagbag):
    print("Testing DAGs: Ensuring no import errors")
    assert dagbag.import_errors == {}, "No import errors should be found."
