<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

// Database connection details
$host = "localhost"; // e.g., localhost
$username = "root";
$password = "";
$database = "ninth";

// Create connection
$conn = new mysqli($host, $username, $password, $database);

// Check connection
if ($conn->connect_error) {
    die(json_encode(["error" => "Connection failed: " . $conn->connect_error]));
}

// Get parameters from the request
$teacherId = isset($_GET['teacherId']) ? intval($_GET['teacherId']) : 0;
$subject = isset($_GET['subject']) ? $conn->real_escape_string($_GET['subject']) : "";
$rollno = isset($_GET['rollno']) ? intval($_GET['rollno']) : 0;
$class = $_GET['class'];

// Validate input
if ($teacherId == 0 || empty($subject) || $rollno == 0) {
    echo json_encode(["error" => "Invalid parameters"]);
    exit;
}

// SQL query to fetch attendance records
$sql = "SELECT datee, time, attendance FROM attendance 
        WHERE teacher_id = ? AND subject = ? AND rollno = ? AND class = ?
        ORDER BY datee DESC";

$stmt = $conn->prepare($sql);
$stmt->bind_param("isis", $teacherId, $subject, $rollno, $class);
$stmt->execute();
$result = $stmt->get_result();

// Fetch data
$attendanceRecords = [];
while ($row = $result->fetch_assoc()) {
    $attendanceRecords[] = [
        "datee" => $row["datee"],
        "time" => $row["time"],
        "attendance" => $row["attendance"]
    ];
}

// Close connection
$stmt->close();
$conn->close();

// Return JSON response
echo json_encode($attendanceRecords);
?>
