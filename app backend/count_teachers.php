<?php
header('Content-Type: application/json'); // Set response type to JSON

$host = 'localhost'; // Change if necessary
$username = 'root'; // Replace with your DB username
$password = ''; // Replace with your DB password
$database = 'teachers'; // Database name

// Connect to MariaDB
$conn = new mysqli($host, $username, $password, $database);

// Check connection
if ($conn->connect_error) {
    die(json_encode(["error" => "Connection failed: " . $conn->connect_error]));
}

// Query to count total teachers
$totalTeachersQuery = "SELECT COUNT(*) AS totalTeachers FROM teachers";
$totalTeachersResult = $conn->query($totalTeachersQuery);
$totalTeachers = 0;

if ($totalTeachersResult) {
    $row = $totalTeachersResult->fetch_assoc();
    $totalTeachers = $row['totalTeachers'];
}

// Query to count teachers marked as 'Present' in teacherattendance table
$presentTeachersQuery = "SELECT COUNT(*) AS presentTeachers FROM teacherattendance WHERE Attendance = 'Present'";
$presentTeachersResult = $conn->query($presentTeachersQuery);
$presentTeachers = 0;

if ($presentTeachersResult) {
    $row = $presentTeachersResult->fetch_assoc();
    $presentTeachers = $row['presentTeachers'];
}

// Close connection
$conn->close();

// Return JSON response
echo json_encode([
    "totalTeachers" => $totalTeachers,
    "presentTeachers" => $presentTeachers
]);
?>
