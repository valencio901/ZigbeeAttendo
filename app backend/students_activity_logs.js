// Import necessary libraries
const WebSocket = require('ws');
const mysql = require('mysql2');
const dotenv = require('dotenv');

// Load environment variables from .env file (if needed for database credentials)
dotenv.config();

// Setup WebSocket server
const wss = new WebSocket.Server({ port: 8081 });

wss.on('connection', (ws) => {
    console.log("New WebSocket client connected.");

    // Send a message to the client when it connects
    ws.send(JSON.stringify({ message: 'Connected to WebSocket server' }));
});

// List of databases to monitor
const databases = ['tybca_a']; // Replace with your actual database names

// MySQL connection configuration for multiple databases
const dbConfig = {
    host: 'localhost',
    user: 'root',
    password: '',  // Replace with your MySQL password
};

let lastCheckedTime = {};  // To store last checked time for each database

// Function to check and send new log entries from each database
function checkDatabaseLogs() {
    databases.forEach((database) => {
        const connection = mysql.createConnection({ ...dbConfig, database });

        connection.connect((err) => {
            if (err) {
                console.error(`Error connecting to database ${database}: ${err.stack}`);
                return;
            }

            console.log(`Connected to database: ${database}`);

            // Set the last checked time for the database if not already set
            if (!lastCheckedTime[database]) {
                lastCheckedTime[database] = new Date();
            }

            // Query for new logs after the last checked time
            const query = `
                SELECT * FROM students_activity_logs
                WHERE timestamp > ?
                ORDER BY timestamp DESC
            `;

            connection.query(query, [lastCheckedTime[database]], (err, results) => {
                if (err) {
                    console.error(`Error querying database ${database}: ${err.stack}`);
                    return;
                }

                // If there are new logs, send them to all connected clients
                if (results.length > 0) {
                    // Update the last checked time to the latest timestamp in the results
                    lastCheckedTime[database] = results[0].timestamp;

                    // Broadcast the new logs to all WebSocket clients
                    wss.clients.forEach((client) => {
                        if (client.readyState === WebSocket.OPEN) {
                            client.send(JSON.stringify({
                                database,
                                logs: results,
                            }));
                        }
                    });
                }
            });

            // Close the connection after the query is executed
            connection.end();
        });
    });
}

// Function to start monitoring logs every second
function startMonitoring() {
    setInterval(() => {
        checkDatabaseLogs();  // Check for new logs every second
    }, 1000);
}

// Start monitoring when the server starts
startMonitoring();

console.log("WebSocket server running on ws://localhost:8081");
