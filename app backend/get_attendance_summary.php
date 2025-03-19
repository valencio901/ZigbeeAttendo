<?php
// Set content type to JSON
header('Content-Type: application/json');

// Enable CORS for cross-origin requests (optional)
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");

// Database credentials
$servername = "localhost";  // Update with your database server
$username = "root";     // Update with your database username
$password = "";     // Update with your database password
$dbname = "ninth";          // Update with your database name

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die(json_encode(["status" => "error", "message" => "Connection failed: " . $conn->connect_error]));
}

// Get the JSON input
$inputData = json_decode(file_get_contents("php://input"), true);

// Check if rollno is provided
if (!isset($inputData['rollno'])) {
    echo json_encode(["status" => "error", "message" => "Roll number is required"]);
    exit;
}

$rollno = $inputData['rollno'];

// Query to get attendance data for the specific rollno
$sql = "SELECT attendance FROM attendance WHERE rollno = ?";

// Prepare and bind the SQL statement
$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $rollno); // "i" denotes integer type for rollno
$stmt->execute();

// Get the result
$result = $stmt->get_result();

// Initialize counters
$presentCount = 0;
$absentCount = 0;

// Loop through the results and count present and absent records
while ($row = $result->fetch_assoc()) {
    if ($row['attendance'] == 'present') {
        $presentCount++;
    } elseif ($row['attendance'] == 'absent') {
        $absentCount++;
    }
}

// Get total number of classes for the student
$totalClasses = $presentCount + $absentCount;

// Close the connection
$stmt->close();
$conn->close();

// Return the data as JSON response
if ($totalClasses > 0) {
    echo json_encode([
        "status" => "success",
        "attendance" => [
            "present" => $presentCount,
            "absent" => $absentCount,
            "total_classes" => $totalClasses
        ]
    ]);
} else {
    echo json_encode(["status" => "error", "message" => "No attendance data found for the given rollno"]);
}
?>
