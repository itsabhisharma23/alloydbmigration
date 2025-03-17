from dags import dynamic_dag_generator  # Import the DAG generator
import unittest
from airflow.models import DagBag
import sys
import os

# Add necessary environment variables for Airflow
os.environ['AIRFLOW_HOME'] = os.path.abspath(os.path.join(os.path.dirname(__file__), '..')) #set airflow home
os.environ['AIRFLOW__CORE__DAGS_FOLDER'] = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'dags')) #set dags folder

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'dags'))) #Add the dags folder to the path


class TestDynamicDags(unittest.TestCase):

    def setUp(self):
        # Generate dynamic DAGs before each test
        dynamic_dag_generator.generate_dags()
        self.dagbag = DagBag(dag_folder=os.environ['AIRFLOW__CORE__DAGS_FOLDER']) #Use the environment variable.

    def test_import_dags(self):
        errors = self.dagbag.import_errors
        if errors:
            for filepath, error in errors.items():
                print(f"Error importing DAG file {filepath}: {error}") #print specific errors.
        self.assertFalse(errors, 'DAG import failures. Errors: {}'.format(errors))


if __name__ == '__main__':
    unittest.main()
