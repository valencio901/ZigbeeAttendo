import mysql.connector
import pandas as pd
from openpyxl import Workbook
from calendar import month_name

# List of databases
databases = ['tybca_a']

# Database connection settings
db_config = {
    'user': 'root',
    'password': '',
    'host': 'localhost',
    'database': ''
}

# Function to get attendance data from the database for each month
# Function to get attendance data from the database for each month
def get_attendance_data(database):
    db_config['database'] = database
    conn = mysql.connector.connect(**db_config)
    cursor = conn.cursor()

    # SQL query to get attendance data grouped by month and year
    query = """
    SELECT rollno, date, attendance
    FROM attendance
    WHERE YEAR(date) = YEAR(CURDATE())  -- get data for the current year
    ORDER BY date
    """

    cursor.execute(query)
    rows = cursor.fetchall()

    # Create a DataFrame to organize the data
    df = pd.DataFrame(rows, columns=['rollno', 'date', 'attendance'])

    # Convert the 'date' column to datetime format
    df['date'] = pd.to_datetime(df['date'])

    # Extract month name and create a new column for it
    df['month'] = df['date'].dt.month.apply(lambda x: month_name[x])

    cursor.close()
    conn.close()

    return df

# Function to save attendance data to an Excel file for each month
def save_to_excel(database, df):
    # Group data by month
    months = df['month'].unique()
    
    with pd.ExcelWriter(f'{database.lower()}_attendance.xlsx', engine='openpyxl') as writer:
        for month in months:
            month_data = df[df['month'] == month]
            # Write each month data to a separate sheet
            month_data.drop(columns=['month'], inplace=True)  # drop the month column
            month_data.to_excel(writer, sheet_name=month, index=False)

# Main execution loop to process each database
for db in databases:
    print(f"Processing data for database: {db}")
    df = get_attendance_data(db)
    save_to_excel(db, df)
    print(f"Attendance data for {db} has been saved.")
