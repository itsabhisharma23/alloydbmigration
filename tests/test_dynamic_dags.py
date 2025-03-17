import unittest
from airflow.models import DagBag
from dags import dynamic_dag_generator  # Import the DAG generator

class TestDynamicDags(unittest.TestCase):

    def setUp(self):
        #Generate dags before testing.
        dynamic_dag_generator.generate_dags()
        self.dagbag = DagBag(dag_folder='./dags') #Adjust path if needed.

    def test_import_dags(self):
        self.assertFalse(
            len(self.dagbag.import_errors),
            'DAG import failures. Errors: {}'.format(self.dagbag.import_errors)
        )

    def test_dynamic_dag_exists(self):
        self.assertIn('dynamic_example', self.dagbag.dags)

    def test_dynamic_dag_tasks(self):
        dag = self.dagbag.get_dag(dag_id='dynamic_example')
        expected_task_ids = ['process_item1', 'process_item2', 'process_item3']
        task_ids = [task.task_id for task in dag.tasks]
        self.assertEqual(sorted(task_ids), sorted(expected_task_ids))

if __name__ == '__main__':
    unittest.main()
