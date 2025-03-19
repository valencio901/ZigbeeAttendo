import mysql.connector
import re
from datetime import datetime

# List of databases
databases = ['tybca_a']

# Database configuration
db_config = {
    'host': 'localhost',
    'user': 'root',
    'password': '',  # Update with actual password
}

# Establish connection to MySQL
def connect_to_db(database):
    conn = mysql.connector.connect(**db_config, database=database)
    return conn

# Fetch roll numbers based on batch
def fetch_rollnos_by_batch(conn, batch=None):
    cursor = conn.cursor()
    if batch is not None:
        cursor.execute("SELECT rollno FROM rollnos WHERE batch = %s;", (batch,))
    else:
        cursor.execute("SELECT rollno FROM rollnos;")
    rollnos = cursor.fetchall()
    return [r[0] for r in rollnos]

# Parse the serial_output.txt file for entry and exit times
def parse_serial_output(file_path):
    entries_exits = {}
    with open(file_path, 'r') as file:
        for line in file:
            time_match = re.match(r'(\d{2}:\d{2}:\d{2}) class (\w+) rollno (\d+) (entered|exited) the class', line)
            if time_match:
                time_str, class_name, rollno, action = time_match.groups()
                time_obj = datetime.strptime(time_str, '%H:%M:%S').time()

                if (class_name, rollno) not in entries_exits:
                    entries_exits[(class_name, rollno)] = {'entered': None, 'exited': None}

                if action == 'entered':
                    entries_exits[(class_name, rollno)]['entered'] = time_obj
                elif action == 'exited':
                    entries_exits[(class_name, rollno)]['exited'] = time_obj

    return entries_exits

# Fetch lecture data from the correct database
def fetch_lectures(conn):
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM monday;")
    lectures = cursor.fetchall()
    return lectures

# Insert attendance into the database
def insert_attendance(conn, rollno, status, lecture_name, teacher, start_time, end_time, classroom):
    cursor = conn.cursor()
    query = """
        INSERT INTO attendance (rollno, attendance, date, weekday, subject, teacher, time, classroom)
        VALUES (%s, %s, CURDATE(), DAYNAME(CURDATE()), %s, %s, CONCAT(%s, ' to ', %s), %s)
    """
    cursor.execute(query, (rollno, status, lecture_name, teacher, start_time, end_time, classroom))
    conn.commit()

# Compare entry/exit times with lecture times and update attendance in the correct database
def check_attendance(entries_exits):
    db_connections = {}

    try:
        # Connect to all databases
        for db in databases:
            db_connections[db] = connect_to_db(db)

        # Fetch all lectures from databases
        lectures_data = {db: fetch_lectures(db_connections[db]) for db in databases}

        # Fetch roll numbers grouped by batch for databases
        rollnos_data = {
            db: {
                None: fetch_rollnos_by_batch(db_connections[db]),  # All roll numbers
                1: fetch_rollnos_by_batch(db_connections[db], 1),
                2: fetch_rollnos_by_batch(db_connections[db], 2)
            } for db in databases
        }

        # Process each database
        for database in databases:
            lectures = lectures_data[database]
            eligible_rollnos = rollnos_data[database]
            present_students = set()

            # Process each lecture
            for lecture in lectures:
                lecture_name, start_time, end_time, teacher, classroom, lecture_batch, _, lecture_type = lecture
                start_time = datetime.strptime(str(start_time), '%H:%M:%S').time()
                end_time = datetime.strptime(str(end_time), '%H:%M:%S').time()

                # ✅ Ensure batch filtering is applied for lab lectures
                if lecture_type == 'lab':
                    if lecture_batch is not None:  # Ensure lab batch is valid
                        valid_rollnos = eligible_rollnos.get(int(lecture_batch), [])  # Fetch students only from the correct batch
                    else:
                        valid_rollnos = []  # No valid students if batch is undefined
                else:
                    valid_rollnos = eligible_rollnos[None]  # All students for normal lectures

                # Check who is present
                for (class_name, rollno), times in entries_exits.items():
                    if class_name == database and int(rollno) in valid_rollnos:
                        entered = times['entered']
                        exited = times['exited']

                        if entered and exited and entered <= start_time and exited >= end_time:
                            present_students.add(int(rollno))
                            insert_attendance(db_connections[database], rollno, 'Present', lecture_name, teacher, start_time, end_time, classroom)

                # Now, mark absent students
                for rollno in valid_rollnos:
                    if rollno not in present_students:
                        insert_attendance(db_connections[database], rollno, 'Absent', lecture_name, teacher, start_time, end_time, classroom)

        print("Attendance (present & absent) has been updated correctly.")

    finally:
        # Close database connections
        for conn in db_connections.values():
            conn.close()

# Main function to execute the program
def main():
    entries_exits = parse_serial_output('serial_output.txt')
    check_attendance(entries_exits)

if __name__ == '__main__':
    main()
