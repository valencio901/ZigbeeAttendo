from sqlalchemy import create_engine
import pandas as pd
import datetime

# Get the current weekday
current_day = datetime.datetime.now().strftime('%A').lower()

# Create the SQLAlchemy engine (instead of using mysql.connector directly)
engine = create_engine('mysql+mysqlconnector://root:@localhost/students')

# Query to fetch data from specific columns
query = f"SELECT * FROM {current_day}timetable"

# Fetch the data into a pandas DataFrame using the SQLAlchemy engine
df = pd.read_sql(query, engine)

# Save to Excel
file_path = "tybca_a_attendance.xlsx"

# Open the file and write content, then save it
with pd.ExcelWriter(file_path, engine='xlsxwriter') as writer:
    df.to_excel(writer, index=False)

# Close the connection (SQLAlchemy handles this automatically)
