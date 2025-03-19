import mysql.connector
import re
from datetime import datetime

# Connect to MySQL
db = mysql.connector.connect(
    host="localhost",        # Replace with your host
    user="root",             # Replace with your username
    password="",             # Replace with your password
    database="tybca_a"       # Replace with your database
)
cursor = db.cursor()

# Fetch roll numbers from the students table
cursor.execute("SELECT rollno FROM rollnos")
student_rollnos = {row[0] for row in cursor.fetchall()}  # Store roll numbers in a set for quick lookup

# Read the serial_output.txt file
with open("serial_output.txt", "r") as file:
    logs = file.readlines()

# Extract roll numbers and their entry/exit times
student_logs = {}
entry_pattern = re.compile(r"\[(.*?)\] rollno (\d+) entered the class")
exit_pattern = re.compile(r"\[(.*?)\] rollno (\d+) exited the class")

for line in logs:
    entry_match = entry_pattern.search(line)
    exit_match = exit_pattern.search(line)
    
    if entry_match:
        timestamp, rollno = entry_match.groups()
        rollno = int(rollno)
        if rollno in student_rollnos:  # Only consider roll numbers from the students table
            student_logs.setdefault(rollno, []).append(("entry", datetime.strptime(timestamp, "%Y-%m-%d %H:%M:%S")))
    
    if exit_match:
        timestamp, rollno = exit_match.groups()
        rollno = int(rollno)
        if rollno in student_rollnos:  # Only consider roll numbers from the students table
            student_logs.setdefault(rollno, []).append(("exit", datetime.strptime(timestamp, "%Y-%m-%d %H:%M:%S")))

# Get the current weekday
current_weekday = datetime.today().strftime('%A')

# Fetch lecture timings and teacher names for the current weekday
query = f"SELECT lecture, start_time, end_time, teacher, classroom FROM {current_weekday}"
cursor.execute(query)
lectures = cursor.fetchall()

# Compare entry/exit times with the lecture times and determine attendance
for rollno in student_rollnos:  # Iterate through roll numbers from students table
    times = student_logs.get(rollno, [])  # Get log times if available
    times.sort(key=lambda x: x[1])  # Sort by timestamp

    for lecture, start_time, end_time, teacher, classroom in lectures:
        start_time = datetime.strptime(str(start_time), "%H:%M:%S").time()
        end_time = datetime.strptime(str(end_time), "%H:%M:%S").time()
        start_time_str = start_time.strftime("%H:%M")
        end_time_str = end_time.strftime("%H:%M")
        t = f"{start_time_str}-{end_time_str}"
        
        present = False

        for i in range(0, len(times), 2):  # Loop through pairs of entry and exit times
            if i + 1 < len(times):
                entry_time = times[i][1].time()
                exit_time = times[i + 1][1].time()

                # Check if entry time is before or equal to the lecture start time
                # and exit time is after or equal to the lecture end time
                if entry_time <= start_time and exit_time >= end_time:
                    present = True
                    break
        
        # Insert attendance record into the database
        attendance_status = "Present" if present else "Absent"
        query = """
        INSERT INTO attendance (rollno, attendance, subject, teacher, time, classroom)
        VALUES (%s, %s, %s, %s, %s, %s)
        """
        cursor.execute(query, (rollno, attendance_status, lecture, teacher, t, classroom))

# Commit changes to the database
db.commit()

# Close the database connection
cursor.close()
db.close()
