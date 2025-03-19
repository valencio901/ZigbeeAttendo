const WebSocket = require('ws');
const mysql = require('mysql2');

// Create WebSocket Server
const wss = new WebSocket.Server({ port: 8080 });
console.log("✅ WebSocket server running on ws://localhost:8080");

// Connect to MySQL Database
const db = mysql.createConnection({
    host: "localhost",
    user: "root",
    password: "",
    database: "changes"  // The database storing the change logs
});

db.connect(err => {
    if (err) {
        console.error("❌ Database connection error:", err);
        return;
    }
    console.log("✅ Connected to MySQL database.");
});

let lastProcessedId = 0;  // Stores the last processed ID

// Function to check for new changes
function checkForChanges() {
    db.query("SELECT * FROM changes_log WHERE id > ? ORDER BY id ASC", [lastProcessedId], (err, results) => {
        if (err) {
            console.error("❌ Error fetching changes:", err);
            return;
        }

        if (results.length > 0) {
            results.forEach(change => {
                console.log(`✅ New Change Detected: ${change.database_name}.${change.table_name} - ${change.action} - ${change.teacher} at ${change.changed_at}`);

                // Update last processed ID
                lastProcessedId = change.id;

                // Notify WebSocket clients
                let message = JSON.stringify(change);
                wss.clients.forEach(client => {
                    if (client.readyState === WebSocket.OPEN) {
                        client.send(message);
                    }
                });
            });
        }
    });
}

// Run check every 2 seconds
setInterval(checkForChanges, 2000);

// Handle WebSocket connections
wss.on("connection", ws => {
    console.log("🔌 New WebSocket client connected.");
});
