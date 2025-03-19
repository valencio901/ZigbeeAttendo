<?php
// Database configuration
$servername = "localhost";
$username = "root";
$password = "";

$className = isset($_POST['className']) ? $_POST['className'] : 'default_class';  // Default class if not provided

$dbName = str_replace(" ", "_", $className);

// Create connection
$conn = new mysqli($servername, $username, $password, $dbName);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Get POST data
$day = $_POST['day']; // e.g., 'monday'
$id = $_POST['id']; // ID of the row to delete

// SQL to delete the timetable row
$sql = "DELETE FROM $day WHERE id=$id";

if ($conn->query($sql) === TRUE) {
    echo json_encode(['status' => 'success']);
} else {
    echo json_encode(['status' => 'error', 'message' => $conn->error]);
}

$conn->close();
?>
