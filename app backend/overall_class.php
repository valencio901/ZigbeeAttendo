<?php
$servername = "localhost"; // Change if your database is hosted elsewhere
$username = "root"; // Change to your database username
$password = ""; // Change to your database password
$dbname = "fybca_a"; // Your database name

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Get the current date
$current_date = date('Y-m-d');

// Query to get the total number of students
$sql_total = "SELECT COUNT(DISTINCT rollno) AS total_students FROM attendance WHERE date = '$current_date'";
$result_total = $conn->query($sql_total);
$total_students = ($result_total->num_rows > 0) ? $result_total->fetch_assoc()['total_students'] : 0;

// Query to get the number of students present
$sql_present = "SELECT COUNT(DISTINCT rollno) AS present_students FROM attendance WHERE attendance = 'Present' AND date = '$current_date'";
$result_present = $conn->query($sql_present);
present_students = ($result_present->num_rows > 0) ? $result_present->fetch_assoc()['present_students'] : 0;

// Prepare response
$attendance_summary = [
    "date" => $current_date,
    "total_students" => $total_students,
    "present_students" => $present_students
];

// Encode data into JSON format
header('Content-Type: application/json');
echo json_encode($attendance_summary, JSON_PRETTY_PRINT);

// Close connection
$conn->close();
?>