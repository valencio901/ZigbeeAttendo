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

// Get the teacherName from the query string
if (isset($_GET['teacherName'])) {
    $teacher_name = $_GET['teacherName'];
} else {
    echo json_encode(['success' => false, 'message' => 'Teacher name not provided']);
    exit();
}

// Prepare the SQL query to fetch the teacher's details
$sql = "SELECT teacher_name, phone_number, address FROM teachers WHERE teacher_name = ?";
$stmt = $conn->prepare($sql);

// Check for query preparation errors
if ($stmt === false) {
    echo json_encode(['success' => false, 'message' => 'Error in preparing query: ' . $conn->error]);
    exit();
}

// Bind the parameter
$stmt->bind_param("s", $teacher_name);

// Execute the query
$stmt->execute();
$result = $stmt->get_result();

// Check if the teacher exists
if ($result->num_rows > 0) {
    // Fetch the teacher's data
    $teacher = $result->fetch_assoc();

    // Return the teacher details as a JSON response
    echo json_encode([
        'success' => true,
        'teacher_name' => $teacher['teacher_name'],
        'phone_number' => $teacher['phone_number'],
        'address' => $teacher['address']
    ]);
} else {
    // If no teacher found, return an error message
    echo json_encode(['success' => false, 'message' => 'Teacher not found']);
}

// Close the database connection
$stmt->close();
$conn->close();
?>
