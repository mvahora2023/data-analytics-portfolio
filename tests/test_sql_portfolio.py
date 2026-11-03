"""Static checks only: not a SQL Server execution test."""
import pathlib, re, unittest
ROOT=pathlib.Path(__file__).resolve().parents[1]
schema=(ROOT/'schema/enterprise_operations_db.sql').read_text(encoding='utf-8')
queries=(ROOT/'queries/analyst_queries.sql').read_text(encoding='utf-8')
cases=(ROOT/'queries/case_study_analysis.sql').read_text(encoding='utf-8')

class SchemaSafetyTests(unittest.TestCase):
    def test_setup_does_not_destroy_database(self):
        self.assertNotRegex(schema,r'(?i)\bDROP\s+DATABASE\b')
        self.assertIn('THROW 50001',schema)
    def test_columns_and_observed_completion_exist(self):
        self.assertIn('Quantity       INT NOT NULL',schema)
        self.assertIn('CompletedDate  DATE',schema)
        self.assertIn('SUM(Quantity * UnitPrice)',schema)
        self.assertIn('proj.CompletedDate',queries)
    def test_queries_do_not_reference_previous_nonexistent_columns(self):
        for text in (queries,cases):
            for expression in [r'\boi\.Qty\b',r'\bd\.DeptID\b',r'\bd\.DeptName\b',
                               r'\be\.DeptID\b',r'\be\.EmpID\b',r'\bproj\.ProjID\b',
                               r'\bproj\.EmpID\b',r'\bc\.Name\b']:
                self.assertNotRegex(text,expression)
    def test_sample_schema_tables(self):
        names=re.findall(r'(?im)^\s*CREATE\s+TABLE\s+(\w+)',schema)
        self.assertEqual(len(names),8) # actual count, not an invented nine
        self.assertEqual(len(set(names)),8)
if __name__ == '__main__': unittest.main()
