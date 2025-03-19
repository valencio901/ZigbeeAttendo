import serial
import time
from datetime import datetime
import mysql.connector

# Configure your serial port and database connection
PORT = 'COM14'  # Replace with your port (e.g., '/dev/ttyUSB0' on Linux, 'COMx' on Windows)
BAUD_RATE = 115200  # Match this with your device's baud rate

# MySQL connection
db = mysql.connector.connect(
    host="localhost",      # Replace with your MySQL host if needed
    user="root",           # Your MySQL username
    password="",           # Your MySQL password
    database="your_database"  # The database where your table is created
)
cursor = db.cursor()

def is_within_time_range():
    """Check if the current time is between 6:10 and 15:20."""
    now = datetime.now()
    start_time = now.replace(hour=8, minute=0, second=0, microsecond=0)
    end_time = now.replace(hour=23, minute=26, second=0, microsecond=0)
    return start_time <= now <= end_time

def log_to_db(class_name, rollno, action):
    """Insert log entry into the MySQL database."""
    try:
        timestamp = datetime.now()
        
        # Check if there is already an 'entered' or 'exited' action for the given rollno
        cursor.execute(
            "SELECT * FROM students_activity_logs WHERE rollno = %s AND action = %s ORDER BY timestamp DESC LIMIT 1",
            (rollno, action)
        )
        last_entry = cursor.fetchone()
        
        # If no such action exists, insert the new record
        if not last_entry:
            cursor.execute(
                "INSERT INTO students_activity_logs (class, rollno, action, timestamp) VALUES (%s, %s, %s, %s)",
                (class_name, rollno, action, timestamp)
            )
            db.commit()
            print(f"Log added: {class_name}, Rollno: {rollno}, Action: {action}, Time: {timestamp}")
        else:
            print(f"Duplicate action detected for Rollno {rollno}: {action} not added.")
    
    except mysql.connector.Error as e:
        print(f"Error inserting into database: {e}")

try:
    # Open the serial connection
    ser = serial.Serial(PORT, BAUD_RATE, timeout=1)
    print(f"Connected to {PORT} at {BAUD_RATE} baud.")
    
    # Wait a bit for the connection to stabilize
    time.sleep(2)

    print("Listening to the serial port... Press Ctrl+C to exit.")
    while True:
        if not is_within_time_range():
            print("Current time is outside the allowed range (8:00 to 23:26). Exiting.")
            break

        if ser.in_waiting:  # Check if there's data in the buffer
            line = ser.readline().decode('utf-8').strip()  # Read and decode the line
            timestamp = datetime.now().strftime('%H:%M:%S')  # Get the current timestamp
            print(f"{timestamp} {line}")  # Print the received data
            
            # Check if the line contains "entered" or "exited"
            if "entered" in line:
                class_name = line.split("class")[1].split()[0].strip()
                rollno = int(line.split("rollno")[1].split()[0].strip())
                log_to_db(class_name, rollno, 'entered')
            elif "exited" in line:
                class_name = line.split("class")[1].split()[0].strip()
                rollno = int(line.split("rollno")[1].split()[0].strip())
                log_to_db(class_name, rollno, 'exited')

except serial.SerialException as e:
    print(f"Error: {e}")
except KeyboardInterrupt:
    print("\nExiting...")
finally:
    if 'ser' in locals() and ser.is_open:
        ser.close()  # Ensure the port is closed on exit
        db.close()  # Close the database connection
        print("Serial port closed and database connection closed.")
