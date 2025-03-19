import mysql.connector
from datetime import datetime, timedelta

# Function to parse teacher entry/exit logs from serial_output.txt
def parse_serial_output(file_path):
    teacher_logs = {}

    with open(file_path, "r") as file:
        for line in file:
            parts = line.strip().split(" ")
            if len(parts) >= 5 and parts[1] == "teacher":
                time_str = parts[0]  # Time of entry/exit
                teacher_name = " ".join(parts[2:4])  # Extract full teacher name
                action = parts[4]  # 'entered' or 'exited'

                entry_time = datetime.strptime(time_str, "%H:%M:%S").time()

                if teacher_name not in teacher_logs:
                    teacher_logs[teacher_name] = {"entry": None, "exit": None}
                
                if action == "entered":
                    teacher_logs[teacher_name]["entry"] = entry_time
                elif action == "exited":
                    teacher_logs[teacher_name]["exit"] = entry_time

    print("Parsed Teacher Logs:", teacher_logs)  # Debugging Output
    return teacher_logs

# Function to check attendance
def check_attendance(db_name, db_conn, teacher_logs, teachers_db_conn):
    cursor = db_conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM monday")  # Fetch lecture schedule
    lectures = cursor.fetchall()
    
    for lecture in lectures:
        teacher = lecture["teacher"]
        start_time = lecture["start_time"]
        end_time = lecture["end_time"]
        
        # Convert timedelta to time if necessary
        if isinstance(start_time, timedelta):  
            start_time = (datetime.min + start_time).time()
        if isinstance(end_time, timedelta):  
            end_time = (datetime.min + end_time).time()
        
        if teacher in teacher_logs:
            entry_time = teacher_logs[teacher]["entry"]
            exit_time = teacher_logs[teacher]["exit"]
            
            # Debugging logs
            print(f"\nChecking {teacher}:")
            print(f"Lecture: {lecture['lecture']} ({start_time} - {end_time})")
            print(f"Entry Time: {entry_time}, Exit Time: {exit_time}")
            
            if entry_time and exit_time and entry_time <= start_time and exit_time >= end_time:
                print(f"✅ Marking {teacher} as Present for {lecture['lecture']}")
                
                # Insert attendance into `teachers.teacherattendance`
                attendance_cursor = teachers_db_conn.cursor()
                attendance_cursor.execute(
                    "INSERT INTO teacherattendance (teacherName, Attendance, Lecture, classroom, start_time, end_time, class) "
                    "VALUES (%s, %s, %s, %s, %s, %s, %s)",
                    (teacher, "Present", lecture["lecture"], lecture["classroom"], start_time, end_time, db_name)
                )
                teachers_db_conn.commit()
                attendance_cursor.close()
            else:
                attendance_cursor = teachers_db_conn.cursor()
                attendance_cursor.execute(
                    "INSERT INTO teacherattendance (teacherName, Attendance, Lecture, classroom, start_time, end_time, class) "
                    "VALUES (%s, %s, %s, %s, %s, %s, %s)",
                    (teacher, "Absent", lecture["lecture"], lecture["classroom"], start_time, end_time, db_name)
                )
                teachers_db_conn.commit()
                attendance_cursor.close()
                print(f"❌ {teacher} did not meet attendance criteria.")

    cursor.close()

# Main function
def main():
    serial_output_file = "serial_output.txt"
    teacher_logs = parse_serial_output(serial_output_file)  # Parse teacher logs

    # Database Configuration
    db_config = {
        "host": "localhost",
        "user": "root",
        "password": ""
    }
    
    databases_to_check = ["tybca_a"]  # List of databases to check
    
    # Connect to `teachers` database for storing attendance
    teachers_db_conn = mysql.connector.connect(database="teachers", **db_config)
    
    for db_name in databases_to_check:
        db_conn = mysql.connector.connect(database=db_name, **db_config)
        check_attendance(db_name, db_conn, teacher_logs, teachers_db_conn)
        db_conn.close()
    
    teachers_db_conn.close()
    
    print("\n✅ Attendance processing complete.")

if __name__ == "__main__":
    main()
