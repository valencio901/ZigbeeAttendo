<?php
// Set content type to JSON
header('Content-Type: application/json');

// Get input data from POST
$teacher_name = $_POST['teacher_name'];
$phone_number = $_POST['phone_number'];
$address = $_POST['address'];
$password = $_POST['password'];

// Database connection details
$servername = "localhost"; // Database host
$username = "root"; // Database username
$password = ""; // Database password (if any)
$dbname = "teachers"; // Your database name

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die(json_encode(['error' => 'Connection failed: ' . $conn->connect_error]));
}

// Prepare and bind the SQL statement
$stmt = $conn->prepare("INSERT INTO teachers (teacher_name, phone_number, address, password) VALUES (?, ?, ?, ?)");
$stmt->bind_param("ssss", $teacher_name, $phone_number, $address, $password);

// Execute the statement and check if the query was successful
if ($stmt->execute()) {
    echo json_encode(['success' => 'Teacher registered successfully']);
} else {
    echo json_encode(['error' => 'Failed to register teacher']);
}

// Close the prepared statement and database connection
$stmt->close();
$conn->close();
?>
