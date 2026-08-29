import mysql.connector
import pandas as pd


def get_connection():
    """Establishes connection to the MySQL supply chain database."""
    return mysql.connector.connect(
        host="localhost",
        user="root",
        password="stephen0111301468",
        database="supply_chain_optimizer",
    )


def load_data(query: str) -> pd.DataFrame:
    """Executes a SQL query and returns the results as a Pandas DataFrame."""
    conn = get_connection()
    df = pd.read_sql(query, conn)
    conn.close()
    return df


# Quick test execution when running db.py directly
if __name__ == "__main__":
    print("Testing database connection...")
    test_df = load_data("SELECT * FROM vw_shipment_details LIMIT 3;")
    print("Connection successful! Sample data retrieved:")
    print(test_df)