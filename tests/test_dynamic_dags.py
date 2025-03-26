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
    """Test if dagbag is non-empty"""
    assert dagbag.size() > 0, "Dagbag should not be empty."
    
def test_no_import_errors(dag_bag):
    """Test if there are any import errors"""
    assert not dag_bag.import_errors


def test_requires_tags(dag_bag):
    """Test if tags are available"""
    for dag_id, dag in dag_bag.dags.items():
        assert dag.tags


def test_requires_specific_tag(dag_bag):
    """Test if there are any required tags"""
    for dag_id, dag in dag_bag.dags.items():
        assert dag.tags.index("environment") >= 0


def test_owner_not_airflow(dag_bag):
    """Test if there is a owner for the dag except 'airflow'"""
    for dag_id, dag in dag_bag.dags.items():
        assert str.lower(dag.owner) != "airflow"
        

def test_no_emails_on_failure(dag_bag):
    """Test if there are email_on_failure configured"""
    for dag_id, dag in dag_bag.dags.items():
        assert not dag.default_args["email_on_failure"]


def test_three_or_less_retries(dag_bag):
    """Test if there are 3 or less retries"""
    for dag_id, dag in dag_bag.dags.items():
        assert dag.default_args["retries"] <= 3


def test_dag_id_contains_prefix(dag_bag):
    """Test if there is a required prefix or not"""
    for dag_id, dag in dag_bag.dags.items():
        assert str.lower(dag_id).find("__") != -1


def test_dag_id_requires_specific_prefix(dag_bag):
    for dag_id, dag in dag_bag.dags.items():
        assert str.lower(dag_id).startswith("data_lake__") \
               or str.lower(dag_id).startswith("redshift_demo__")
