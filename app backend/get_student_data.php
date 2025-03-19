<?php
// Get the incoming JSON data from the request
$data = json_decode(file_get_contents("php://input"));

// Extract the class and rollno from the request
$class = $data->class;
$rollno = $data->rollno;

// Set up the connection to MySQL
$servername = "localhost";  // Replace with your server details
$username = "root";         // Replace with your MySQL username
$password = "";             // Replace with your MySQL password
$port = "3306";             // Replace with your port if needed

// Dynamically set the database based on the class value
$dbname = $class; // This will be the name of the class passed from the Flutter app

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname, $port);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Prepare the query to fetch student data
$query = "SELECT * FROM students WHERE rollno = ?";
$stmt = $conn->prepare($query);
$stmt->bind_param("s", $rollno); // Bind the rollno parameter

$stmt->execute();
$result = $stmt->get_result();

// Check if student exists
if ($result->num_rows > 0) {
    $student = $result->fetch_assoc();
    // Return success status with student data
    echo json_encode([
        'status' => 'success',
        'student' => [
            'name' => $student['name'],
            'classroom' => $student['classroom'],
            'college' => $student['college'],
        ]
    ]);
} else {
    // Return error if no student is found
    echo json_encode([
        'status' => 'error',
        'message' => 'Student not found.'
    ]);
}

$stmt->close();
$conn->close();
?>
