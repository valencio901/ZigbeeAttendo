<?php
// Database credentials
$host = "localhost"; // Change to your database host
$dbname = "teachers"; // Database name
$username = "root"; // Database username
$password = ""; // Database password, change accordingly

// Create a connection to the database
$conn = new mysqli($host, $username, $password, $dbname);

// Check if the connection was successful
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Get the POST data from Flutter
$teacher_name = $_POST['teacher_name'];
$teacher_password = $_POST['password'];

// Check if both fields are provided
if (empty($teacher_name) || empty($teacher_password)) {
    echo json_encode(['success' => false, 'message' => 'Please enter both Teacher ID and Password']);
    exit();
}

// Prepare the SQL query to check the teacher's credentials
$sql = "SELECT * FROM teachers WHERE teacher_name = ? AND password = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("ss", $teacher_name, $teacher_password);

// Execute the query
$stmt->execute();
$result = $stmt->get_result();

// Check if a matching teacher was found
if ($result->num_rows > 0) {
    // Login successful
    echo json_encode(['success' => true, 'message' => 'Login successful']);
} else {
    // Login failed
    echo json_encode(['success' => false, 'message' => 'Invalid Teacher ID or Password']);
}

// Close the database connection
$stmt->close();
$conn->close();
?>
