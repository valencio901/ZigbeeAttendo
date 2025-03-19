import mysql.connector
import time
import json
from websocket_server import WebsocketServer

# WebSocket server setup
server = WebsocketServer(8080, '192.168.43.61')

# Connect to MySQL (changes database)
db = mysql.connector.connect(
    host="localhost",
    user="root",
    password="",
    database="changes"  # The database storing the change logs
)

# Store the last processed change ID
last_processed_id = None

# Function to check for new changes
def check_for_changes():
    global last_processed_id

    cursor = db.cursor()

    # Fetch the latest record
    cursor.execute("SELECT * FROM changes_log ORDER BY id DESC LIMIT 1")
    result = cursor.fetchone()
    cursor.close()

    if result:
        change_id, database_name, table_name, action, changed_at = result

        # Process only if it's a new change
        if last_processed_id is None or change_id > last_processed_id:
            last_processed_id = change_id  # Update last processed ID

            print(f"✅ New Change: {database_name}.{table_name} - {action} at {changed_at}")

            # Notify WebSocket clients
            message = {
                "database": database_name,
                "table": table_name,
                "action": action,
                "changed_at": str(changed_at)
            }
            server.send_message_to_all(json.dumps(message))

# Continuous monitoring function
def monitor():
    while True:
        check_for_changes()
        time.sleep(2)  # Adjust the polling interval if needed

# Start monitoring
monitor()
