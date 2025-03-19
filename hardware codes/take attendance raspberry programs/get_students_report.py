import serial
import time
from datetime import datetime

# Configure your serial port here
PORT = 'COM14'  # Replace with your port (e.g., '/dev/ttyUSB0' on Linux, 'COMx' on Windows)
BAUD_RATE = 115200  # Match this with your device's baud rate

def is_within_time_range():
    """Check if the current time is between 6:10 and 15:20."""
    now = datetime.now()
    start_time = now.replace(hour=8, minute=00, second=0, microsecond=0)
    end_time = now.replace(hour=23, minute=26, second=0, microsecond=0)
    return start_time <= now <= end_time

try:
    # Open the serial connection
    ser = serial.Serial(PORT, BAUD_RATE, timeout=1)
    print(f"Connected to {PORT} at {BAUD_RATE} baud.")
    
    # Wait a bit for the connection to stabilize
    time.sleep(2)

    # Open the log file before starting the loop
    log_file = open("serial_output.txt", "w")

    print("Listening to the serial port... Press Ctrl+C to exit.")
    while True:
        if not is_within_time_range():
            print("Current time is outside the allowed range (6:10 to 15:20). Exiting.")
            break

        if ser.in_waiting:  # Check if there's data in the buffer
            line = ser.readline().decode('utf-8').strip()  # Read and decode the line
            timestamp = datetime.now().strftime('%H:%M:%S')  # Get the current timestamp
            log_entry = f"{timestamp} {line}"  # Add timestamp to the log entry
            print(log_entry)  # Print the received data with timestamp
            log_file.write(log_entry + "\n")  # Write the data to the log file

except serial.SerialException as e:
    print(f"Error: {e}")
except KeyboardInterrupt:
    print("\nExiting...")
finally:
    if 'ser' in locals() and ser.is_open:
        ser.close()  # Ensure the port is closed on exit
        log_file.close()  # Close the log file
        print("Serial port closed and log file saved.")
