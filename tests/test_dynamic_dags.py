import sys
from pathlib import Path
import pytest
from airflow.models import DagBag

@pytest.fixture(scope="session")
def dagbag():
    dags_path = str((Path(__file__).parent.parent / "dags").resolve())
    sys.path.insert(0, dags_path)

    # Generate dynamic DAGs before creating the DagBag
    # dynamic_dag_generator.generate_dags()

    yield DagBag(dag_folder=dags_path, include_examples=False)


def test_no_import_errors(dagbag):
    """Test if there are any import errors"""
    assert dagbag.import_errors == {}, f"Import errors found in the following DAGs: {dagbag.import_errors}"


def test_requires_tags(dagbag):
    """Test if tags are available"""
    failing_dags = {}
    for dag_id, dag in dagbag.dags.items():
        if not dag.tags:
            failing_dags[dag_id] = "Missing tags"
    assert not failing_dags, f"The following DAGs are missing tags: {failing_dags}"


def test_requires_specific_tag(dagbag):
    """Test if there are any required tags"""
    required_tag = "environment"
    failing_dags = {}
    for dag_id, dag in dagbag.dags.items():
        if required_tag not in dag.tags:
            failing_dags[dag_id] = f"Missing required tag: '{required_tag}'"
    assert not failing_dags, f"The following DAGs are missing the '{required_tag}' tag: {failing_dags}"


def test_owner_not_airflow(dagbag):
    """Test if there is a owner for the dag except 'airflow'"""
    failing_dags = {}
    for dag_id, dag in dagbag.dags.items():
        if str.lower(dag.owner) == "airflow":
            failing_dags[dag_id] = "Owner is 'airflow'"
    assert not failing_dags, f"The following DAGs have the owner set to 'airflow': {failing_dags}"


def test_no_emails_on_failure(dagbag):
    """Test if there are email_on_failure configured"""
    failing_dags = {}
    for dag_id, dag in dagbag.dags.items():
        if "email_on_failure" in dag.default_args and dag.default_args["email_on_failure"]:
            failing_dags[dag_id] = "email_on_failure is configured"
    assert not failing_dags, f"The following DAGs have 'email_on_failure' configured: {failing_dags}"


def test_three_or_less_retries(dagbag):
    """Test if there are 3 or less retries"""
    max_retries = 3
    failing_dags = {}
    for dag_id, dag in dagbag.dags.items():
        if "retries" not in dag.default_args or dag.default_args["retries"] > max_retries:
            failing_dags[dag_id] = f"Has more than {max_retries} retries or 'retries' is not defined"
    assert not failing_dags, f"The following DAGs have more than {max_retries} retries or 'retries' is not defined: {failing_dags}"


def test_dag_id_contains_prefix(dagbag):
    """Test if there is a required prefix or not"""
    required_prefix = "__"
    failing_dags = {}
    for dag_id, dag in dagbag.dags.items():
        if str.lower(dag_id).find(required_prefix) == -1:
            failing_dags[dag_id] = f"DAG ID does not contain the required prefix: '{required_prefix}'"
    assert not failing_dags, f"The following DAG IDs do not contain the required prefix '{required_prefix}': {failing_dags}"
