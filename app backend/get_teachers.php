<?php
// Database configuration
$host = 'localhost'; // Your MySQL host
$dbname = 'teachers'; // Your database name
$username = 'root'; // Your database username
$password = ''; // Your database password

// Create connection
$conn = new mysqli($host, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Query to fetch teacher names
$sql = "SELECT teacher_id, teacher_name FROM teachers";

// Execute query and check for errors
$result = $conn->query($sql);

if ($result->num_rows > 0) {
    // Store the results in an array
    $teachers = array();
    while($row = $result->fetch_assoc()) {
        $teachers[] = array(
            'teacher_id' => $row['teacher_id'],
            'teacher_name' => $row['teacher_name']
        );
    }

    // Return the teachers data as a JSON response
    echo json_encode($teachers);
} else {
    // No teachers found
    echo json_encode([]);
}

// Close connection
$conn->close();
?>
