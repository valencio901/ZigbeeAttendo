<?php
header('Content-Type: application/json');

// Assuming you already have a DB connection established
// Replace the credentials with your actual DB details
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "ninth";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

$teacherId = $_GET['teacherId'];
$subject = $_GET['subject'];
$rollno = $_GET['rollno'];

// Query to fetch attendance data based on the selected subject, roll number, and teacher ID
$query = "SELECT datee, time, attendance FROM attendance WHERE teacher_id = ? AND subject = ? AND rollno = ?";
$stmt = $conn->prepare($query);
$stmt->bind_param("isi", $teacherId, $subject, $rollno);
$stmt->execute();
$result = $stmt->get_result();

$attendance_data = [];
while ($row = $result->fetch_assoc()) {
    $attendance_data[] = [
        'date' => $row['datee'],
        'time' => $row['time'],
        'attendance' => $row['attendance'],
    ];
}

echo json_encode(['attendance' => $attendance_data]);

$stmt->close();
$conn->close();
?>
