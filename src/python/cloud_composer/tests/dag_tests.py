
import sys
from pathlib import Path
import pytest
from airflow.models import DagBag

@pytest.fixture(scope="session")
def dagbag():
    dags_path = str((Path(__file__).parent.parent / "src/python/cloud_composer/dags").resolve())
    sys.path.insert(0, dags_path)

    # Generate dynamic DAGs before creating the DagBag
    #dynamic_dag_generator.generate_dags()

    yield DagBag(dag_folder=dags_path, include_examples=False)

    
def test_no_import_errors(dagbag):
    """Test if there are any import errors"""
    assert dagbag.import_errors == {}, "No import errors should be found."


def test_requires_tags(dagbag):
    """Test if tags are available"""
    for dag_id, dag in dagbag.dags.items():
        assert dag.tags


def test_requires_specific_tag(dagbag):
    """Test if there are any required tags"""
    for dag_id, dag in dagbag.dags.items():
        assert dag.tags.index("environment") >= 0


def test_owner_not_airflow(dagbag):
    """Test if there is a owner for the dag except 'airflow'"""
    for dag_id, dag in dagbag.dags.items():
        assert str.lower(dag.owner) != "airflow"
        

def test_no_emails_on_failure(dagbag):
    """Test if there are email_on_failure configured"""
    for dag_id, dag in dagbag.dags.items():
        assert not dag.default_args["email_on_failure"]


def test_three_or_less_retries(dagbag):
    """Test if there are 3 or less retries"""
    for dag_id, dag in dagbag.dags.items():
        assert dag.default_args["retries"] <= 3


def test_dag_id_contains_prefix(dagbag):
    """Test if there is a required prefix or not"""
    for dag_id, dag in dagbag.dags.items():
        assert str.lower(dag_id).find("__") != -1
