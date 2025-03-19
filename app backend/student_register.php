<?php
// Set content type to JSON
header('Content-Type: application/json');

// Get input data
$rollno = $_POST['rollno'];
$name = $_POST['name'];
$password = $_POST['password'];
$class = $_POST['class'];
$classroom = $_POST['classroom'];
$college = $_POST['college'];

// Establish database connection
$servername = "localhost"; // Your database host
$username = "root"; // Your database username
$password = ""; // Your database password (if any)
$dbname = $class; // Use class as database name

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die(json_encode(['error' => 'Connection failed: ' . $conn->connect_error]));
}

// Prepare and bind statement
$stmt = $conn->prepare("INSERT INTO students (rollno, name, password, classroom, college) VALUES (?, ?, ?, ?, ?)");
$stmt->bind_param("issss", $rollno, $name, $password, $classroom, $college);

// Execute statement
if ($stmt->execute()) {
    echo json_encode(['success' => 'Record inserted successfully']);
} else {
    echo json_encode(['error' => 'Failed to insert record']);
}

// Close connection
$stmt->close();
$conn->close();
?>
