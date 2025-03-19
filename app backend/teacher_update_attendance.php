<?php
header("Content-Type: application/json");

// Get POST data
$class = $_POST['class']; // Database name
$rollno = $_POST['rollno'];
$attendance = $_POST['attendance'];
$date = $_POST['date'];
$subject = $_POST['subject'];

// Validate input
if (empty($class) || empty($rollno) || empty($attendance) || empty($date) || empty($subject)) {
    echo json_encode(["status" => "error", "message" => "Missing required parameters"]);
    exit;
}

// Database connection
$host = "localhost";
$username = "root";
$password = "";

$conn = new mysqli($host, $username, $password, $class); // Use class as database name

if ($conn->connect_error) {
    die(json_encode(["status" => "error", "message" => "Connection failed: " . $conn->connect_error]));
}

// Prepare the SQL statement
$sql = "UPDATE attendance SET attendance = ? WHERE rollno = ? AND date = ? AND subject = ?";
$stmt = $conn->prepare($sql);

if ($stmt) {
    $stmt->bind_param("siss", $attendance, $rollno, $date, $subject);
    if ($stmt->execute()) {
        echo json_encode(["status" => "success", "message" => "Attendance updated successfully"]);
    } else {
        echo json_encode(["status" => "error", "message" => "Update failed"]);
    }
    $stmt->close();
} else {
    echo json_encode(["status" => "error", "message" => "SQL error: " . $conn->error]);
}

$conn->close();
?>
