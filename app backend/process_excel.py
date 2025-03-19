import pandas as pd
import mysql.connector
import sys

def process_excel(file_path):
    try:
        # Read the Excel file
        df = pd.read_excel(file_path)
        print("Excel file loaded successfully!")

        # Connect to the MySQL database
        connection = mysql.connector.connect(
            host="localhost",      # Your database host
            user="root",           # Your database username
            password="",           # Your database password
            database="tybca_a"     # Your database name
        )
        cursor = connection.cursor()

        # Step 1: Delete all records from 'monday' before inserting new data
        delete_query = "DELETE FROM monday"
        cursor.execute(delete_query)
        connection.commit()
        print("All existing records deleted from 'monday'.")

        # Step 2: Insert new data into 'monday'
        insert_query = """
            INSERT INTO monday (lecture, start_time, end_time, teacher, classroom, batch, id, type)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
        """

        for index, row in df.iterrows():
            cursor.execute(insert_query, (row['lecture'], row['start_time'], row['end_time'], 
                                          row['teacher'], row['classroom'], row['batch'], 
                                          row['id'], row['type']))
            print(f"Inserted: {row['lecture']}")

        connection.commit()  # Commit all inserts at once
        print("Database insertion completed!")

        # Step 3: Log the insertion action into changes_log
        log_query = """
            INSERT INTO changes.changes_log (database_name, table_name, action)
            VALUES (%s, %s, %s)
        """
        cursor.execute(log_query, ('tybca_a', 'monday', 'insert'))
        connection.commit()
        print("Insertion logged in 'changes_log'.")

        # Close connections
        cursor.close()
        connection.close()
        print("Database connection closed.")

    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    # Get the file path from the command line argument
    file_path = sys.argv[1]
    process_excel(file_path)
